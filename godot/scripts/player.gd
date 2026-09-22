extends CharacterBody2D

const WALK_SPEED := 48.0
const ACCELERATION := 420.0
const DECELERATION := 560.0

var _touch_input := Vector2.ZERO
var _facing := Vector2.DOWN
var _step_clock := 0.0
var _tex_front: Texture2D
var _tex_right: Texture2D
var _tex_back: Texture2D
var _tex_left: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_tex_front = _texture_from_b64_webp("res://assets_b64/myu_front.b64")
	_tex_right = _texture_from_b64_webp("res://assets_b64/myu_right.b64")
	_tex_back = _texture_from_b64_webp("res://assets_b64/myu_back.b64")
	_tex_left = _texture_from_b64_webp("res://assets_b64/myu_left.b64")
	sprite.texture = _tex_front
	if _tex_front == null or _tex_right == null or _tex_back == null or _tex_left == null:
		push_error("MYU: one or more directional sprites failed to decode")
	else:
		print("MYU_PIXEL_PLAYER_READY")

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
	global_position.x = clamp(global_position.x, 18.0, 494.0)
	global_position.y = clamp(global_position.y, 118.0, 235.0)

func _update_facing() -> void:
	if abs(_facing.x) > abs(_facing.y):
		sprite.texture = _tex_right if _facing.x > 0.0 else _tex_left
	else:
		sprite.texture = _tex_front if _facing.y > 0.0 else _tex_back

func _texture_from_b64_webp(path: String) -> Texture2D:
	var encoded := FileAccess.get_file_as_string(path).strip_edges()
	if encoded.is_empty():
		push_error("MYU: empty base64 asset: " + path)
		return null
	var bytes := Marshalls.base64_to_raw(encoded)
	if bytes.is_empty():
		push_error("MYU: invalid base64 asset: " + path)
		return null
	var image := Image.new()
	var error := image.load_webp_from_buffer(bytes)
	if error != OK:
		push_error("MYU: WebP decode failed for " + path + " error=" + str(error))
		return null
	return ImageTexture.create_from_image(image)
