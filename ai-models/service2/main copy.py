from fastapi import FastAPI, File, UploadFile, HTTPException
from models import YOLOModel
from distance_calculation import calculate_distance_from_box
from clustering import cluster_obj, generate_output, reload_clusters
from utils import save_uploaded_file, remove_temp_file, read_and_preprocess_image
from pydantic import BaseModel
from image_description import ImageDescriptionModel
from money import MoneyCounter
from PIL import Image
from io import BytesIO
import os
from typing import List, Dict, Optional
import cv2
import math
import numpy as np
from ultralytics import YOLO
from typing import Optional
from uuid import uuid4
from asyncio import Lock
import logging

# FastAPI Instance
app = FastAPI()

session_yolo_models: Dict[str, YOLOModel] = {}
session_tracking_state: Dict[str, Dict[int, Dict]] = {}

# Lock for thread-safe access
session_lock = Lock()

# Initialize YOLO model
money_model = MoneyCounter()
description_model = ImageDescriptionModel()

# Camera Parameters (imported from config.py)
from config import CAMERA_HEIGHT, ANGLE_OF_INCLINATION

# Configure logging
logging.basicConfig(level=logging.INFO)

class SessionResponse(BaseModel):
    session_id: str

# State dictionary to track last known distances of objects
object_last_distances = {}

@app.get("/start-session", response_model=SessionResponse)
async def start_session():
    async with session_lock:
        session_id = str(uuid4())  # Generate a unique session ID
        logging.info(f"Creating new session: {session_id}")
        session_tracking_state[session_id] = {}  # Initialise tracking state for this session
        session_yolo_models[session_id] = YOLOModel()  # Create a new YOLO instance for this session
    logging.info(f"Session created successfully: {session_id}")
    return {"session_id": session_id}

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

@app.post("/detect")
async def process_local_image(session_id: str, file: UploadFile = File(...)):
    """
    Process an uploaded image and track objects across frames.
    """
    global object_last_distances
    reload_clusters()
    try:
        # Check if the session exists
        if session_id not in session_yolo_models:
            raise HTTPException(status_code=404, detail="Session ID not found.")

        # Save the uploaded file temporarily
        temp_file_path = save_uploaded_file(file)

        model = session_yolo_models[session_id]
        tracking_state = get_session_state(session_id)
        detected_objects = []
        current_frame_ids = set()

        # Read and preprocess the image
        image = read_and_preprocess_image(temp_file_path)
        original_height, original_width = image.shape[:2]

        results = model.track_objects(image)

        for result in results:
            for box in result.boxes:
                x1, y1, x2, y2 = box.xyxy[0].tolist()
                conf = box.conf[0].item()
                cls =  int(box.cls[0].item())  # Class index
                track_id = int(box.id[0].item()) if box.id is not None else -1  # Track ID
                # if conf < 0.3:
                #     continue
                print("Track_id", track_id)
                current_frame_ids.add(track_id)
                bbox_height = y2 - y1
                label = result.names[cls]

                distance = calculate_distance_from_box(
                    CAMERA_HEIGHT, ANGLE_OF_INCLINATION, bbox_height, original_height
                )

                side = model.get_object_direction(original_width, box)

                if track_id in object_last_distances:
                    last_distance = object_last_distances[track_id]
                    if distance is not None and (last_distance is None or distance < last_distance):
                        object_last_distances[track_id] = distance
                        detected_objects.append({
                            "id": track_id,
                            "label": label,
                            "confidence": conf,
                            "bbox": [x1, y1, x2, y2],
                            "distance": round(distance),
                            "side": side
                        })
                else:
                    object_last_distances[track_id] = distance
                    detected_objects.append({
                        "id": track_id,
                        "label": label,
                        "confidence": conf,
                        "bbox": [x1, y1, x2, y2],
                        "distance": round(distance),
                        "side": side
                    })

                cluster_obj({
                    "x1": x1,
                    "y1": y1,
                    "x2": x2,
                    "y2": y2,
                    "label": label,
                    "distance": round(distance),
                    "side": side,
                    "id": track_id
                })

        for track_id in list(tracking_state.keys()):
            if track_id not in current_frame_ids:
                del tracking_state[track_id]

        # Cleanup stale entries
        # object_last_distances = {k: v for k, v in object_last_distances.items() if k in current_frame_ids}

        # Cleanup temporary file
        remove_temp_file(temp_file_path)

        # Generate descriptive phrases
        phrases = generate_output(detected_objects)
        return {"message": phrases}

    except Exception as e:
        return {"error": f"An error occurred: {str(e)}"}
    
def get_session_state(session_id: str):
    """
    Retrieve the session tracking state for the given session ID.
    """
    if session_id not in session_tracking_state:
        raise HTTPException(status_code=404, detail="Session ID not found.")
    return session_tracking_state[session_id]


@app.post("/describe")
async def describe_image(file: UploadFile = File(...)):  # Cambiamos 'image' por 'file'
    try:
        # Leer los datos del archivo
                
        # Convertir a un objeto PIL
        file_data = await file.read()
        img = Image.open(BytesIO(file_data)).convert("RGB")
        generated_text = description_model.describe(img)
        
        return {"message": generated_text}
    except Exception as e:
        return {"error": str(e)}

@app.post("/money")
async def count_money(file: UploadFile = File(...)):  # Cambiamos 'image' por 'file'
    try:
        # Save the uploaded file temporarily
        temp_file_path = save_uploaded_file(file)

        # Read and preprocess the image
        image = money_model.read_and_preprocess_image(temp_file_path)
        original_height, original_width = image.shape[:2]

        # Use YOLO's tracking system
        results = money_model.detect_objects(image)
        amount = ""
        for result in results:
            for obj in result.boxes.data.tolist():
                _,_,_,_, conf, cls = obj
                class_name = result.names[int(cls)]
                if(conf >= 0.8):
                    if(class_name == "100eur"):
                        amount = "100€"
                    elif(class_name == "50eur"):
                        amount = "50€"
                    elif(class_name == "20eur"):
                        amount = "20€"
                    elif(class_name == "10eur"):
                        amount = "10€"
                    elif(class_name == "5eur"):
                        amount = "5€"

        # Cleanup temporary file
        remove_temp_file(temp_file_path)
        return {"message": f"{amount}"}
    except Exception as e:
        return {"error": str(e)}