import math
from config import FOV_VERTICAL
from typing import Optional

def calculate_distance_from_box(camera_height: float, angle_of_inclination: float,
                                bbox_height: float, image_height: int) -> Optional[float]:
    """
    Calculate distance to an object based on bounding box height.
    """
    bbox_fraction = bbox_height / image_height
    angle_per_pixel = math.degrees(FOV_VERTICAL) / image_height
    object_angle = bbox_fraction * angle_per_pixel * image_height
    return camera_height / math.tan(math.radians(object_angle + angle_of_inclination)) if object_angle != 0 else None
