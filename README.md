# BVIApplication Simulation

This project simulates the audio output of the guiding system for Blind and Visually Impaired (BVI) individuals called BegIA.

---

## Features

1. **Command Processing:**
   - Commands are classified into four categories:
     - **Emergency Call (EC):** Highest priority.
     - **Risk Detection (RD):** Second-highest priority.
     - **Navigation Guidance (NG):** Moderate priority.
     - **Environment Description (ED):** Lowest priority.
   - Commands are added to a custom priority queue and processed based on their priority.

2. **Text-to-Speech (TTS):**
   - Google Cloud TTS is integrated to read commands aloud.
   - Audio is played using Java's `javax.sound.sampled` API.

3. **Swing-Based UI:**
   - A user-friendly interface to simulate thread activity.
   - Buttons for manually adding commands to the queue.
   - Dynamic display of the queue state, including command details.

4. **Custom Priority Queue:**
   - Implements priority management using synchronisation techniques.
   - Handles concurrent command processing efficiently.

---

## Project Structure

### 1. **Model**
- **`AudioCommand` Class:**
  Represents commands with fields for message, priority, creator thread, unique identifier, enqueue timestamp, and maximum wait time.
- **`CustomPriorityBlockingQueue`:**
  A synchronised priority queue designed for efficient command handling.
- **`BVIModel.java`:**
  Handle project logic by adding commands.

### 2. **View**
- **`BVISwingApp` Class:**
  - Provides the graphical user interface.
  - Displays the queue state and buttons for interaction.

### 3. **Controller**
- **`BVIApplication` Class:**
  - Manages the lifecycle of threads and the priority queue.
  - Connects the model and view to handle user actions and update the UI.
- **`AudioOutputProcessor` Class:**
  - Processes commands from the queue and interacts with Google Cloud TTS.

---

## Requirements

- **Java Development Kit (JDK):** Version 17 or higher.
- **Google Cloud TTS API:** Requires API key and configuration.
- **Swing Library:** Included with standard Java.

---

## How to Run

1. **Setup:**
   - Ensure JDK 17+ is installed.
   - Configure Google Cloud TTS API credentials.

2. **Build:**
   - Compile the project using your preferred IDE or `javac` command.

3. **Run:**
   - Execute the main class `MainApp.java` to launch the simulation.

4. **Interact:**
   - Use the Swing UI to manually add commands.
   - Observe how commands are processed based on priority.

---

## Authors
Developed as part of the **BegIA Project**, focusing on enhancing accessibility for Blind and Visually Impaired individuals.
Oier Arano, Maialen Gallastegi, Beñat Iruretagoyena, Alain Ordoñez

