package BVIApplication;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GarbageCollector implements Runnable {
    
    private BVIModel model;
    private BVIController controller; // Reference to the controller

    // Metrics tracking
    private Map<String, Integer> deletedCommandCounts = new HashMap<>();
    private Duration totalWaitingTime = Duration.ZERO;
    private Duration totalQueueFullTime = Duration.ZERO;

    // Time tracking
    private Instant lastQueueStateCheck = Instant.now();
    private boolean wasQueueFull = false;

    public void setModel(BVIModel model) {
        this.model = model;
    }

    public void setController(BVIController controller) {
        this.controller = controller;
    }

    @Override
    public void run() {
        while (!model.stopSimulation) {
            try {
                List<AudioCommand> expiredCommands = new ArrayList<>();
                Instant now = Instant.now();

                // Check for expired commands
                for (AudioCommand command : model.commandQueue.getAll()) {
                    if (Duration.between(command.enqueueTime, now).toMillis() > command.maxTimeWaiting) {
                        expiredCommands.add(command);
                        String commandType = getCommandType(command.identifier);
                        deletedCommandCounts.merge(commandType, 1, Integer::sum);
                    }
                }

                // Remove expired commands from the queue
                for (AudioCommand expired : expiredCommands) {
                    model.commandQueue.remove(expired);
                    controller.removeCommandFromQueueView(expired, true);
                }

                updateQueueMetrics(now);
                controller.updateMetrics(deletedCommandCounts, totalWaitingTime, totalQueueFullTime);

                Thread.sleep(5000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                System.err.println("GarbageCollector thread interrupted");
                break;
            }
        }
        System.out.println("GarbageCollector thread stopped");
        printMetrics();
    }

    private void updateQueueMetrics(Instant now) {
        boolean isQueueFull = model.commandQueue.isFull();
        boolean isQueueEmpty = model.commandQueue.isEmpty();
        Duration timeSinceLastCheck = Duration.between(lastQueueStateCheck, now);
        if (isQueueFull) {
            totalQueueFullTime = totalQueueFullTime.plus(timeSinceLastCheck);
        }
        if (isQueueEmpty) {
            totalWaitingTime = totalWaitingTime.plus(timeSinceLastCheck);
        }
        wasQueueFull = isQueueFull;
        lastQueueStateCheck = now;
    }

    private void printMetrics() {
        System.out.println("=== GarbageCollector Performance Metrics ===");
        System.out.println("Deleted Commands by Type:");
        for (Map.Entry<String, Integer> entry : deletedCommandCounts.entrySet()) {
            System.out.println("\tType: " + entry.getKey() + ", Count: " + entry.getValue());
        }
        System.out.println("Total time audio output processor waited for commands: " + totalWaitingTime.toMillis() + " ms");
        System.out.println("Total time queue was completely full: " + totalQueueFullTime.toMillis() + " ms");
        System.out.println("===========================================");
    }

    private String getCommandType(String identifier) {
        if (identifier.startsWith("EC")) {
            return "EmergencyCall";
        } else if (identifier.startsWith("RD")) {
            return "RiskDetection";
        } else if (identifier.startsWith("NG")) {
            return "NavigationGuidance";
        } else if (identifier.startsWith("ED")) {
            return "EnvironmentDescription";
        } else {
            return "Unknown";
        }
    }
}
