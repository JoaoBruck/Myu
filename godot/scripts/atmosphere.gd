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
		_leaves.append(Vector2(_rng.randf_range(70.0, 990.0), _rng.randf_range(70.0, 430.0)))
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
	var pulse := 0.88 + sin(_time * 2.05) * 0.05
	var slow_pulse := 0.92 + sin(_time * 0.73) * 0.035

	# Warm sources aligned to the original 1672×941 scene.
	_draw_glow(Vector2(316, 181), 63.0, Color(1.0, 0.53, 0.27, 0.052 * slow_pulse))
	_draw_glow(Vector2(449, 137), 30.0, Color(1.0, 0.57, 0.29, 0.060 * pulse))
	_draw_glow(Vector2(726, 69), 48.0, Color(1.0, 0.55, 0.24, 0.068 * pulse))
	_draw_glow(Vector2(956, 168), 31.0, Color(1.0, 0.52, 0.24, 0.050 * slow_pulse))

	# A faint wet-air veil keeps the rain integrated rather than pasted on top.
	draw_rect(Rect2(0, 0, WORLD_SIZE.x, WORLD_SIZE.y), Color(0.11, 0.13, 0.21, 0.018))

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
		var color := Color(
			0.40 + float(i % 3) * 0.045,
			0.085 + float(i % 2) * 0.015,
			0.135,
			0.32 + float(i % 4) * 0.025
		)
		draw_colored_polygon(leaf, color)

func _draw_glow(center: Vector2, radius: float, color: Color) -> void:
	draw_circle(center, radius, color)
	draw_circle(center, radius * 0.62, Color(color.r, color.g, color.b, color.a * 1.35))
	draw_circle(center, radius * 0.28, Color(color.r, color.g, color.b, color.a * 1.70))
