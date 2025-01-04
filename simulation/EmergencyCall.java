import java.util.Random;

public class EmergencyCall implements Runnable {
    private BVIApplication app;
    private int counter = 1;

    public EmergencyCall(BVIApplication app) {
        this.app = app;
    }

    public void run() {
        while (!app.stopSimulation) { 
            boolean emergencyDetected = new Random().nextDouble() < 0.01;
            if (emergencyDetected) {
                try {
                    app.audioLock.lock();
                    String identifier = "EC" + counter++;
                    app.commandQueue.add(new AudioCommand("Emergency call in progress...", BVIApplication.PRIORITY_EMERGENCY_CALL, Thread.currentThread(),identifier));
                    app.printQueueState();
                    app.outputReady.signalAll();
                } catch (Exception e) {
                    Thread.currentThread().interrupt();
                    e.printStackTrace();
                } finally {
                    app.audioLock.unlock();
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
