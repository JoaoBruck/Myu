extends Node2D
## One explicit interaction with safe entry/exit and the same controls on desktop/touch.
const Bubble := preload("res://scripts/thought_bubble.gd")
const SCALE := 2.0/3.0
const APPROACH := Vector2(340,461)*SCALE
const SIT_POSITION := Vector2(340,439)*SCALE
const REACH := 43.0
var occupied := false
var seated_seconds := 0.0
var bubble: Control
var approach_area: Area2D
@onready var player: CharacterBody2D = get_node("../DepthWorld/Player")
func _ready() -> void:
	z_index = 85
	approach_area = Area2D.new()
	approach_area.name = "ChairReach"
	approach_area.position = APPROACH
	approach_area.collision_layer = 0
	approach_area.collision_mask = 2
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = REACH
	shape.shape = circle
	approach_area.add_child(shape)
	add_child(approach_area)
	var layer := CanvasLayer.new()
	layer.layer = 101
	add_child(layer)
	bubble = Bubble.new()
	layer.add_child(bubble)
	print("MYU_CAFE_SEAT_READY")
func can_interact() -> bool:
	return occupied or (player.position.distance_to(APPROACH) <= REACH and player.position.y >= 402.0*SCALE)
func toggle() -> void:
	if occupied:
		stand_up()
	elif can_interact():
		sit_down()
func sit_down() -> void:
	if occupied or not can_interact():
		return
	occupied = true
	seated_seconds = 0.0
	get_node("../MobileUI/MobileControls").release_joystick()
	player.set_seated(true,SIT_POSITION)
	bubble.show_at(SIT_POSITION)
func stand_up() -> bool:
	if not occupied:
		return false
	# Try the front of the chair, then two nearby clear pavement positions.
	for point in [APPROACH,Vector2(306,457)*SCALE,Vector2(363,469)*SCALE]:
		if _exit_is_clear(point):
			occupied = false
			player.set_seated(false,point)
			bubble.hide_bubble()
			return true
	return false
func _exit_is_clear(point: Vector2) -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	var feet: CollisionShape2D = player.get_node("FeetCollision")
	query.shape = feet.shape
	query.transform = Transform2D(feet.rotation,point+feet.position)
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	return get_world_2d().direct_space_state.intersect_shape(query,1).is_empty()
func _process(delta: float) -> void:
	if occupied:
		seated_seconds += delta
		var movement := Input.get_vector("move_left","move_right","move_up","move_down")
		if seated_seconds > 0.35 and (movement.length() > 0.25 or player.touch_input.length() > 0.25):
			stand_up()
	queue_redraw()
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo() and can_interact():
		toggle()
		get_viewport().set_input_as_handled()
	elif occupied and event.is_action_pressed("ui_cancel"):
		stand_up()
		get_viewport().set_input_as_handled()
	elif occupied and event.is_action_pressed("reveal_thought"):
		bubble.reveal()
		get_viewport().set_input_as_handled()
	elif not occupied and can_interact():
		var tapped := false
		var point := Vector2.ZERO
		if event is InputEventScreenTouch and event.pressed:
			tapped = true
			point = event.position
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			tapped = true
			point = event.position
		if tapped and Rect2(Vector2(304,328)*SCALE,Vector2(78,112)*SCALE).has_point(point):
			sit_down()
			get_viewport().set_input_as_handled()
func _draw() -> void:
	if occupied or not can_interact():
		return
	var p := Vector2(335,323)*SCALE
	draw_colored_polygon(PackedVector2Array([p+Vector2(0,-4),p+Vector2(4,0),p+Vector2(0,4),p+Vector2(-4,0)]),Color("e1c898"))
