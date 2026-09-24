extends Node2D

var _time := 0.0
var wetness := 0.72
var rain_intensity := 0.34

func _ready() -> void:
	print("MYU_REFLECTIONS_READY")

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var pulse := (0.72 + sin(_time * 1.5) * 0.055)*wetness

	_draw_fragmented_reflection(286, 326, 226, Color(0.96, 0.52, 0.29, 0.13 * pulse))
	_draw_fragmented_reflection(710, 312, 242, Color(1.0, 0.57, 0.29, 0.16 * pulse))
	_draw_fragmented_reflection(464, 342, 150, Color(0.74, 0.41, 0.38, 0.08 * pulse))
	_draw_fragmented_reflection(930, 334, 176, Color(1.0, 0.54, 0.26, 0.11 * pulse))

	_draw_ripple(Vector2(565, 446), 13.0, rain_intensity)
	_draw_ripple(Vector2(748, 496), 9.0, rain_intensity * 0.8)
	_draw_ripple(Vector2(350, 470), 7.0, rain_intensity * 0.7)

func _draw_fragmented_reflection(x: float, y: float, height: float, color: Color) -> void:
	var segment_y: float = y
	var widths: Array[float] = [12.0, 24.0, 9.0, 31.0, 17.0, 8.0]
	var index := 0

	while segment_y < min(y + height, 566.0):
		var segment_height := 4.0 + float(index % 3) * 2.0
		var width := widths[index % widths.size()]
		var drift := sin(_time * 1.4 + float(index)) * 2.5
		draw_rect(Rect2(x - width * 0.5 + drift, segment_y, width, segment_height), color)
		segment_y += segment_height + 8.0 + float(index % 2) * 4.0
		index += 1

func _draw_ripple(center: Vector2, radius: float, alpha_scale: float) -> void:
	var phase := fmod(_time * 9.0 + center.x * 0.03, radius)
	var r := 3.0 + phase
	draw_arc(center, r, 0.0, TAU, 32, Color(0.62, 0.68, 0.85, 0.055 * alpha_scale), 1.0, true)
