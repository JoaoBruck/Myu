extends Node2D

const DROP_COUNT := 86
var _drops: Array[Vector2] = []
var _speeds: Array[float] = []
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.seed = 1740
	for i in DROP_COUNT:
		_drops.append(Vector2(_rng.randi_range(0, 511), _rng.randi_range(0, 287)))
		_speeds.append(_rng.randf_range(120.0, 210.0))
	queue_redraw()

func _process(delta: float) -> void:
	for i in _drops.size():
		var p := _drops[i]
		p.x -= _speeds[i] * 0.10 * delta
		p.y += _speeds[i] * delta
		if p.y > 292:
			p.y = -8
			p.x = _rng.randi_range(0, 520)
		_drops[i] = p
	queue_redraw()

func _draw() -> void:
	for i in _drops.size():
		var p := _drops[i]
		var alpha := 0.16 + float(i % 4) * 0.05
		var length := 3.0 + float(i % 3)
		draw_line(p, p + Vector2(-1, length), Color(0.65, 0.70, 0.86, alpha), 1.0)
