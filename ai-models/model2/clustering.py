import math
import numpy as np
from typing import List, Dict

grouping_classes = {"vehicle", "tree", "barrier", "safety-barrier", "table", "chair", "person"}

# Global dictionary to store clusters
clusters = {}

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

    for label, group in clusters.items():
        if label == obj['label']:
            distance = get_distance(obj, group)
            if distance < min_distance:
                min_distance = distance
                closest_group = group

    if closest_group is not None:
        closest_group.append(obj)
    else:
        clusters[obj['label']] = [obj]

    # Determine direction for the cluster
    determine_cluster_direction(closest_group or [obj])

def determine_cluster_direction(group):
    """
    Determines the direction of the cluster based on the directions of its members.
    """
    directions = set()
    for obj in group:
        directions.add(obj['side'])
    
    # If "in front" exists in any object, the entire cluster is considered "in front"
    if "in front" in directions:
        cluster_direction = "in front"
    elif "left" in directions and "right" in directions:
        # If both "left" and "right" exist, the cluster is considered "in front"
        cluster_direction = "in front"
    elif "left" in directions:
        cluster_direction = "left"
    elif "right" in directions:
        cluster_direction = "right"
    else:
        cluster_direction = "in front"  # Default case
    
    # Assign the direction to the cluster
    for obj in group:
        obj['cluster_direction'] = cluster_direction

def get_distance(obj, group, iou_threshold=0.1, distance_threshold=20):
    """
    Calculate the distance between an object and a group.
    If bounding boxes overlap or are close, return a low distance.
    """
    def calculate_iou(bbox1, bbox2):
        # Intersection over Union calculation
        x1 = max(bbox1[0], bbox2[0])
        y1 = max(bbox1[1], bbox2[1])
        x2 = min(bbox1[2], bbox2[2])
        y2 = min(bbox1[3], bbox2[3])
        inter_area = max(0, x2 - x1) * max(0, y2 - y1)
        bbox1_area = (bbox1[2] - bbox1[0]) * (bbox1[3] - bbox1[1])
        bbox2_area = (bbox2[2] - bbox2[0]) * (bbox2[3] - bbox2[1])
        union_area = bbox1_area + bbox2_area - inter_area
        return inter_area / union_area if union_area > 0 else 0

    obj_bbox = obj['x1'], obj['y1'], obj['x2'], obj['y2']
    min_distance = float("inf")

    for group_obj in group:
        group_bbox = group_obj['x1'], group_obj['y1'], group_obj['x2'], group_obj['y2']
        iou = calculate_iou(obj_bbox, group_bbox)
        if iou > iou_threshold:
            return 0  # Consider it the same group

        obj_center = [(obj_bbox[0] + obj_bbox[2]) / 2, (obj_bbox[1] + obj_bbox[3]) / 2]
        group_center = [(group_bbox[0] + group_bbox[2]) / 2, (group_bbox[1] + group_bbox[3]) / 2]
        distance = np.linalg.norm(np.array(obj_center) - np.array(group_center))
        min_distance = min(min_distance, distance)

    return min_distance if min_distance < distance_threshold else float("inf")


def generate_output(detected_objects: List[Dict]) -> List[str]:
    """
    Generate descriptive phrases for detected objects, ensuring no duplicates.
    - If an object belongs to a group, only the group is mentioned.
    - Individual objects are described only if they are not in a group.
    """
    phrases = []

    # Identificar objetos agrupados
    clustered_ids = {obj['id'] for group in clusters.values() for obj in group}

    # Describir los clusters
    for label, group in clusters.items():
        count = len(group)
        cluster_direction = group[0].get('cluster_direction', 'in front')  # Get direction of the cluster
        if count > 1:
            phrases.append(f"A group of {label}s detected, located {cluster_direction}.")
        else:
            # Only one object in the "group"
            obj = group[0]
            if obj['distance'] == -1:
                phrases.append(f"{label} very close!")
            else:
                phrases.append(f"{label} at {obj['distance']} meters {cluster_direction}.")

    # Describir objetos individuales no agrupados
    for obj in detected_objects:
        if obj["label"] not in grouping_classes:  # Check if not part of a cluster
            if obj['distance'] == -1:
                phrases.append(f"{obj['label']} very close!")
            else:
                phrases.append(f"{obj['label']} at {obj['distance']} meters {obj['side']}.")

    return phrases

def reload_clusters():
    global clusters
    clusters = {}
