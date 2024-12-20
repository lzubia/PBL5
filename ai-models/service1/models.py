from ultralytics import YOLO
import cv2
from config import RESIZE_DIM

class YOLOModel:
    def __init__(self):
        # Initialize YOLO model
        self.model = YOLO("../models/yolov8n.pt")

    def track_objects(self, image):
        """
        Track objects in an image using the YOLO model.
        """
        return self.model.track(source=image, stream=True, persist=True)

    def read_and_preprocess_image(self, temp_file_path):
        """
        Read and preprocess the uploaded image.
        """
        image = cv2.imread(temp_file_path)
        if image is None:
            raise ValueError("Failed to load the image.")
        return cv2.resize(image, (RESIZE_DIM, RESIZE_DIM))

    def get_object_direction(self, image_width, box):
        """
        Determine the direction of the object relative to the camera.
        """
        center_range = (image_width * 0.4, image_width * 0.6)
        x1, y1, x2, y2 = box.xyxy[0].tolist()  # Get box coordinates
        box_center = (x1 + x2) / 2
        if box_center < center_range[0]:
            return "left"
        elif box_center > center_range[1]:
            return "right"
        else:
            return "in front"
