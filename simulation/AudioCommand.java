import java.time.Instant;

public class AudioCommand {
    String message;
    int priority;
    Thread creatorThread;
    String identifier;  // Unique identifier for the command
    Instant enqueueTime; // Timestamp when the command was added
    Float maxTimeWaiting; // Maximum time the command can be in the queue

    public AudioCommand(String message, int priority, Thread creatorThread, String identifier) {
        this.message = message;
        this.priority = priority;
        this.creatorThread = creatorThread;
        this.identifier = identifier;
        this.enqueueTime = Instant.now();
        this.maxTimeWaiting = calculateMaxTimeWaiting(priority); // Dynamically calculated
    }

    private Float calculateMaxTimeWaiting(int priority) {
        //TODO: Implement the formula for calculating the maximum time a command can wait in the queue
        
        float baseTime = 100_000f; // Base time for priority 1 (100 seconds)
        float exponent = 1.5f; // Controls steepness of decay
        return (float) Math.round(baseTime * Math.pow(1.0 / priority, exponent));
    }

    @Override
    public String toString() {
        return String.format("%s (Priority: %d)", identifier, priority);
    }
}
