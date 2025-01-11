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
                AudioCommand command = app.commandQueue.take(); // Take the first in the queue
                if (command != null) {
                    System.out.println("\t\t\t\t\t\t📢 " + command.identifier + ": " + command.message);

                    int duration = calculateDuration(command.message);
                    Thread.sleep(duration);
                }

            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                e.printStackTrace();
            }
        }
        System.out.println("AudioOutputProcessor thread stopped");
    }
}
