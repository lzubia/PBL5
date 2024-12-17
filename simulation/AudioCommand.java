
public class AudioCommand {
    String message;
    int priority;
    Thread creatorThread;
    String identifier;  // Unique identifier for the command

    public AudioCommand(String message, int priority, Thread creatorThread, String identifier) {
        this.message = message;
        this.priority = priority;
        this.creatorThread = creatorThread;
        this.identifier = identifier;
    }

    @Override
    public String toString() {
        return String.format("%s (Priority: %d)", identifier, priority);
    }
}
