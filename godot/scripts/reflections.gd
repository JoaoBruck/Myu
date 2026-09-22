extends Node2D

var _time := 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var pulse := 0.72 + sin(_time * 1.7) * 0.06
	_draw_fragmented_reflection(143, 165, 118, Color(0.95, 0.53, 0.30, 0.22 * pulse))
	_draw_fragmented_reflection(355, 160, 126, Color(0.95, 0.55, 0.29, 0.25 * pulse))
	_draw_fragmented_reflection(232, 173, 68, Color(0.71, 0.39, 0.36, 0.12 * pulse))

func _draw_fragmented_reflection(x: float, y: float, height: float, color: Color) -> void:
	var segment_y: float = y
	var widths: Array[float] = [8.0, 13.0, 6.0, 17.0, 9.0, 5.0]
	var index: int = 0
	while segment_y < min(y + height, 286.0):
		var segment_height: float = 4.0 + float(index % 3) * 2.0
		var width: float = widths[index % widths.size()]
		draw_rect(Rect2(x - width * 0.5, segment_y, width, segment_height), color)
		segment_y += segment_height + 5.0 + float(index % 2) * 3.0
		index += 1
