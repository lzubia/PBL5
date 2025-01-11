import java.util.Arrays;
import java.util.List;
import java.util.Random;

public class EnvironmentDescription implements Runnable {
    private BVIApplication app;
    private int counter = 1;
    private List<String> messagePool = Arrays.asList(
        "To your left, there's a park with several children playing on swings.",
        "To your right, there’s a bustling street market filled with vendors selling fruits and vegetables.",
        "You’ve entered a shopping mall; the air is filled with the sound of people talking and faint music playing.",
        "To your left, there’s a fountain surrounded by benches where people are resting.",
        "Ahead is a pedestrian crossing with vehicles waiting at the red light.");

    public EnvironmentDescription(BVIApplication app) {
        this.app = app;
    }

    @Override
    public void run() {
        while (!app.stopSimulation) {
            try {
                String identifier = "ED" + counter++;
                String message = messagePool.get(new Random().nextInt(messagePool.size()));
                app.commandQueue.put(new AudioCommand(message, BVIApplication.PRIORITY_ENVIRONMENT_DESCRIPTION,
                        Thread.currentThread(), identifier));
                app.printQueueState();
            } catch (Exception e) {
                Thread.currentThread().interrupt();
                e.printStackTrace();
            }
            try {
                Thread.sleep(4000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                e.printStackTrace();
            }
        }
        System.out.println("EnvironmentDescription thread stopped");
    }
}
