package BVIApplication;

import java.util.Comparator;

public class BVIModel {

    // Priority Levels
    static final int PRIORITY_EMERGENCY_CALL = 1;
    static final int PRIORITY_RISK_DETECTION = 2;
    static final int PRIORITY_NAVIGATION_GUIDANCE = 3;
    static final int PRIORITY_ENVIRONMENT_DESCRIPTION = 4;

    // Threads
    Thread emergencyThread;
    Thread riskThread;
    Thread navigationThread;
    Thread garbageCollectorThread;
    Thread environmentThread;
    Thread audioProcessorThread;

    // Shared resource: Command queue for audio processing
    CustomPriorityBlockingQueue<AudioCommand> commandQueue;

    private BVIController controller;

    public boolean stopSimulation = false;

    public BVIModel(AudioOutputProcessor audioOutputProcessor, GarbageCollector garbageCollector) {
        commandQueue = new CustomPriorityBlockingQueue<>(20, Comparator.comparingInt(a -> a.priority));
        emergencyThread = new Thread(new EmergencyCall(this));
        riskThread = new Thread(new RiskDetection(this));
        navigationThread = new Thread(new NavigationGuidance(this));
        garbageCollector.setModel(this);
        garbageCollectorThread = new Thread(garbageCollector);
        environmentThread = new Thread(new EnvironmentDescription(this));
        audioOutputProcessor.setBVIApplication(this);
        audioProcessorThread = new Thread(audioOutputProcessor);
    }

    public void setController(BVIController controller) {
        this.controller = controller; // Set the controller reference
    }

    public void start() {
        emergencyThread.start();
        riskThread.start();
        navigationThread.start();
        garbageCollectorThread.start();
        environmentThread.start();
        audioProcessorThread.start();
    }

    public void stop() {
        stopSimulation = true;
        try {
            emergencyThread.join();
            riskThread.join();
            navigationThread.join();
            garbageCollectorThread.join();
            environmentThread.join();
            audioProcessorThread.join();
        } catch (InterruptedException e) {
            System.out.println("Error stopping threads: " + e.getMessage());
        }
    }

    public void addCommand(AudioCommand command) {
        try {
            commandQueue.put(command);
            if (controller != null) {
                controller.updateViewWithNewCommand(command);
            }
        } catch (InterruptedException e) {
            System.out.println("Error adding command to queue: " + e.getMessage());
        }
    }

}
