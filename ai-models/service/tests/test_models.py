from models import YOLOModel

def test_yolo_model():
    model = YOLOModel()
    assert model is not None
