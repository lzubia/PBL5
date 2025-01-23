from distance_calculation import calculate_distance_from_box

def test_calculate_distance_from_box():
    distance = calculate_distance_from_box(1.5, 12, 50, 640)
    assert distance is not None
    assert distance > 0
