import java.util.*;

public class BVIApplication {

    static final int PRIORITY_EMERGENCY_CALL = 1;
    static final int PRIORITY_RISK_DETECTION = 2;
    static final int PRIORITY_NAVIGATION_GUIDANCE = 3;
    static final int PRIORITY_ENVIRONMENT_DESCRIPTION = 4;
    static final int COMMAND_TIME_WAITING = 10; // 10 seconds

    // Shared resource: Audio OutputProcessor
    CustomPriorityBlockingQueue<AudioCommand> commandQueue = new CustomPriorityBlockingQueue<>(20,
            Comparator.comparingInt(a -> a.priority));

    public boolean stopSimulation = false;

    public void printQueueState() {
        StringBuilder queueState = new StringBuilder();
        for (AudioCommand command : commandQueue.getAll()) {
            queueState.append(command.toString()).append(" ; ");
        }
        System.out.println("🔜 " + queueState);
    }

    public static void main(String[] args) {
        BVIApplication app = new BVIApplication();

        Thread emergencyThread = new Thread(new EmergencyCall(app));
        Thread riskThread = new Thread(new RiskDetection(app));
        Thread navigationThread = new Thread(new NavigationGuidance(app));
        Thread environmentThread = new Thread(new EnvironmentDescription(app));
        Thread audioProcessorThread = new Thread(new AudioOutputProcessor(app));
        Thread garbageCollectorThread = new Thread(new GarbageCollector(app));

        emergencyThread.start();
        riskThread.start();
        navigationThread.start();
        environmentThread.start();
        audioProcessorThread.start();
        garbageCollectorThread.start();

        try {
            Thread.sleep(40000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        app.stopSimulation = true; // Stop simulation

        try {
            emergencyThread.join();
            riskThread.join();
            navigationThread.join();
            environmentThread.join();
            audioProcessorThread.join();
            garbageCollectorThread.join();

        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        System.out.println("Simulation finished");
    }

}
