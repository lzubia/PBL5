package BVIApplication;

import java.util.Random;

public class EmergencyCall implements Runnable {
    private BVIModel model;
    private int counter = 1;

    public EmergencyCall(BVIModel model) {
        this.model = model;
    }

    @Override
    public void run() {
        while (!model.stopSimulation) {
            boolean emergencyDetected = new Random().nextDouble() < 0.01; // Random emergency detection
            if (emergencyDetected) {
                try {
                    String identifier = "EC" + counter++;
                    AudioCommand command = new AudioCommand("Emergency call in progress...", BVIModel.PRIORITY_EMERGENCY_CALL, Thread.currentThread(), identifier);
                    model.addCommand(command);
                } catch (Exception e) {
                    Thread.currentThread().interrupt();
                    e.printStackTrace();
                }
            }
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                e.printStackTrace();
            }
        }
        System.out.println("EmergencyCall thread stopped");
    }
}
