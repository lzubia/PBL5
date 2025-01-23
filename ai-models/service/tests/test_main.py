from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_list_services():
    """
    Prueba el endpoint /services.
    """
    response = client.get("/services")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
    assert len(response.json()) > 0

def test_start_session():
    """
    Prueba el endpoint /start-session.
    """
    response = client.get("/start-session")
    assert response.status_code == 200
    data = response.json()
    assert "session_id" in data
    assert isinstance(data["session_id"], str)

def test_end_session():
    """
    Prueba el endpoint /end-session con una sesión válida.
    """
    # Crea una sesión
    start_response = client.get("/start-session")
    session_id = start_response.json()["session_id"]

    # Finaliza la sesión
    end_response = client.delete(f"/end-session?session_id={session_id}")
    assert end_response.status_code == 200
    assert "results" in end_response.json()

def test_detect_objects():
    """
    Prueba el endpoint /detect con una imagen válida.
    """
    # Crea una sesión
    start_response = client.get("/start-session")
    assert start_response.status_code == 200
    session_id = start_response.json()["session_id"]

    # Sube una imagen válida
    with open("tests/test_image.jpeg", "rb") as img:
        response = client.post(
            f"/detect?session_id={session_id}",  # Pasa session_id como query
            files={"file": img}
        )
    print(response.json())  # Depuración: imprime detalles de la respuesta
    assert response.status_code == 200, f"Error en detect: {response.json()}"

def test_describe_image():
    """
    Prueba el endpoint /describe con una imagen válida.
    """
    # Crea una sesión
    start_response = client.get("/start-session")
    assert start_response.status_code == 200
    session_id = start_response.json()["session_id"]

    # Sube una imagen válida
    with open("tests/test_image.jpeg", "rb") as img:
        response = client.post(
            f"/describe?session_id={session_id}",  # Pasa session_id como query
            files={"file": img}
        )
    print(response.json())  # Depuración: imprime detalles de la respuesta
    assert response.status_code == 200, f"Error en describe: {response.json()}"

def test_count_money():
    """
    Prueba el endpoint /money con una imagen válida.
    """
    # Crea una sesión
    start_response = client.get("/start-session")
    assert start_response.status_code == 200
    session_id = start_response.json()["session_id"]

    # Sube una imagen válida
    with open("tests/test_money.jpg", "rb") as img:
        response = client.post(
            f"/money?session_id={session_id}",  # Pasa session_id como query
            files={"file": img}
        )
    print(response.json())  # Depuración: imprime detalles de la respuesta
    assert response.status_code == 200, f"Error en money: {response.json()}"

def test_perform_ocr():
    """
    Prueba el endpoint /ocr con una imagen válida.
    """
    # Crea una sesión
    start_response = client.get("/start-session")
    assert start_response.status_code == 200
    session_id = start_response.json()["session_id"]

    # Sube una imagen válida
    with open("tests/test_ocr.jpg", "rb") as img:
        response = client.post(
            f"/ocr?session_id={session_id}",  # Pasa session_id como query
            files={"file": img}
        )
    print(response.json())  # Depuración: imprime detalles de la respuesta
    assert response.status_code == 200, f"Error en ocr: {response.json()}"
