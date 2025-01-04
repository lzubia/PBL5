import java.time.Instant;

public class AudioCommand {
    String message;
    int priority;
    Thread creatorThread;
    String identifier;  // Unique identifier for the command
    Instant enqueueTime; // Timestamp when the command was added

    public AudioCommand(String message, int priority, Thread creatorThread, String identifier) {
        this.message = message;
        this.priority = priority;
        this.creatorThread = creatorThread;
        this.identifier = identifier;
        this.enqueueTime = Instant.now();
    }

    @Override
    public String toString() {
        return String.format("%s (Priority: %d)", identifier, priority);
    }
}
