import java.util.concurrent.TimeUnit;

public class AudioOutputProcessor implements Runnable {
    private BVIApplication app;
    
    public AudioOutputProcessor(BVIApplication app) {
        this.app = app;
    }
    
    private int calculateDuration(String message) {
        int characters = message.length();
        int timePerCharacter = 50; // 50 ms per character
        return characters * timePerCharacter;
    }

    public void run() {
        while (!app.stopSimulation) {
            try {
                app.audioLock.lock();
                AudioCommand command = app.commandQueue.poll(); // Take the first in the queue
                if (command != null) {
                    System.out.println("\t\t\t\t\t\t" + command.identifier + ": " + command.message);

                    int duration = calculateDuration(command.message);
                    // System.out.println("\t\t\t\t\t\tDuration (ms): " + duration);
                    
                    app.audioLock.unlock(); // Unlock before sleeping to allow other threads to interact
                    Thread.sleep(duration);
                    app.audioLock.lock(); // Re-lock after sleeping
                }

                // Timeout to ensure the thread doesn't block indefinitely (max 5 seconds)
                boolean signaled = app.outputReady.await(5000, TimeUnit.MILLISECONDS);
                if (!signaled && app.stopSimulation) {
                    break;
                }

            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                e.printStackTrace();
            } finally {
                app.audioLock.unlock();
            }
        }
        System.out.println("AudioOutputProcessor thread stopped");
    }
}
