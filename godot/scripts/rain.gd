extends Node2D

const WORLD_SIZE := Vector2(1024, 576)
const DROP_COUNT := 156

var _drops: Array[Vector2] = []
var _speeds: Array[float] = []
var _rng := RandomNumberGenerator.new()
var _time := 0.0

func _ready() -> void:
	_rng.seed = 1740
	for i in DROP_COUNT:
		_drops.append(Vector2(_rng.randi_range(0, 1023), _rng.randi_range(0, 575)))
		_speeds.append(_rng.randf_range(170.0, 360.0))
	print("MYU_RAIN_READY")
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta
	for i in _drops.size():
		var p := _drops[i]
		var speed := _speeds[i]
		p.x -= speed * 0.12 * delta
		p.y += speed * delta
		if p.y > WORLD_SIZE.y + 14.0:
			p.y = -16.0
			p.x = _rng.randi_range(0, 1050)
		_drops[i] = p
	queue_redraw()

func _draw() -> void:
	for i in _drops.size():
		var p := _drops[i]
		var layer := i % 3
		var alpha := 0.07 + float(layer) * 0.035
		var length := 5.0 + float(layer) * 3.0 + float(i % 4)
		var width := 1.0 if layer < 2 else 1.35
		draw_line(
			p,
			p + Vector2(-2.0 - float(layer), length),
			Color(0.70, 0.75, 0.91, alpha),
			width,
			true
		)

		if layer == 2 and p.y > 365.0 and i % 11 == 0:
			var splash_alpha := 0.035 + sin(_time * 4.0 + float(i)) * 0.008
			draw_arc(
				p + Vector2(0, 5),
				4.0 + float(i % 4),
				0.15,
				PI - 0.15,
				12,
				Color(0.68, 0.72, 0.88, splash_alpha),
				1.0,
				true
			)
