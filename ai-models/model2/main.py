from fastapi import FastAPI, File, UploadFile
from models import YOLOModel
from distance_calculation import calculate_distance_from_box
from clustering import cluster_obj, generate_output, reload_clusters
from utils import save_uploaded_file, remove_temp_file
import os

# FastAPI Instance
app = FastAPI()

# Initialize YOLO model
model = YOLOModel()

# Camera Parameters (imported from config.py)
from config import CAMERA_HEIGHT, ANGLE_OF_INCLINATION, RESIZE_DIM

# State dictionary to track last known distances of objects
object_last_distances = {}

@app.post("/track")
async def process_local_image(file: UploadFile = File(...)):
    """
    Process an uploaded image and track objects across frames.
    """
    global object_last_distances
    reload_clusters()
    try:
        # Save the uploaded file temporarily
        temp_file_path = save_uploaded_file(file)

        # Read and preprocess the image
        image = model.read_and_preprocess_image(temp_file_path)
        original_height, original_width = image.shape[:2]

        # Use YOLO's tracking system
        results = model.track_objects(image)
        detected_objects = []
        current_frame_ids = set()

        for result in results:
            for box in result.boxes:
                x1, y1, x2, y2 = box.xyxy[0].tolist()
                conf = box.conf[0].item()
                cls =  int(box.cls[0].item())  # Class index
                track_id = int(
                    box.id[0].item()) if box.id is not None else -1  # Track ID
                if conf < 0.3:
                    continue
                
                current_frame_ids.add(track_id)
    
                bbox_height = y2 - y1

                distance = calculate_distance_from_box(
                    CAMERA_HEIGHT, ANGLE_OF_INCLINATION, bbox_height, original_height
                )

                label = result.names[cls]
                
                direction = model.get_object_direction(original_width, box)

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
                            "side": direction
                        })
                else:
                    object_last_distances[track_id] = distance
                    detected_objects.append({
                        "id": track_id,
                        "label": label,
                        "confidence": conf,
                        "bbox": [x1, y1, x2, y2],
                        "distance": round(distance),
                        "side": direction
                    })

                cluster_obj({
                    "x1": x1,
                    "y1": y1,
                    "x2": x2,
                    "y2": y2,
                    "label": label,
                    "distance": round(distance),
                    "side": direction,
                    "id": track_id
                })

        # Cleanup stale entries
        object_last_distances = {k: v for k, v in object_last_distances.items() if k in current_frame_ids}

        # Cleanup temporary file
        remove_temp_file(temp_file_path)

        # Generate descriptive phrases
        phrases = generate_output(detected_objects)
        return {"message": phrases}

    except Exception as e:
        return {"error": f"An error occurred: {str(e)}"}
