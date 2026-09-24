extends Node2D
func _draw() -> void:
	# Inspect actual bodies, including the kiosk's dynamically built footprint.
	for body in get_node("../CollisionGeometry").get_children():
		for shape in body.get_children():
			if shape is CollisionPolygon2D:
				var polygon: PackedVector2Array = body.transform*shape.polygon
				draw_colored_polygon(polygon,Color(0.2,0.95,0.65,0.18))
				var outline := polygon.duplicate()
				outline.append(polygon[0])
				draw_polyline(outline,Color(0.2,0.95,0.65,0.8),1.0)
