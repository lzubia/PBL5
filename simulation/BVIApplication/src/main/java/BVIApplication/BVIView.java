package BVIApplication;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.time.Duration;
import java.util.Map;

public class BVIView extends JFrame {
    private JPanel queuePanel;
    private JPanel deletedPanel; // Panel for deleted commands
    private JPanel metricsPanel; // Panel for metrics display
    private BVIController controller; // Reference to the controller

    public BVIView() {
        setTitle("BVI Command Processor");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(800, 600);
        setLayout(new BorderLayout());
        setBackground(new Color(240, 240, 240));
        setWindowIcon();
        setupButtons();
        setupPanels();
    }

    private void setWindowIcon() {
        // Load an image from resources (ensure the icon is in your project directory)
        ImageIcon icon = new ImageIcon(getClass().getResource("/icon.png"));
        setIconImage(icon.getImage());
    }

    public void setController(BVIController controller) {
        this.controller = controller;
    }

    private void setupPanels() {
        // Setup command queue panel
        queuePanel = new JPanel();
        queuePanel.setLayout(new BoxLayout(queuePanel, BoxLayout.Y_AXIS));
        queuePanel.setBorder(new EmptyBorder(10, 20, 10, 10));

        JScrollPane queueScrollPane = new JScrollPane(queuePanel);
        queueScrollPane.setBorder(BorderFactory.createTitledBorder("Command Queue"));
        add(queueScrollPane, BorderLayout.CENTER);

        // Setup deleted commands panel
        deletedPanel = new JPanel();
        deletedPanel.setLayout(new BoxLayout(deletedPanel, BoxLayout.Y_AXIS));
        deletedPanel.setBorder(new EmptyBorder(10, 10, 10, 10));

        JScrollPane deletedScrollPane = new JScrollPane(deletedPanel);
        deletedScrollPane.setPreferredSize(new Dimension(300, 0)); // Set width for deleted panel
        deletedScrollPane.setBorder(BorderFactory.createTitledBorder("Deleted Commands"));
        add(deletedScrollPane, BorderLayout.EAST);

        // Setup metrics panel
        metricsPanel = new JPanel();
        metricsPanel.setLayout(new BoxLayout(metricsPanel, BoxLayout.Y_AXIS));
        metricsPanel.setBorder(new EmptyBorder(10, 10, 10, 10));
        JScrollPane metricsScrollPane = new JScrollPane(metricsPanel);
        metricsScrollPane.setPreferredSize(new Dimension(0, 200)); // Set height for metrics panel
        metricsScrollPane.setBorder(BorderFactory.createTitledBorder("Metrics"));
        add(metricsScrollPane, BorderLayout.SOUTH);
    }

    private void setupButtons() {
        JPanel buttonPanel = new JPanel(new GridBagLayout());
        buttonPanel.setBorder(new EmptyBorder(10, 10, 10, 10)); // Add spacing around the panel
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(10, 10, 10, 10); // Add spacing between buttons

        // Create buttons for each command type
        JButton emergencyButton = new RoundedButton("Emergency Call");
        JButton riskButton = new RoundedButton("Risk Detection");
        JButton navigationButton = new RoundedButton("Navigation Guidance");
        JButton environmentButton = new RoundedButton("Environment Description");

        // Add action listeners to buttons
        addButtonAction(emergencyButton, "Emergency Call");
        addButtonAction(riskButton, "Risk Detection");
        addButtonAction(navigationButton, "Navigation Guidance");
        addButtonAction(environmentButton, "Environment Description");

        // Add buttons to the panel
        gbc.gridx = 0; gbc.gridy = 0;
        buttonPanel.add(emergencyButton, gbc);
        gbc.gridx = 1; gbc.gridy = 0;
        buttonPanel.add(riskButton, gbc);
        gbc.gridx = 2; gbc.gridy = 0;
        buttonPanel.add(navigationButton, gbc);
        gbc.gridx = 3; gbc.gridy = 0;
        buttonPanel.add(environmentButton, gbc);

        add(buttonPanel, BorderLayout.NORTH);
    }

    private void addButtonAction(JButton button, String label) {
        button.addActionListener(e -> {
            if (controller != null) {
                controller.handleButtonClick(label); // Delegate to the controller
            }
        });
    }

    public void addCommandToQueueView(AudioCommand command) {
        JLabel label = new JLabel(command.toString());
        styleLabel(label, new Color(220, 240, 255)); // Light blue background
        queuePanel.add(label);
        queuePanel.revalidate();
        queuePanel.repaint();
    }

    public void removeCommandFromQueueView(AudioCommand command, boolean isGarbage) {
        for (Component comp : queuePanel.getComponents()) {
            if (comp instanceof JLabel) {
                JLabel label = (JLabel) comp;
                if (label.getText().contains(command.getIdentifier())) {
                    queuePanel.remove(label);
                    if(isGarbage){
                        addCommandToDeletedView(command); // Add to the deleted panel
                    }
                    break;
                }
            }
        }
        queuePanel.revalidate();
        queuePanel.repaint();
    }

    public void addCommandToDeletedView(AudioCommand command) {
        JLabel label = new JLabel(command.toString());
        styleLabel(label, new Color(200, 200, 200)); // Grey background for deleted commands
        deletedPanel.add(label);
        deletedPanel.revalidate();
        deletedPanel.repaint();
    }

    public void updateCommandState(String identifier, boolean isRunning) {
        SwingUtilities.invokeLater(() -> {
            for (Component comp : queuePanel.getComponents()) {
                if (comp instanceof JLabel) {
                    JLabel label = (JLabel) comp;
                    if (label.getText().contains(identifier)) {
                        label.setBackground(isRunning ? new Color(255, 102, 102) : new Color(220, 240, 255)); // Change background based on state
                        label.repaint();
                        break;
                    }
                }
            }
        });
    }

    public void updateMetrics(Map<String, Integer> deletedCommandMetrics, Duration totalWaitingTime, Duration totalQueueFullTime) {
        metricsPanel.removeAll(); // Clear previous metrics
    
        // Set a vertical layout with spacing for better structure
        metricsPanel.setLayout(new BoxLayout(metricsPanel, BoxLayout.Y_AXIS));
    
        // Panel for Deleted Commands Metrics
        JPanel deletedCommandsPanel = new JPanel();
        deletedCommandsPanel.setLayout(new BoxLayout(deletedCommandsPanel, BoxLayout.Y_AXIS));
        deletedCommandsPanel.setBorder(BorderFactory.createTitledBorder("Commands Deleted"));
        
        deletedCommandMetrics.forEach((commandType, count) -> {
            JLabel label = new JLabel("<html>&#8226; " + commandType + ": <b>" + count + "</b></html>");
            label.setFont(new Font("Verdana", Font.PLAIN, 14));
            label.setBackground(new Color(240, 240, 240));
            label.setOpaque(true);
            deletedCommandsPanel.add(label);
        });
    
        // Add the deleted commands panel to the metrics panel
        metricsPanel.add(deletedCommandsPanel);
    
        // Panel for Duration Metrics (Waiting Time & Queue Full Time)
        JPanel durationPanel = new JPanel();
        durationPanel.setLayout(new BoxLayout(durationPanel, BoxLayout.Y_AXIS));
        durationPanel.setBorder(BorderFactory.createTitledBorder("Time Metrics"));
    
        String waitingTimeStr = "Total Waiting Time: <b>" + totalWaitingTime.toMillis() + " ms</b>";
        String fullQueueTimeStr = "Total Queue Full Time: <b>" + totalQueueFullTime.toMillis() + " ms</b>";
    
        JLabel waitingTimeLabel = new JLabel("<html>" + waitingTimeStr + "</html>");
        JLabel fullQueueTimeLabel = new JLabel("<html>" + fullQueueTimeStr + "</html>");
    
        waitingTimeLabel.setFont(new Font("Verdana", Font.PLAIN, 14));
        fullQueueTimeLabel.setFont(new Font("Verdana", Font.PLAIN, 14));
    
        durationPanel.add(waitingTimeLabel);
        durationPanel.add(fullQueueTimeLabel);
    
        // Add the duration panel to the metrics panel
        metricsPanel.add(durationPanel);
    
        // Add some padding for better visual separation
        metricsPanel.add(Box.createVerticalStrut(10));
    
        metricsPanel.revalidate();
        metricsPanel.repaint();
    }
    
    

    private void styleLabel(JLabel label, Color background) {
        label.setOpaque(true);
        label.setBackground(background);
        label.setForeground(Color.BLACK);
        label.setFont(new Font("Verdana", Font.BOLD, 14));
        label.setBorder(new EmptyBorder(5, 10, 5, 10)); // Add padding inside the label
    }

    // Custom RoundedButton class
    private static class RoundedButton extends JButton {
        public RoundedButton(String text) {
            super(text);
            setFont(new Font("Verdana", Font.PLAIN, 14));
            setFocusPainted(false);
            setBackground(new Color(51, 153, 255));
            setForeground(Color.WHITE);
            setBorder(BorderFactory.createEmptyBorder(10, 20, 10, 20));
            setContentAreaFilled(false);
        }

        @Override
        protected void paintComponent(Graphics g) {
            Graphics2D g2 = (Graphics2D) g;
            g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            g2.setColor(getBackground());
            g2.fillRoundRect(0, 0, getWidth(), getHeight(), 20, 20);
            super.paintComponent(g);
        }
    }
}
