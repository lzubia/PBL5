package BVIApplication;

import java.util.Arrays;
import java.util.List;
import java.util.Random;

public class NavigationGuidance implements Runnable {
    private BVIModel model;  // Use BVIModel instead of BVIModel
    private int counter = 1;
    private List<String> messagePool = Arrays.asList(
        "Turn left at the next intersection.",
        "Continue straight for 100 meters.",
        "Turn right to follow the path.",
        "Prepare to stop at the next crosswalk."
    );

    public NavigationGuidance(BVIModel model) {
        this.model = model;
    }

    public String getRandomMessage() {
        return messagePool.get(new Random().nextInt(messagePool.size()));
    }

    @Override
    public void run() {
        while (!model.stopSimulation) {
            try {
                String identifier = "NG" + counter++;
                String message = getRandomMessage();

                AudioCommand command = new AudioCommand(message, BVIModel.PRIORITY_NAVIGATION_GUIDANCE, 
                        Thread.currentThread(), identifier);
                model.addCommand(command); // Add command to the model's queue

            } catch (Exception e) {
                Thread.currentThread().interrupt();
                e.printStackTrace();
            }
            try {
                Thread.sleep(5000); // Sleep for 6 seconds
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                e.printStackTrace();
            }
        }
        System.out.println("NavigationGuidance thread stopped");
    }
}
