package BVIApplication;

import javax.swing.SwingUtilities;

public class MainApp {
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            BVIView view = new BVIView();  // Create the view
            AudioOutputProcessor audioProcessor = null;
            try {
                audioProcessor = new AudioOutputProcessor(view);
            } catch (Exception e) {
                System.out.println("Error initializing audio processor: " + e.getMessage());
            }
            GarbageCollector garbageCollector = new GarbageCollector();
            BVIModel model = new BVIModel(audioProcessor, garbageCollector);  // Create the model
            BVIController controller = new BVIController(model, view);  // Create the controller
            garbageCollector.setController(controller);
            model.setController(controller);
            view.setController(controller);
            view.setVisible(true);
            model.start();  // Start the simulation
        });
    }
}
