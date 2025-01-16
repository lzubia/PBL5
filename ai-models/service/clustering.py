import numpy as np
from typing import List, Dict

# Global dictionary to store clusters
clusters = {}

grouping_classes = {"car", "tree", "barrier", "safety-barrier", "table", "chair", "person", "People"}

def cluster_obj(obj):
    if obj['label'] in grouping_classes:
        get_cluster(obj)

def get_cluster(obj):
    """
    Get the cluster the object belongs to or create a new one.
    Also determines the direction of the cluster.
    """
    min_distance = float("inf")
    closest_group = None

    # Check if the object is in an existing cluster or create a new one
    for label, group in clusters.items():
        if label == obj['label']:
            distance = get_distance(obj, group)
            if distance < min_distance:
                min_distance = distance
                closest_group = group
    # Create a new cluster or add to the existing one
    if closest_group is not None:
        closest_group.append(obj)
    else:
        clusters[obj['label']] = [obj]
    # Assign direction to the cluster based on its members
    determine_cluster_direction(closest_group or [obj])

def determine_cluster_direction(group):
    """
    Determines the direction of the cluster based on the directions of its members.
    This function is optimized to handle groups more efficiently.
    """
    directions = {"left": 0, "right": 0, "in front": 0}
    
    # Count directions for the group
    for obj in group:
        directions[obj['side']] += 1
    
    # Assign the cluster's direction based on the majority
    if directions["in front"] > 0:
        cluster_direction = "in front"
    elif directions["left"] > 0 and directions["right"] > 0:
        cluster_direction = "in front"
    elif directions["left"] > 0:
        cluster_direction = "left"
    elif directions["right"] > 0:
        cluster_direction = "right"
    else:
        cluster_direction = "in front"  # Default case if no direction is found
    
    # Assign direction to all objects in the cluster
    for obj in group:
        obj['cluster_direction'] = cluster_direction

def get_distance(obj, group, iou_threshold=0.1, distance_threshold=20):
    """
    Optimized function to calculate the distance between an object and a group of objects.
    If bounding boxes overlap or are close, return a low distance.
    """
    obj_bbox = np.array([obj['x1'], obj['y1'], obj['x2'], obj['y2']])
    min_distance = float("inf")

    # Calculate the distance only if bounding boxes don't overlap (IOU threshold check)
    for group_obj in group:
        group_bbox = np.array([group_obj['x1'], group_obj['y1'], group_obj['x2'], group_obj['y2']])
        
        # Intersection over Union (IoU) check
        if calculate_iou(obj_bbox, group_bbox) > iou_threshold:
            return 0  # No need to calculate distance if IOU is high

        # Compute Euclidean distance between the centers of the objects
        obj_center = np.array([(obj_bbox[0] + obj_bbox[2]) / 2, (obj_bbox[1] + obj_bbox[3]) / 2])
        group_center = np.array([(group_bbox[0] + group_bbox[2]) / 2, (group_bbox[1] + group_bbox[3]) / 2])
        distance = np.linalg.norm(obj_center - group_center)
        min_distance = min(min_distance, distance)

    return min_distance if min_distance < distance_threshold else float("inf")

def calculate_iou(bbox1, bbox2):
    """
    Optimized IOU calculation for bounding boxes.
    """
    x1, y1, x2, y2 = np.maximum(bbox1[:4], bbox2[:4])
    x2, y2 = np.minimum(bbox1[2:], bbox2[2:])
    
    # Calculate the intersection area
    inter_area = max(0, x2 - x1) * max(0, y2 - y1)
    if inter_area == 0:
        return 0

    # Calculate the union area
    bbox1_area = (bbox1[2] - bbox1[0]) * (bbox1[3] - bbox1[1])
    bbox2_area = (bbox2[2] - bbox2[0]) * (bbox2[3] - bbox2[1])
    union_area = bbox1_area + bbox2_area - inter_area

    return inter_area / union_area

def generate_output(detected_objects: List[Dict]) -> List[str]:
    """
    Generate descriptive phrases for detected objects, ensuring no duplicates.
    - If an object belongs to a group, only the group is mentioned.
    - Individual objects are described only if they are not in a group.
    """
    phrases = []
    
    # Cache grouped object IDs for faster lookup
    clustered_ids = {obj['id'] for group in clusters.values() for obj in group}

    # Process clusters
    for label, group in clusters.items():
        cluster_direction = group[0].get('cluster_direction', 'in front')  # Get the direction of the cluster
        count = len(group)

        if count > 1:
            phrases.append(f"A group of {label}s detected, located {cluster_direction}.")
        else:
            obj = group[0]
            if obj['distance'] == -1:
                phrases.append(f"{label} very close!")
            else:
                phrases.append(f"{label} at {obj['distance']} meters {cluster_direction}.")

    # Process individual objects that are not part of any cluster
    for obj in detected_objects:
        if obj["id"] not in clustered_ids:  # Check if not part of a cluster
            if obj['distance'] == -1:
                phrases.append(f"{obj['label']} very close!")
            else:
                phrases.append(f"{obj['label']} at {obj['distance']} meters {obj['side']}.")

    return phrases

def reload_clusters():
    global clusters
    clusters = {}
