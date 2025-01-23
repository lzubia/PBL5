# AI Models

This repository project contains various AI models and a web service to use them, each model tailored for specific tasks or varying version. The models achieve object detection, tracking and clustering. The repository is modular, with each model having its own set of training, configurations, and tuning.

## Repository Structure/Overview
- ./models: All the AI models that are used or that can be used.
- ./service: An improved object detection service, based on the latests models in the models directory, providing object detection, tracking and clustering.

---

## `models`: YOLO based Ai Models

1. **yolo_detect1.pt** - Custom model trained from [risk-detection dataset](https://universe.roboflow.com/pbl5mu/risk-detection-1/dataset/1) for object detection.
2. **yolo_detect2.pt** - Custom model trained from [risk-detection dataset](https://universe.roboflow.com/pbl5mu/risk-detection-1/dataset/2) for object detection.
3. **money3.pt** - Custom model trained from [money-reader dataset](https://universe.roboflow.com/pbl5mu/money-reader/dataset/3) for object detection.
4. **yolov8n.pt** - Pre-trained YOLOv8 model (nano scale), trained on the COCO dataset for object detection.
5. **yolov8s.pt** - Pre-trained YOLOv8 model (small scale), trained on the COCO dataset for object detection.

## `service`: YOLO Object Detection

### What is YOLO?
YOLO (You Only Look Once) is a state-of-the-art real-time object detection algorithm. It is widely used for tasks like object detection in images and videos due to its speed and accuracy.

### Model Details
This model leverages the **YOLOv11** implementation provided by [Ultralytics](https://ultralytics.com). Depending on the model it is pre-trained with **COCO dataset** or with a custome dataset **Risk-detection dataset**, which contains 5 classes of indoors objects (chair, door, people, table, trashbin). The trained weights and configuration were changed based on the original to fit better with the datasets.

### Files in `service/`
- **`main.py`**: The FastAPI main file.

### Setup and Usage

1. **Create a virtual environment** (optional but recommended):
    - For **Windows**:
        ```bash
        python -m venv venv
        venv\Scripts\activate
        ```
    - For **macOS/Linux**:
        ```bash
        python3 -m venv venv
        source venv/bin/activate
        ```

2. **Install dependencies from `requirements.txt`**:
    ```bash
    pip install -r requirements.txt
    ```

    Additionally, the Tesseract OCR set up must be installed on the device running the web service.
    - **Windows**:  
        Download and install Tesseract OCR from the official page: [Tesseract OCR for Windows](https://github.com/UB-Mannheim/tesseract/wiki). Follow the installation steps provided in the link.
    - **macOS/Linux**:  
        Use your system's package manager to install Tesseract OCR. For example:
        - **macOS**:  
            ```bash
            brew install tesseract
            ```
        - **Linux**:  
            ```bash
            sudo apt update
            sudo apt install tesseract-ocr
            ```

    Make sure Tesseract is properly added to your system's `PATH` so it can be accessed by the web service.

3. **Run the following command to start the service**:
    ```bash
    uvicorn main:app --host 0.0.0.0 --port 8000 --reload
    ```
    > **Note:** The running parameters can be changed, this is a standard example to execute the web service.
    >           To deploy with HTTPS, ssl_keyfile and ssl_certfile files needs to be added.

If the steps were followed the service will start and response on localhost:8000/*
- **`/detect`**: tracking, clustering and detecting objects, giving instructions to guide, from a given images.
- **`/describe`**: describe the image that is sent.
- **`/money`**: detect and clasify bills (only €).

### Extended usages and information:

AI Models and a proper setup of them, view the original quickstart documentation in [Ultralytics](https://docs.ultralytics.com/quickstart/).

Web service setup and extended explanation, view the manual deployment documentation in [FastAPI](https://fastapi.tiangolo.com/deployment/manually/).

---