from ultralytics import YOLO
import cv2
from config import RESIZE_DIM

class MoneyCounter:
    def __init__(self):
        # Initialize YOLO model
        self.model = YOLO("../models/money3.onnx")

    def detect_objects(self, image):
        """
        Track objects in an image using the YOLO model.
        """
        return self.model(source=image, stream=True)

    def read_and_preprocess_image(self, temp_file_path):
        """
        Read and preprocess the uploaded image.
        """
        image = cv2.imread(temp_file_path)
        if image is None:
            raise ValueError("Failed to load the image.")
        return cv2.resize(image, (RESIZE_DIM, RESIZE_DIM))
