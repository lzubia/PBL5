import os
import cv2
from config import RESIZE_DIM
import shutil

def save_uploaded_file(file):
    """
    Saves the uploaded file in a temporal file.
    """
    temp_file_path = f"./temp_{file.filename}"
    with open(temp_file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    return temp_file_path

# def save_uploaded_file(file):
#     """
#     Saves the uploaded file in a temporal file.
#     """
#     temp_file_path = f"./temp_{file.filename}"
#     with open(temp_file_path, "wb") as buffer:
#         buffer.write(file.file.read())
#     return temp_file_path

def remove_temp_file(file_path):
    """
    Removes the temporal file.
    """
    os.remove(file_path)

def read_and_preprocess_image(temp_file_path):
        """
        Read and preprocess the uploaded image.
        """
        image = cv2.imread(temp_file_path)
        if image is None:
            raise ValueError("Failed to load the image.")
        return cv2.resize(image, (RESIZE_DIM, RESIZE_DIM))