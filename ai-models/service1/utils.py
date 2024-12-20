import os

def save_uploaded_file(file):
    temp_file_path = f"./temp_{file.filename}"
    with open(temp_file_path, "wb") as buffer:
        buffer.write(file.file.read())
    return temp_file_path

def remove_temp_file(file_path):
    os.remove(file_path)
