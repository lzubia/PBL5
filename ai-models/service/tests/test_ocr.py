from io import BytesIO
from PIL import Image
from ocr import OCR_Model

def test_ocr_model():
    class MockFile:
        def __init__(self, content):
            self.file = BytesIO(content)

    ocr = OCR_Model()
    image = Image.new("RGB", (100, 100), color="white")

    # Convierte la imagen a bytes para simular un archivo
    buffer = BytesIO()
    image.save(buffer, format="JPEG")
    buffer.seek(0)

    file = MockFile(buffer.getvalue())
    text = ocr.execute_ocr(file)  # Pasa el mock file
    assert isinstance(text, str)
