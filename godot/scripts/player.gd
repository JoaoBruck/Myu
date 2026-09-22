extends CharacterBody2D

const WALK_SPEED := 52.0
const ACCELERATION := 520.0
const DECELERATION := 720.0

var _facing := Vector2.DOWN
var _step_clock := 0.0

func _ready() -> void:
	queue_redraw()

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vector.y += 1.0

	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		_facing = input_vector
		velocity = velocity.move_toward(input_vector * WALK_SPEED, ACCELERATION * delta)
		_step_clock += delta * 8.0
	else:
		velocity = velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
		_step_clock = 0.0

	move_and_slide()
	queue_redraw()

func _draw() -> void:
	# Temporary authored-in-engine silhouette using the approved 56 px scale.
	# It exists only until the final 4-direction sprite sheet is separated from the art source.
	var bob := 0.0
	if velocity.length() > 1.0:
		bob = round(sin(_step_clock) * 1.0)

	_draw_shadow_ellipse(Vector2(0, 27), Vector2(11, 4), Color(0.025, 0.026, 0.045, 0.55))

	draw_rect(Rect2(-9, 13 + bob, 7, 13), Color("#211f2d"))
	draw_rect(Rect2(2, 13 + bob, 7, 13), Color("#211f2d"))
	draw_rect(Rect2(-12, 5 + bob, 24, 15), Color("#292638"))

	draw_rect(Rect2(-13, -12 + bob, 26, 22), Color("#4a3140"))
	draw_rect(Rect2(-16, -8 + bob, 4, 17), Color("#3b2a38"))
	draw_rect(Rect2(12, -8 + bob, 4, 17), Color("#3b2a38"))

	draw_rect(Rect2(-12, -13 + bob, 24, 7), Color("#48506f"))
	draw_rect(Rect2(7, -8 + bob, 6, 13), Color("#414864"))

	draw_circle(Vector2(0, -25 + bob), 11.0, Color("#d7a18e"))
	draw_circle(Vector2(0, -30 + bob), 15.0, Color("#3a252e"))
	draw_circle(Vector2(9, -42 + bob), 7.0, Color("#3a252e"))
	draw_rect(Rect2(-14, -30 + bob, 9, 17), Color("#3a252e"))
	draw_rect(Rect2(4, -30 + bob, 10, 15), Color("#3a252e"))

	draw_rect(Rect2(12, 4 + bob, 10, 13), Color("#3b2634"))
	draw_line(Vector2(8, -5 + bob), Vector2(17, 5 + bob), Color("#6a4a58"), 2.0)
	draw_circle(Vector2(20, 6 + bob), 3.0, Color("#f0d9c7"))
	draw_line(Vector2(17, 6 + bob), Vector2(23, 6 + bob), Color("#f0d9c7"), 1.0)
	draw_line(Vector2(20, 3 + bob), Vector2(20, 9 + bob), Color("#f0d9c7"), 1.0)

func _draw_shadow_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in 24:
		var angle := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
