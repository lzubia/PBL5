import java.util.Arrays;
import java.util.List;
import java.util.Random;

public class NavigationGuidance implements Runnable {
    private BVIApplication app;
    private int counter = 1;
    private List<String> messagePool = Arrays.asList(
        "Turn left at the next intersection.",
        "Continue straight for 100 meters.",
        "Turn right to follow the path.",
        "Prepare to stop at the next crosswalk."
    );

    public NavigationGuidance(BVIApplication app) {
        this.app = app;
    }

    public void run() {
        while (!app.stopSimulation) {
            try {
                app.audioLock.lock();
                String identifier = "NG" + counter++;
                String message = messagePool.get(new Random().nextInt(messagePool.size()));
                app.commandQueue.add(new AudioCommand(message, BVIApplication.PRIORITY_NAVIGATION_GUIDANCE, Thread.currentThread(), identifier));
                app.printQueueState();
                app.outputReady.signal();
            } catch (Exception e) {
                Thread.currentThread().interrupt();
                e.printStackTrace();
            } finally {
                app.audioLock.unlock();
            }
            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                e.printStackTrace();
            }
        }
        System.out.println("NavigationGuidance thread stopped");
    }
}
