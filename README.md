# BegIA Project
BegIA is a guiding system designed to assist Blind and Visually Impaired (BVI) individuals. The system leverages various AI models, mobile app interfaces, and simulations to provide real-time environment descriptions, risk detection, and enhanced navigation features. This repository contains different components necessary for the development and integration of these features.

## Project Structure
The project is divided into the following main folders:

### 1. ai-models
Contains all AI models used for various tasks within the system, including object detection, environment description, text recognition, and any other machine learning models for BVI assistance.

Blip-2: Transformer-based model for generating natural language descriptions of captured scenes (used for Environment Description feature).
Tesseract OCR: Optical Character Recognition model for text recognition from images (used for reading printed or handwritten text).
### 2. mobile-app
Contains the Flutter application used for the BVI guiding system. The app provides an interface for the users to interact with the system and provides real-time voice commands, alerts, and navigation guidance.

Flutter version: 3.24.5
Core features:
Real-time navigation and risk detection
Voice interaction for BVI individuals
Product recognition (for use in stores or at home)
Weather adaptation for safe navigation
3. shared-resources
This folder contains shared resources, such as assets, scripts, and configurations, that are used across the project components. It ensures consistency between the mobile app and AI models.

### 4. simulation
Contains simulation tools for testing different features of the guiding system. This includes simulations for audio output, queue management for voice commands, and testing the AI models' real-time performance under various conditions.

## Features
- **Risk Detection**: The system detects obstacles and hazards in the user's path and provides timely alerts.
- **Navigation Guidance**: Helps BVI individuals navigate from point A to point B using voice-guided directions.
- **Environment Description**: The system uses AI to describe the environment around the user, such as nearby objects, people, and obstacles.
- **Text Recognition**: Using Tesseract OCR, the app reads printed or handwritten text, helping the user identify items, signs, or documents.
- **Customisable Voice Commands**: Users can customise voice commands for a more personalised experience.
- **Weather Adaptation**: Adjusts the guidance and risk detection based on weather conditions (e.g., slippery surfaces during rain).
- **Product Recognition**: Recognises common products, allowing the user to identify items in stores or at home.
