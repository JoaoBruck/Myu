extends CharacterBody2D

const WALK_SPEED := 48.0
const ACCELERATION := 420.0
const DECELERATION := 560.0
const CELL_W := 32
const CELL_H := 56

var _touch_input := Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	var sheet := _load_sheet_from_chunks()
	if sheet == null:
		push_error("MYU: animated sprite sheet failed to decode")
		return

	sprite.sprite_frames = _build_frames(sheet)
	sprite.play(&"idle_down")
	print("MYU_PIXEL_PLAYER_READY")
	print("MYU_ANIMATED_PLAYER_READY")

func set_touch_input(value: Vector2) -> void:
	_touch_input = value

func _physics_process(delta: float) -> void:
	var keyboard := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input_vector := keyboard + _touch_input
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * WALK_SPEED, ACCELERATION * delta)
		_play_walk_animation(input_vector)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
		if sprite.animation != &"idle_down":
			sprite.play(&"idle_down")

	move_and_slide()
	global_position.x = clamp(global_position.x, 18.0, 494.0)
	global_position.y = clamp(global_position.y, 118.0, 235.0)

func _play_walk_animation(input_vector: Vector2) -> void:
	var next_animation: StringName
	if abs(input_vector.x) > abs(input_vector.y):
		next_animation = &"walk_right" if input_vector.x > 0.0 else &"walk_left"
	else:
		next_animation = &"walk_down" if input_vector.y > 0.0 else &"walk_up"

	if sprite.animation != next_animation:
		sprite.play(next_animation)

func _build_frames(sheet: Texture2D) -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")

	_add_animation(frames, sheet, &"idle_down", 0, 4, 4.0)
	_add_animation(frames, sheet, &"walk_down", 1, 6, 8.0)
	_add_animation(frames, sheet, &"walk_up", 2, 6, 8.0)
	_add_animation(frames, sheet, &"walk_right", 3, 6, 8.0)
	_add_animation(frames, sheet, &"walk_left", 4, 6, 8.0)

	return frames

func _add_animation(
	frames: SpriteFrames,
	sheet: Texture2D,
	animation_name: StringName,
	row: int,
	frame_count: int,
	fps: float
) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, fps)
	frames.set_animation_loop(animation_name, true)

	for column in frame_count:
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(
			column * CELL_W,
			row * CELL_H,
			CELL_W,
			CELL_H
		)
		frames.add_frame(animation_name, atlas)

func _load_sheet_from_chunks() -> Texture2D:
	var encoded := ""
	for path in [
		"res://assets_b64/myu_anim_0.b64",
		"res://assets_b64/myu_anim_1.b64",
		"res://assets_b64/myu_anim_2.b64",
		"res://assets_b64/myu_anim_3.b64",
	]:
		var chunk := FileAccess.get_file_as_string(path).strip_edges()
		if chunk.is_empty():
			push_error("MYU: empty animation chunk: " + path)
			return null
		encoded += chunk

	var bytes := Marshalls.base64_to_raw(encoded)
	if bytes.is_empty():
		push_error("MYU: invalid animated sheet base64")
		return null

	var image := Image.new()
	var error := image.load_webp_from_buffer(bytes)
	if error != OK:
		push_error("MYU: animated WebP decode failed error=" + str(error))
		return null

	return ImageTexture.create_from_image(image)
