extends Node2D

const WORLD_SIZE := Vector2(1024, 576)
const LEAF_COUNT := 18

var _time := 0.0
var _leaves: Array[Vector2] = []
var _leaf_speed: Array[Vector2] = []
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.seed = 17401740
	for i in LEAF_COUNT:
		_leaves.append(Vector2(_rng.randf_range(70.0, 990.0), _rng.randf_range(80.0, 430.0)))
		_leaf_speed.append(Vector2(_rng.randf_range(-5.0, 6.0), _rng.randf_range(7.0, 15.0)))
	print("MYU_POLISH_READY")
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta
	for i in _leaves.size():
		var p := _leaves[i]
		p += _leaf_speed[i] * delta
		p.x += sin(_time * 0.8 + float(i)) * 2.4 * delta
		if p.y > WORLD_SIZE.y + 12.0:
			p.y = -12.0
			p.x = _rng.randf_range(50.0, 1000.0)
		if p.x < -20.0:
			p.x = WORLD_SIZE.x + 10.0
		elif p.x > WORLD_SIZE.x + 20.0:
			p.x = -10.0
		_leaves[i] = p
	queue_redraw()

func _draw() -> void:
	var pulse := 0.88 + sin(_time * 2.1) * 0.05

	_draw_glow(Vector2(392, 215), 46.0, Color(1.0, 0.55, 0.28, 0.055 * pulse))
	_draw_glow(Vector2(454, 207), 34.0, Color(1.0, 0.58, 0.30, 0.050 * pulse))
	_draw_glow(Vector2(720, 165), 52.0, Color(1.0, 0.56, 0.25, 0.060 * pulse))
	_draw_glow(Vector2(910, 219), 37.0, Color(1.0, 0.52, 0.24, 0.045 * pulse))

	for i in _leaves.size():
		var p := _leaves[i]
		var size := 2.0 + float(i % 3)
		var sway := sin(_time * 1.6 + float(i) * 0.7) * 2.0
		var leaf := PackedVector2Array([
			p + Vector2(-size, 0),
			p + Vector2(0, -size * 0.65 + sway * 0.12),
			p + Vector2(size, 0),
			p + Vector2(0, size * 0.65)
		])
		var color := Color(0.42 + float(i % 3) * 0.04, 0.10, 0.15, 0.42)
		draw_colored_polygon(leaf, color)

func _draw_glow(center: Vector2, radius: float, color: Color) -> void:
	draw_circle(center, radius, color)
	draw_circle(center, radius * 0.62, Color(color.r, color.g, color.b, color.a * 1.35))
	draw_circle(center, radius * 0.28, Color(color.r, color.g, color.b, color.a * 1.65))
