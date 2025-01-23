package BVIApplication;

import java.util.Arrays;
import java.util.List;
import java.util.Random;

public class RiskDetection implements Runnable {
    private BVIModel model;  // Use BVIModel instead of BVIModel
    private int counter = 1;
    private List<String> messagePool = Arrays.asList(
        "Obstacle detected!",
        "Danger ahead, stop immediately!",
        "Caution, an object is blocking the path!",
        "Alert: Moving object detected nearby."
    );

    public RiskDetection(BVIModel model) {
        this.model = model;
    }

    public String getRandomMessage() {
        return messagePool.get(new Random().nextInt(messagePool.size()));
    }

    @Override
    public void run() {
        while (!model.stopSimulation) {
            boolean riskDetected = new Random().nextDouble() < 0.3;
            if (riskDetected) {
                try {
                    String identifier = "RD" + counter++;
                    String message = getRandomMessage();

                    AudioCommand command = new AudioCommand(message, BVIModel.PRIORITY_RISK_DETECTION, 
                            Thread.currentThread(), identifier);
                    model.addCommand(command); // Add command to the model's queue

                } catch (Exception e) {
                    Thread.currentThread().interrupt();
                    e.printStackTrace();
                }
            }
            try {
                Thread.sleep(4000); // Sleep for 2 seconds
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                e.printStackTrace();
            }
        }
        System.out.println("RiskDetection thread stopped");
    }
}
