extends Node2D
const Geometry = preload("res://data/lume_geometry.gd")
func _draw() -> void:
	for entry in Geometry.blockers():
		var polygon: PackedVector2Array = Geometry.to_world(entry.polygon)
		draw_colored_polygon(polygon,Color(0.2,0.95,0.65,0.18))
		var outline := polygon.duplicate()
		outline.append(polygon[0])
		draw_polyline(outline,Color(0.2,0.95,0.65,0.8),1.0)
