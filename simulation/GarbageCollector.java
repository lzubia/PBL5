import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

public class GarbageCollector implements Runnable {
    private BVIApplication app;

    public GarbageCollector(BVIApplication app) {
        this.app = app;
    }

    @Override
    public void run() {
        while (!app.stopSimulation) {
            try {
                List<AudioCommand> expiredCommands = new ArrayList<>();
                Instant now = Instant.now();

                for (AudioCommand command : app.commandQueue.getAll()) {
                    if (Duration.between(command.enqueueTime, now).toMillis() > command.maxTimeWaiting) {
                        expiredCommands.add(command);
                    }
                }

                for (AudioCommand expired : expiredCommands) {
                    app.commandQueue.remove(expired);
                }

                if (!expiredCommands.isEmpty()) {
                    System.out.println("GarbageCollector: Removed expired commands from the queue:");
                    for (AudioCommand cmd : expiredCommands) {
                        System.out.println("\t✖️ Expired Command: " + cmd.identifier);
                    }
                }

                Thread.sleep(5000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                System.err.println("GarbageCollector thread interrupted");
            }
        }
        System.out.println("GarbageCollector thread stopped");
    }
}
