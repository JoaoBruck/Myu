extends Node2D

const WORLD_SIZE := Vector2(1024, 576)
const LEAF_COUNT := 14

var _time := 0.0
var _leaves: Array[Vector2] = []
var _leaf_speed: Array[Vector2] = []
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.seed = 17401740
	for i in LEAF_COUNT:
		_leaves.append(Vector2(_rng.randf_range(70.0, 990.0), _rng.randf_range(70.0, 430.0)))
		_leaf_speed.append(Vector2(_rng.randf_range(-4.0, 5.0), _rng.randf_range(6.0, 12.0)))
	print("MYU_POLISH_READY")
	print("MYU_NO_FAKE_GLOWS_READY")
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta

	for i in _leaves.size():
		var p := _leaves[i]
		p += _leaf_speed[i] * delta
		p.x += sin(_time * 0.8 + float(i)) * 2.0 * delta

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
	# Apenas uma névoa fria quase imperceptível. As luzes permanecem as
	# pintadas no cenário original; não desenhamos círculos artificiais.
	draw_rect(Rect2(0, 0, WORLD_SIZE.x, WORLD_SIZE.y), Color(0.08, 0.10, 0.17, 0.012))

	for i in _leaves.size():
		var p := _leaves[i]
		var size := 1.6 + float(i % 3) * 0.5
		var sway := sin(_time * 1.4 + float(i) * 0.7) * 1.4
		var leaf := PackedVector2Array([
			p + Vector2(-size, 0),
			p + Vector2(0, -size * 0.55 + sway * 0.10),
			p + Vector2(size, 0),
			p + Vector2(0, size * 0.55)
		])
		var color := Color(
			0.38 + float(i % 3) * 0.035,
			0.075,
			0.12,
			0.20 + float(i % 4) * 0.02
		)
		draw_colored_polygon(leaf, color)
