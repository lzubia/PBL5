import math

CAMERA_HEIGHT = 1.5  # In meters
SENSOR_HEIGHT_MM = 4.8  # Sensor height in mm
FOCAL_LENGTH_MM = 4.35  # Focal length in mm
ANGLE_OF_INCLINATION = 12  # In degrees
RESIZE_DIM = 640  # Image resize dimensions
LEFT_BOUNDARY = 0.4  # Fraction of image width for "left"
RIGHT_BOUNDARY = 0.6  # Fraction of image width for "right"

FOV_VERTICAL = 2 * math.atan((SENSOR_HEIGHT_MM / 2) / FOCAL_LENGTH_MM)