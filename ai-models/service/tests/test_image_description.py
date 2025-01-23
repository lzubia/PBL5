from PIL import Image
from image_description import ImageDescriptionModel

def test_describe():
    model = ImageDescriptionModel()
    image = Image.new("RGB", (100, 100), color="white")
    description = model.describe(image)
    assert isinstance(description, str)
    assert len(description) > 0
