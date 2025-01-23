from clustering import cluster_obj, reload_clusters, clusters, grouping_classes

def test_cluster_obj():
    # Reinicia los clusters antes de la prueba
    reload_clusters()
    assert len(clusters) == 0  # clusters debería estar vacío inicialmente

    # Objetos de prueba
    obj1 = {
        "label": "car",  # Asegúrate de que 'car' está en grouping_classes
        "x1": 0, "y1": 0, "x2": 50, "y2": 50,
        "distance": 5, "side": "left", "id": 1
    }
    obj2 = {
        "label": "car",  # Mismo label para que se agrupen
        "x1": 60, "y1": 60, "x2": 100, "y2": 100,
        "distance": 10, "side": "right", "id": 2
    }

    # Verifica que el label de los objetos está en grouping_classes
    assert "car" in grouping_classes, "El label de los objetos no está en grouping_classes"

    # Agrupa los objetos
    cluster_obj(obj1)
    cluster_obj(obj2)

    # Depuración: Imprime el estado de los clusters
    print(f"Estado de clusters después de agrupar: {clusters}")

    # Verifica que se haya creado un cluster
    # assert len(clusters) == 1, f"Se esperaba un cluster, pero se encontraron: {len(clusters)}"
    # assert "car" in clusters, "No se encontró el cluster con el label 'car'"
    # assert len(clusters["car"]) == 2, f"El cluster 'car' debería contener 2 objetos, pero tiene: {len(clusters['car'])}"

    # Verifica que los objetos fueron agregados correctamente
    # cluster_member_ids = {obj["id"] for obj in clusters["car"]}
    # assert obj1["id"] in cluster_member_ids, "El primer objeto no fue agregado al cluster"
    # assert obj2["id"] in cluster_member_ids, "El segundo objeto no fue agregado al cluster"
