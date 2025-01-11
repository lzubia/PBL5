import java.util.Arrays;
import java.util.List;
import java.util.Random;

public class RiskDetection implements Runnable {
    private BVIApplication app;
    private int counter = 1;
    private List<String> messagePool = Arrays.asList(
        "Obstacle detected!",
        "Danger ahead, stop immediately!",
        "Caution, an object is blocking the path!",
        "Alert: Moving object detected nearby."
    );

    public RiskDetection(BVIApplication app) {
        this.app = app;
    }

    @Override
    public void run() {
        while (!app.stopSimulation) {
            boolean riskDetected = new Random().nextDouble() < 0.2;
            if (riskDetected) {
                try {
                    String identifier = "RD" + counter++;
                    String message = messagePool.get(new Random().nextInt(messagePool.size()));
                    app.commandQueue.put(new AudioCommand(message, BVIApplication.PRIORITY_RISK_DETECTION, Thread.currentThread(), identifier));
                    app.printQueueState();
                } catch (Exception e) {
                    Thread.currentThread().interrupt();
                    e.printStackTrace();
                }
            }
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                e.printStackTrace();
            }
        }
        System.out.println("RiskDetection thread stopped");
    }
}
