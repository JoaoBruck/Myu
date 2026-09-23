extends Node2D

var _time := 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var moving := 1.0
	var parent_body := get_parent() as CharacterBody2D
	if parent_body != null and parent_body.velocity.length() > 1.0:
		moving = 0.94 + sin(_time * 10.0) * 0.025

	_draw_ellipse(Vector2(0, 0), Vector2(25.0 * moving, 8.0 * moving), Color(0.015, 0.018, 0.03, 0.23))
	_draw_ellipse(Vector2(0, -1), Vector2(18.0 * moving, 5.0 * moving), Color(0.01, 0.012, 0.02, 0.24))

func _draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in 28:
		var angle := TAU * float(i) / 28.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
