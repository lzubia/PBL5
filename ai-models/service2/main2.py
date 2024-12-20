from fastapi import FastAPI, File, UploadFile, HTTPException, Depends
from typing import List, Dict, Optional
from pydantic import BaseModel
import cv2
import os
import math
import numpy as np
from ultralytics import YOLO
from typing import Optional
from uuid import uuid4
from asyncio import Lock
import logging

# YOLO Model
model = YOLO("yolov8s.pt")

# FastAPI Instance
app = FastAPI()

# Camera Parameters
CAMERA_HEIGHT = 1.5  # In meters
SENSOR_HEIGHT_MM = 4.8  # Sensor height in mm
FOCAL_LENGTH_MM = 4.35  # Focal length in mm
ANGLE_OF_INCLINATION = 12  # In degrees
RESIZE_DIM = 640  # Image resize dimensions
LEFT_BOUNDARY = 0.4  # Fraction of image width for "left"
RIGHT_BOUNDARY = 0.6  # Fraction of image width for "right"

# Precompute Vertical Field of View
FOV_VERTICAL = 2 * math.atan((SENSOR_HEIGHT_MM / 2) / FOCAL_LENGTH_MM)

# Global session data
session_yolo_models: Dict[str, YOLO] = {}
session_tracking_state: Dict[str, Dict[int, Dict]] = {}

# Lock for thread-safe access
session_lock = Lock()

# Configure logging
logging.basicConfig(level=logging.INFO)

class SessionResponse(BaseModel):
    session_id: str

def generate_output(detected_objects: List[Dict]) -> List[str]:
    phrases = []
    for obj in detected_objects:
        obj_id = obj['id']
        if obj['distance'] < 0.5:
            phrases.append(f"{obj['label']} very close {obj['side']}!")
        else:
            phrases.append(f"{obj['label']} at {obj['distance']} meters {obj['side']}.")
    return phrases

def get_session_state(session_id: str):
    """
    Retrieve the session tracking state for the given session ID.
    """
    if session_id not in session_tracking_state:
        raise HTTPException(status_code=404, detail="Session ID not found.")
    return session_tracking_state[session_id]

@app.get("/start-session", response_model=SessionResponse)
async def start_session():
    async with session_lock:
        session_id = str(uuid4())  # Generate a unique session ID
        logging.info(f"Creating new session: {session_id}")
        session_tracking_state[session_id] = {}  # Initialise tracking state for this session
        session_yolo_models[session_id] = YOLO("yolov8s.pt")  # Create a new YOLO instance for this session
    logging.info(f"Session created successfully: {session_id}")
    return {"session_id": session_id}

@app.post("/detect")
async def process_local_image(session_id: str, file: UploadFile = File(...)):
    """
    Process an uploaded image and track objects for the specified session.
    """
    try:
        # Check if the session exists
        if session_id not in session_yolo_models:
            raise HTTPException(status_code=404, detail="Session ID not found.")
        
        model = session_yolo_models[session_id]
        tracking_state = get_session_state(session_id)
        detected_objects = []
        current_frame_ids = set()

        temp_file_path = f"./temp_{file.filename}"
        with open(temp_file_path, "wb") as buffer:
            buffer.write(await file.read())

        image = cv2.imread(temp_file_path)
        if image is None:
            raise ValueError("Failed to load the image.")

        image = cv2.resize(image, (RESIZE_DIM, RESIZE_DIM))
        original_height, original_width = image.shape[:2]

        results = model.track(source=image, stream=True, persist=True)
        center_range = (original_width * LEFT_BOUNDARY, original_width * RIGHT_BOUNDARY)

        for result in results:
            for box in result.boxes:
                x1, y1, x2, y2 = box.xyxy[0].tolist()
                conf = box.conf[0].item()
                cls = int(box.cls[0].item())
                track_id = int(box.id[0].item()) if box.id is not None else -1

                current_frame_ids.add(track_id)
                bbox_height = y2 - y1
                label = result.names[cls]

                distance = CAMERA_HEIGHT / math.tan(math.radians(bbox_height + ANGLE_OF_INCLINATION))
                side = "left" if (x1 + x2) / 2 < center_range[0] else "right" if (x1 + x2) / 2 > center_range[1] else "in front"

                detected_objects.append({
                    "id": track_id,
                    "label": label,
                    "confidence": conf,
                    "bbox": [x1, y1, x2, y2],
                    "distance": distance,
                    "side": side,
                })

        for track_id in list(tracking_state.keys()):
            if track_id not in current_frame_ids:
                del tracking_state[track_id]

        os.remove(temp_file_path)
        phrases = generate_output(detected_objects)
        return {"session_id": session_id, "message": phrases, "tracked_objects": detected_objects}

    except Exception as e:
        return {"error": f"An error occurred: {str(e)}"}

@app.delete("/end-session")
async def end_session(session_id: str):
    async with session_lock:
        if session_id in session_tracking_state:
            del session_tracking_state[session_id]
            if session_id in session_yolo_models:
                del session_yolo_models[session_id]
            logging.info(f"Session {session_id} ended.")
            return {"message": f"Session {session_id} ended and tracking state cleared."}
        else:
            raise HTTPException(status_code=404, detail="Session ID not found.")