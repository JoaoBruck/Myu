extends Node2D
## A kiosk grounded in the left forecourt; the resident is a formless shadow.
const ART := preload("res://art/newsstand.png")
const Bubble := preload("res://scripts/thought_bubble.gd")
const APPROACH := Vector2(280,542)
const COUNTER_LEFT := Vector2(-48,-3)
const COUNTER_RIGHT := Vector2(114,-21)
const REACH := 48.0
const MESSAGE := "Não chegou nada novo no momento. Volte daqui a 4 dias."
var footprint := PackedVector2Array([Vector2(-104,-46),Vector2(-47,-5),Vector2(113,-22),Vector2(113,-55),Vector2(-50,-31)])
var active := false
var bubble: Control
var visual: Sprite2D
var underlay: Sprite2D
var vendor: Vector2:
	get: return position+Vector2(0,-88)
@onready var player: CharacterBody2D = get_node("../Player")
func _ready() -> void:
	visual = _make_sprite()
	add_child(visual)
	# Match the scenery's two-layer occlusion: an opaque base behind the actor.
	underlay = _make_sprite()
	underlay.position += position
	underlay.z_index = 19
	get_node("../..").add_child.call_deferred(underlay)
	_build_footprint()
	var layer := CanvasLayer.new()
	layer.layer = 101
	add_child(layer)
	bubble = Bubble.new()
	bubble.portrait_texture = null
	bubble.speaker_name = "Jornaleiro"
	bubble.message = MESSAGE
	layer.add_child(bubble)
	print("MYU_NEWSSTAND_READY")
func _make_sprite() -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = ART
	sprite.centered = false
	sprite.position = Vector2(-128,-224)
	sprite.scale = Vector2(2,2)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.modulate = Color(0.86,0.90,1.0)
	return sprite
func _build_footprint() -> void:
	var body := StaticBody2D.new()
	body.name = "NewsstandFootprint"
	body.position = position
	body.collision_layer = 1
	body.collision_mask = 2
	var polygon := CollisionPolygon2D.new()
	polygon.polygon = footprint
	body.add_child(polygon)
	get_node("../../CollisionGeometry").add_child(body)
func _front_y(x: float) -> float:
	var fraction := clampf(inverse_lerp(position.x+COUNTER_LEFT.x,position.x+COUNTER_RIGHT.x,x),0.0,1.0)
	return position.y+lerpf(COUNTER_LEFT.y,COUNTER_RIGHT.y,fraction)
func can_interact() -> bool:
	if player.seated or player.position.y < _front_y(player.position.x)+2.0:
		return false
	var nearest := Geometry2D.get_closest_point_to_segment(player.position,position+COUNTER_LEFT,position+COUNTER_RIGHT)
	return player.position.distance_to(nearest) <= REACH
func interact() -> void:
	if active:
		if bubble.text_label.visible_characters >= 0 and bubble.text_label.visible_characters < MESSAGE.length():
			bubble.reveal()
		else:
			close_dialogue()
	elif can_interact():
		player.stop_motion()
		get_node("../../MobileUI/MobileControls").release_joystick()
		active = true
		# Put the dialogue in the open street, clear of the seller and the player.
		bubble.show_at(vendor+Vector2(128,120))
func close_dialogue() -> void:
	active = false
	bubble.hide_bubble()
func _process(delta: float) -> void:
	if active and not can_interact():
		close_dialogue()
	var player_rect := Rect2(player.position+Vector2(-24,-102),Vector2(48,100))
	var behind := player.position.y < _front_y(player.position.x)
	var covered := behind and player_rect.intersects(Rect2(position+Vector2(-128,-224),Vector2(256,220)))
	# The counter's ground line is diagonal; standing beside it must draw in front.
	z_index = 0 if behind else -1
	visual.modulate.a = lerpf(visual.modulate.a,0.24 if covered else 1.0,1.0-exp(-delta*14.0))
	queue_redraw()
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo() and (active or can_interact()):
		interact()
		get_viewport().set_input_as_handled()
	elif active and event.is_action_pressed("ui_cancel"):
		close_dialogue()
		get_viewport().set_input_as_handled()
	elif active and event.is_action_pressed("reveal_thought"):
		bubble.reveal()
		get_viewport().set_input_as_handled()
	elif not active and can_interact():
		var tap := false
		var point := Vector2.ZERO
		if event is InputEventScreenTouch and event.pressed:
			tap = true
			point = event.position
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			tap = true
			point = event.position
		if tap and Rect2(vendor-Vector2(60,30),Vector2(152,76)).has_point(point):
			interact()
			get_viewport().set_input_as_handled()
func _draw() -> void:
	draw_colored_polygon(footprint,Color(0.015,0.02,0.04,0.19))
	if can_interact() and not active:
		var p := Vector2(105,-94)
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-4),p+Vector2(4,0),p+Vector2(0,4),p+Vector2(-4,0)]),Color("d3c9b7"))
