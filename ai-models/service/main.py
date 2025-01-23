from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi import FastAPI, File, UploadFile, HTTPException
from models import YOLOModel
from distance_calculation import calculate_distance_from_box
from clustering import cluster_obj, generate_output, reload_clusters
from utils import save_uploaded_file, remove_temp_file, read_and_preprocess_image
from pydantic import BaseModel
from image_description import ImageDescriptionModel
from ocr import OCR_Model
from money import MoneyCounter
from PIL import Image
from io import BytesIO
from uuid import uuid4
from asyncio import Lock
import logging 
from fastapi import Request
from typing import List, Dict

# FastAPI Instance
app = FastAPI()

# Yolo session Dictionaries
session_yolo_models: Dict[str, YOLOModel] = {}
session_tracking_state: Dict[str, Dict[int, Dict]] = {}
object_last_distances: Dict[str, List[float]] = {}

# Constants
TOTAL_SERVICES = 7  # Total number of services expected (adjust as needed)

# Tracking Services State (adjust as needed)
services_state = {
    "list_services": {"id": 0, "enabled": True if app.get("services") else False }, # This must be always enabled
    "start_session": {"id": 1, "enabled": True if app.get("start-session") else False},
    "end_session": {"id": 2, "enabled": True if app.get("end-session") else False},
    "detect_objects": {"id": 3, "enabled": True if app.get("detect") else False},
    "describe_image": {"id": 4, "enabled": True if app.get("describe") else False},
    "count_money": {"id": 5, "enabled": True if app.get("moeney") else False},
    "perform_ocr": {"id": 6, "enabled": True if app.get("ocr") else False},
}

# Strings
Session_ID_Error_String = "Session ID not found."

# Lock for thread-safe access
session_lock = Lock()

# Initialize OCR
ocr_model = OCR_Model()

# Initialize Models
money_model = MoneyCounter()
description_model = ImageDescriptionModel()

# Camera Parameters (imported from config.py)
from config import CAMERA_HEIGHT, ANGLE_OF_INCLINATION

# Configure logging info
logging.basicConfig(level=logging.INFO)

# Create class for Session Response
class SessionResponse(BaseModel):
    session_id: str

# Debugging middleware (should be deleted for deploy)
@app.middleware("http")
async def inspect_request(request: Request, call_next):
    headers = dict(request.headers)
    body = await request.body()
    print(f"Headers: {headers}")
    print(f"Body: {body[:500]}")  # Solo muestra los primeros 500 bytes
    response = await call_next(request)
    return response

# Mount static dir
app.mount("/static", StaticFiles(directory="static"), name="static")

# Web services
@app.get("/", response_class=HTMLResponse)
async def read_root():
    with open("./index.html", "r", encoding="utf-8") as file:
        html_content = file.read()
    return HTMLResponse(content=html_content, status_code=200)
# Services
@app.get("/services", response_model=List[dict], summary="Gets all the created endpoints available")
async def list_services():
    """
    Dynamically list all available services (endpoints) in the FastAPI app.
    """
    routes = []
    available_routes = {route.name: route for route in app.routes if hasattr(route, "path")}

    # Track IDs that are included
    included_ids = set()

    for name, service_info in services_state.items():
        service_id = service_info["id"]
        enabled = service_info.get("enabled", True)

        if name in available_routes and enabled:
            route = available_routes[name]
            routes.append({
                "id": service_id,
                "path": route.path,
                "methods": list(route.methods - {"HEAD", "OPTIONS"}),  # Exclude default methods
                "name": route.name,
                "summary": getattr(route, "summary", None),
                "enabled": enabled
            })
        else:
            # If the service is not in available_routes or disabled
            routes.append({
                "id": service_id,
                "enabled": False
            })

        # Add this service ID to the included set
        included_ids.add(service_id)

    # Check for missing IDs
    for service_id in range(0, TOTAL_SERVICES):
        if service_id not in included_ids:
            # Add missing service with 'enabled: false'
            routes.append({
                "id": service_id,
                "enabled": False
            })

    # Sort services by ID before returning
    routes = sorted(routes, key=lambda x: x["id"])

    return routes
# Start Session
@app.get("/start-session", response_model=SessionResponse, summary="This service returns an unique-id to start the session and use other services")
async def start_session():
    """
    Starts session giving an unique-id to use other services.
    """
    async with session_lock:
        session_id = str(uuid4())  # Generate a unique session ID
        logging.info(f"Creating new session: {session_id}")
        session_tracking_state[session_id] = {}  # Initialise tracking state for this session
        session_yolo_models[session_id] = YOLOModel()  # Create a new YOLO instance for this session
        object_last_distances[session_id] = {}  # Create a new YOLO instance for this session

    logging.info(f"Session created successfully: {session_id}")
    logging.info(f"List of sessions: {session_yolo_models}")
    return {"session_id": session_id}
# End Session
@app.delete("/end-session", summary="Ends a session if the user has started one")
async def end_session(session_id: str):
    """
    Ends the open session, if applicable.
    """
    async with session_lock:
        if session_id in session_tracking_state:
            del session_tracking_state[session_id]
            if session_id in session_yolo_models:
                del session_yolo_models[session_id]
            logging.info(f"Session {session_id} ended.")
            logging.info(f"List of sessions: {session_yolo_models}")
            phrase = {"message": f"Session {session_id} ended and tracking state cleared."}
            return {"results": phrase}
        else:
            raise HTTPException(status_code=404, detail=Session_ID_Error_String)
# Detect
@app.post("/detect", summary="Processes and return detected objects from the given image")
async def detect_objects(session_id: str, file: UploadFile = File(...)):
    """
    Process an uploaded image and track objects across frames.
    """
    reload_clusters()
    try:
        
        if session_id not in session_yolo_models:
            raise HTTPException(status_code=404, detail=Session_ID_Error_String)

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
                if(label == "airplane"):
                    label = "chair"

                distance = calculate_distance_from_box(
                    CAMERA_HEIGHT, ANGLE_OF_INCLINATION, bbox_height, original_height
                )

                side = model.get_object_direction(original_width, box)

                model_last_distances = object_last_distances[session_id]
                if track_id in model_last_distances:
                    last_distance = model_last_distances[track_id]
                    if distance is not None and (last_distance is None or distance < last_distance):
                        model_last_distances[track_id] = distance
                        detected_objects.append({
                            "id": track_id,
                            "label": label,
                            "confidence": conf,
                            "bbox": [x1, y1, x2, y2],
                            "distance": round(distance),
                            "side": side
                        })
                else:
                    model_last_distances[track_id] = distance
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
        # model_last_distances = {k: v for k, v in model_last_distances.items() if k in current_frame_ids}

        # Cleanup temporary file
        remove_temp_file(temp_file_path)

        # Generate descriptive phrases
        phrases = generate_output(detected_objects)
        return {"results": phrases}

    except Exception as e:
        return {"error": f"An error occurred: {str(e)}"}
# Get session state for tracking with ID
def get_session_state(session_id: str):
    """
    Retrieve the session tracking state for the given session ID.
    """
    if session_id not in session_tracking_state:
        raise HTTPException(status_code=404, detail=Session_ID_Error_String)
    return session_tracking_state[session_id]
# Describe
@app.post("/describe", summary="Processes and return a description of the given image")
async def describe_image(session_id: str, file: UploadFile = File(...)):
    """
    Process and return a description of an image.
    """
    try:
        # Check if the session exists
        if session_id not in session_yolo_models:
            raise HTTPException(status_code=404, detail=Session_ID_Error_String)
        # Convertir a un objeto PIL
        file_data = await file.read()
        if not file_data:
            raise HTTPException(status_code=400, detail="El archivo subido está vacío.")
        img = Image.open(BytesIO(file_data)).convert("RGB")
        generated_text = description_model.describe(img)
        phrase = {"message": generated_text}
        return {"results": phrase}
    except Exception as e:
        return {"error": str(e)}
# Money
@app.post("/money", summary="Processes and return detected money objects from the given image")
async def count_money(session_id: str, file: UploadFile = File(...)):
    """
    Process and returns the money item that is detected.
    """
    try:
        # Check if the session exists
        if session_id not in session_yolo_models:
            raise HTTPException(status_code=404, detail=Session_ID_Error_String)

        # Save the uploaded file temporarily
        temp_file_path = save_uploaded_file(file)

        # Read and preprocess the image
        image = money_model.read_and_preprocess_image(temp_file_path)

        # Use YOLO's tracking system
        results = money_model.detect_objects(image)
        amount = ""
        for result in results:
            for obj in result.boxes.data.tolist():
                _,_,_,_, conf, cls = obj
                class_name = result.names[int(cls)]
                if(conf >= 0.75):
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
        # Generate descriptive phrases
        phrases = {"message": amount} 
        return {"results": phrases}
    except Exception as e:
        return {"error": str(e)}
# OCR
@app.post("/ocr", summary="Process and return detected text from given image")
async def perform_ocr(session_id: str, file: UploadFile = File(...)):
    """
    Process and returns the detected text in the image.
    """
    try:
        # Check if the session exists
        if session_id not in session_yolo_models:
            raise HTTPException(status_code=404, detail=Session_ID_Error_String)

        # Execute the OCR process
        output_text = ocr_model.execute_ocr(file)
        
        # Construct response
        object_text = {"message": output_text}
        return {"results": object_text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing the image: {str(e)}")