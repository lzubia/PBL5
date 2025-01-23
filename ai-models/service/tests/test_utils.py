import os
from io import BytesIO
from utils import save_uploaded_file, remove_temp_file

def test_save_and_remove_file():
    class MockFile:
        def __init__(self, name, content):
            self.filename = name
            self.file = BytesIO(content)

    file = MockFile("test.txt", b"contenido de prueba")
    temp_path = save_uploaded_file(file)
    
    assert os.path.exists(temp_path)  # Verifica que el archivo se guardó
    remove_temp_file(temp_path)
    assert not os.path.exists(temp_path)  # Verifica que el archivo se eliminó
