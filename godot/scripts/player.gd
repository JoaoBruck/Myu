extends CharacterBody2D
const WALK_SPEED := 116.0
const ACCELERATION := 1100.0
const DECELERATION := 1450.0
const STRIDE_DISTANCE := 68.0
const STEP_FRAMES := 6
const SHEET := preload("res://art/myu_walk.png")
const DIRECTIONS: Array[StringName] = [&"down", &"up", &"right", &"left"]
var touch_input := Vector2.ZERO
var facing: StringName = &"down"
var moved_distance := 0.0
var gait_distance := 0.0
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
	# Drive the pose from actual ground travel, including slides along obstacles.
	# This retains foot phase when changing direction and never walks against a wall.
	if moved_distance/maxf(delta,0.001) > 1.5:
		gait_distance = fposmod(gait_distance+moved_distance,STRIDE_DISTANCE)
		var phase := gait_distance/STRIDE_DISTANCE*STEP_FRAMES
		sprite.animation = StringName("walk_"+String(facing))
		sprite.pause()
		sprite.set_frame_and_progress(int(phase),fmod(phase,1.0))
	else:
		_play_idle()
func _play_idle() -> void:
	var animation := StringName("idle_"+String(facing))
	if sprite.animation != animation or not sprite.is_playing():
		sprite.play(animation)
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
	moved_distance = 0.0
	if is_instance_valid(sprite):
		_play_idle()
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		stop_motion()
func _build_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for row in 4:
		var suffix := String(DIRECTIONS[row])
		_add_animation(frames,StringName("walk_"+suffix),row+1,STEP_FRAMES,10.0)
		# Front idle and back pose come from the sheet; side idle plants both feet.
		_add_animation(frames,StringName("idle_"+suffix),0 if row == 0 else row+1,4 if row == 0 else 1,1.6,0 if row < 2 else 6)
	return frames
func _add_animation(frames: SpriteFrames, animation: StringName, row: int, count: int, fps: float, start: int = 0) -> void:
	frames.add_animation(animation)
	frames.set_animation_speed(animation,fps)
	for column in count:
		var texture := AtlasTexture.new()
		texture.atlas = SHEET
		texture.region = Rect2((column+start)*32,row*56,32,56)
		frames.add_frame(animation,texture)
