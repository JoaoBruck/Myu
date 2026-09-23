extends CharacterBody2D
const WALK_SPEED := 116.0
const ACCELERATION := 1100.0
const DECELERATION := 1450.0
const SHEET := preload("res://art/myu_walk.png")
const DIRECTIONS: Array[StringName] = [&"down", &"up", &"right", &"left"]
var touch_input := Vector2.ZERO
var facing: StringName = &"down"
var moved_distance := 0.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
func _ready() -> void:
	sprite.sprite_frames = _build_frames()
	sprite.play(&"idle_down")
	print("MYU_PIXEL_PLAYER_READY")
	print("MYU_ANIMATED_PLAYER_READY")
	print("MYU_PLAYER_SHADOW_READY")
func set_touch_input(value: Vector2) -> void:
	touch_input = value.limit_length()
func _physics_process(delta: float) -> void:
	var keyboard := Input.get_vector("move_left","move_right","move_up","move_down")
	step_motion(keyboard if keyboard.length_squared() >= touch_input.length_squared() else touch_input,delta)
func step_motion(input_vector: Vector2, delta: float) -> void:
	var direction := input_vector.limit_length()
	var moving := direction.length_squared() > 0.001
	if moving:
		_update_facing(direction)
	velocity = velocity.move_toward(direction * WALK_SPEED,(ACCELERATION if moving else DECELERATION) * delta)
	var previous := global_position
	move_and_slide()
	moved_distance = global_position.distance_to(previous)
	var animation := StringName("walk_" + String(facing)) if moved_distance > 0.08 else StringName("idle_" + String(facing))
	if sprite.animation != animation:
		sprite.play(animation)
	sprite.speed_scale = clampf(moved_distance/maxf(delta,0.001)/WALK_SPEED,0.55,1.25) if animation.begins_with("walk_") else 1.0
func _update_facing(direction: Vector2) -> void:
	if absf(direction.x) > absf(direction.y) + 0.12:
		facing = &"right" if direction.x > 0 else &"left"
	elif absf(direction.y) > absf(direction.x) + 0.12:
		facing = &"down" if direction.y > 0 else &"up"
	elif facing in [&"left",&"right"]:
		facing = &"right" if direction.x > 0 else &"left"
	else:
		facing = &"down" if direction.y > 0 else &"up"
func stop_motion() -> void:
	touch_input = Vector2.ZERO
	velocity = Vector2.ZERO
	if is_instance_valid(sprite):
		sprite.play(StringName("idle_" + String(facing)))
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		stop_motion()
func _build_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for row in 4:
		var suffix := String(DIRECTIONS[row])
		_add_animation(frames,StringName("walk_"+suffix),row+1,6,9.0)
		# Only front idle is supplied; other directions hold a supplied pose.
		_add_animation(frames,StringName("idle_"+suffix),0 if row == 0 else row+1,4 if row == 0 else 1,3.0)
	return frames
func _add_animation(frames: SpriteFrames, animation: StringName, row: int, count: int, fps: float) -> void:
	frames.add_animation(animation)
	frames.set_animation_speed(animation,fps)
	for column in count:
		var texture := AtlasTexture.new()
		texture.atlas = SHEET
		texture.region = Rect2(column*32,row*56,32,56)
		frames.add_frame(animation,texture)
