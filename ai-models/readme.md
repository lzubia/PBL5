# AI Models

This repository project contains various AI models organized into subdirectories, each tailored for specific tasks. The models achieve object detection, classification, tracking and clustering. The repository is modular, with each model having its own set of training, configurations, and tuning.

## Repository Structure/Overview
- ./models: All the AI models that are used or that can be used.
- ./service1/**: A ai based object detection model, pre-trained on the COCO dataset, that uses yolov8.
- ./service2/**: Folowing services...

Each subdirectory contains a specific intructions or usage if aplicable, or standar instructions are used.

---

## `service1`: YOLO Object Detection

### What is YOLO?
YOLO (You Only Look Once) is a state-of-the-art real-time object detection algorithm. It is widely used for tasks like object detection in images and videos due to its speed and accuracy.

### Model Details
This model leverages the **YOLOv8** implementation provided by [Ultralytics](https://ultralytics.com). It is pre-trained with the **COCO dataset**, which contains 80 classes of common objects (e.g., cars, people, animals). The trained weights and configuration were not changed.

### Files in `service1/`
- **`main.py`**: The FastAPI main file.

### Setup and Usage
Install all the dependecies and run the following command:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```
Now you have a web service that response on localhost:8000/*
- **`/detect`**: tracking, clustering and detecting objects, giving instructions to guide, from a given images.
- **`/describe`**: describe the image that is sent.
- **`/money`**: detect and clasify bills (only €).

For more extended usages and a proper setup view the original quickstart documentation in [Ultralytics](https://docs.ultralytics.com/quickstart/).