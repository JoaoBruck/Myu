extends CharacterBody2D

const WALK_SPEED := 48.0
const ACCELERATION := 420.0
const DECELERATION := 560.0

const TEX_FRONT := preload("res://assets/myu_front.png")
const TEX_RIGHT := preload("res://assets/myu_right.png")
const TEX_BACK := preload("res://assets/myu_back.png")
const TEX_LEFT := preload("res://assets/myu_left.png")

var _touch_input := Vector2.ZERO
var _facing := Vector2.DOWN
var _step_clock := 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.texture = TEX_FRONT

func set_touch_input(value: Vector2) -> void:
	_touch_input = value

func _physics_process(delta: float) -> void:
	var keyboard := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input_vector := keyboard + _touch_input
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		_facing = input_vector
		velocity = velocity.move_toward(input_vector * WALK_SPEED, ACCELERATION * delta)
		_step_clock += delta * 8.0
		_update_facing()
		sprite.position.y = -28.0 + round(sin(_step_clock))
	else:
		velocity = velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
		_step_clock = 0.0
		sprite.position.y = -28.0

	move_and_slide()

	# Temporary walkable envelope while the proper tile/collision pass is built.
	global_position.x = clamp(global_position.x, 18.0, 494.0)
	global_position.y = clamp(global_position.y, 118.0, 235.0)

func _update_facing() -> void:
	if abs(_facing.x) > abs(_facing.y):
		sprite.texture = TEX_RIGHT if _facing.x > 0.0 else TEX_LEFT
	else:
		sprite.texture = TEX_FRONT if _facing.y > 0.0 else TEX_BACK
