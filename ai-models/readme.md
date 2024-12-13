# AI Models

This repository project contains various AI models organized into subdirectories, each tailored for specific tasks. The models achieve object detection, classification, tracking and clustering. The repository is modular, with each model having its own set of training, configurations, and tuning.

## Repository Structure/Overview
- ./model1/**: A yolov11 based object detection model, pre-trained on the COCO dataset. Within the original arquitecture and trained model.
- ./model2/**: Folowing models...

Each subdirectory contains a specific intructions or usage if aplicable, or standar instructions are used.

---

## `model1`: YOLO Object Detection

### What is YOLO?
YOLO (You Only Look Once) is a state-of-the-art real-time object detection algorithm. It is widely used for tasks like object detection in images and videos due to its speed and accuracy.

### Model Details
This model leverages the **YOLOv11** implementation provided by [Ultralytics](https://ultralytics.com). It is pre-trained on the **COCO dataset**, which contains 80 classes of common objects (e.g., cars, people, animals). The trained weights and configuration files are included for immediate use.

### Files in `model1/`
- **`yolo11n.pt`**: Pre-trained weights file, provided by Ultralytics.
- **`yolo11n.yaml`**: Configuration file defining the model's architecture and training settings.

### Setup and Usage
To use this model from scratch or pretrained model:

```python
from ultralytics import YOLO

# Create a new YOLO model from scratch
model = YOLO("yolo11n.yaml")

# Load a pretrained YOLO model (recommended for training)
model = YOLO("yolo11n.pt")

# Perform object detection on an example image using the model
results = model("https://ultralytics.com/images/bus.jpg")

```

For more extended usages and a proper setup view the original quickstart documentation in [Ultralytics](https://docs.ultralytics.com/quickstart/).