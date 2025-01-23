package BVIApplication;

import java.time.Duration;
import java.util.Map;

public class BVIController {
    private BVIModel model;
    private BVIView view;

    public BVIController(BVIModel model, BVIView view) {
        this.model = model;
        this.view = view;
    }

    public void handleButtonClick(String commandType) {
        int priority;
        String message = null;

        switch (commandType) {
            case "Emergency Call":
                priority = BVIModel.PRIORITY_EMERGENCY_CALL;
                message = "Emergency call initiated.";
                break;
            case "Risk Detection":
                priority = BVIModel.PRIORITY_RISK_DETECTION;
                message = "Danger ahead, stop immediately!";
                break;
            case "Navigation Guidance":
                priority = BVIModel.PRIORITY_NAVIGATION_GUIDANCE;
                message = "Turn right to follow the path.";
                break;
            case "Environment Description":
                priority = BVIModel.PRIORITY_ENVIRONMENT_DESCRIPTION;
                message = "Ahead is a pedestrian crossing with vehicles waiting at the red light.";
                break;
            default:
                throw new IllegalArgumentException("Unknown command type: " + commandType);
        }

        // Add a new command to the model
        AudioCommand command = new AudioCommand(message, priority, Thread.currentThread(),
                generateIdentifier(commandType));
        model.addCommand(command);
    }

    private String generateIdentifier(String commandType) {
        String[] words = commandType.split(" ");
        String prefix = words[0].substring(0, 1) + words[1].substring(0, 1);
        return prefix.toUpperCase();
    }

    public void updateViewWithNewCommand(AudioCommand command) {
        if (view != null) {
            view.addCommandToQueueView(command);
        }
    }

    public void removeCommandFromQueueView(AudioCommand command, boolean isGarbage) {
        view.removeCommandFromQueueView(command, true);
    }

    public void updateMetrics(Map<String, Integer> deletedCommandCounts, Duration totalWaitingTime, Duration totalQueueFullTime) {
        // Update the metrics in the view
        view.updateMetrics(deletedCommandCounts, totalWaitingTime, totalQueueFullTime);
    }

}
