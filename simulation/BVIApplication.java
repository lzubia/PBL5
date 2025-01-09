import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.PriorityBlockingQueue;

public class BVIApplication {

    static final int PRIORITY_EMERGENCY_CALL = 1;
    static final int PRIORITY_RISK_DETECTION = 2;
    static final int PRIORITY_NAVIGATION_GUIDANCE = 3;
    static final int PRIORITY_ENVIRONMENT_DESCRIPTION = 4;
    static final int COMMAND_TIME_WAITING = 10; // 10 seconds

    // Shared resource: Audio OutputProcessor
    PriorityBlockingQueue<AudioCommand> commandQueue = new PriorityBlockingQueue<>(20,
            Comparator.comparingInt(a -> a.priority));

    public boolean stopSimulation = false;

    public void printQueueState() {
        StringBuilder queueState = new StringBuilder();
        for (AudioCommand command : commandQueue) {
            queueState.append(command.toString()).append(" ; ");
        }
        System.out.println("🔜 " + queueState);
    }

    public void cleanExpiredCommands() {
        Instant now = Instant.now();
        List<AudioCommand> expiredCommands = new ArrayList<>();

        for (AudioCommand command : commandQueue) {
            if (Duration.between(command.enqueueTime, now).getSeconds() > COMMAND_TIME_WAITING) {
                expiredCommands.add(command);
            }
        }

        commandQueue.removeAll(expiredCommands);

        if (!expiredCommands.isEmpty()) {
            System.out.println("Removed expired commands from the queue:");
            for (AudioCommand cmd : expiredCommands) {
                System.out.println("\t✖️ Expired Command: " + cmd.identifier);
            }
        }
    }

    public static void main(String[] args) {
        BVIApplication app = new BVIApplication();

        Thread emergencyThread = new Thread(new EmergencyCall(app));
        Thread riskThread = new Thread(new RiskDetection(app));
        Thread navigationThread = new Thread(new NavigationGuidance(app));
        Thread environmentThread = new Thread(new EnvironmentDescription(app));
        Thread audioProcessorThread = new Thread(new AudioOutputProcessor(app));

        emergencyThread.start();
        riskThread.start();
        navigationThread.start();
        environmentThread.start();
        audioProcessorThread.start();

        try {
            Thread.sleep(40000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        app.stopSimulation = true; // Stop simulation after 10 seconds

        try {
            emergencyThread.join();
            riskThread.join();
            navigationThread.join();
            environmentThread.join();
            audioProcessorThread.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        System.out.println("Simulation finished");
    }

}
