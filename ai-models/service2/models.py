from ultralytics import YOLO
from fastapi import HTTPException
from typing import List, Dict, Optional
from asyncio import Lock

class YOLOModel:
    def __init__(self):
        # Initialize YOLO model
        self.model = YOLO("../models/yolo_detect2.pt")

    def track_objects(self, image):
        """
        Track objects in an image using the YOLO model.
        """
        return self.model.track(source=image, stream=True, persist=True)

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
