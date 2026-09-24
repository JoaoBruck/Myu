extends Node2D
## Opposite pavement: the mysterious seller speaks from inside the kiosk.
const ART := preload("res://art/newsstand.png")
const Bubble := preload("res://scripts/thought_bubble.gd")
const VENDOR := Vector2(464,507)
const COUNTER_APPROACH := Vector2(391,550)
const APPROACH := Vector2(368,540)
const REACH := 55.0
const MESSAGE := "Não chegou nada novo no momento. Volte daqui a 4 dias."
var active := false
var bubble: Control
var visual: Sprite2D
var underlay: Sprite2D
@onready var player: CharacterBody2D = get_node("../Player")
func _ready() -> void:
	visual = _make_sprite()
	add_child(visual)
	# Keep the kiosk opaque behind the actor while its foreground can reveal her.
	underlay = _make_sprite()
	underlay.position += position
	underlay.z_index = 19
	get_node("../..").add_child.call_deferred(underlay)
	_build_footprint("NewsstandFootprint",Rect2(-77,-18,158,20))
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
	sprite.position = Vector2(-96,-160)
	sprite.scale = Vector2(2,2)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.modulate = Color(0.86,0.90,1.0)
	return sprite
func _build_footprint(body_name: String, rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.name = body_name
	body.position = position
	body.collision_layer = 1
	body.collision_mask = 2
	var polygon := CollisionPolygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	body.add_child(polygon)
	get_node("../../CollisionGeometry").add_child(body)
func can_interact() -> bool:
	return not player.seated and player.position.distance_to(COUNTER_APPROACH) <= REACH and player.position.x < 414.0 and player.position.y > 501.0
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
		bubble.show_at(VENDOR+Vector2(-60,25))
func close_dialogue() -> void:
	active = false
	bubble.hide_bubble()
func _process(delta: float) -> void:
	if active and (not can_interact() or player.seated):
		close_dialogue()
	var player_rect := Rect2(player.position+Vector2(-24,-102),Vector2(48,100))
	var covered := player.position.y < position.y and player_rect.intersects(Rect2(position+Vector2(-96,-160),Vector2(192,156)))
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
		if tap and Rect2(VENDOR-Vector2(45,38),Vector2(90,56)).has_point(point):
			interact()
			get_viewport().set_input_as_handled()
func _draw() -> void:
	# Ground contact only; never cast a shadow across the whole road.
	draw_set_transform(Vector2(2,-3),0,Vector2(1,0.12))
	draw_circle(Vector2.ZERO,79,Color(0.015,0.02,0.04,0.22))
	draw_set_transform(Vector2.ZERO)
	if can_interact() and not active:
		var p := VENDOR-position-Vector2(0,40)
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-4),p+Vector2(4,0),p+Vector2(0,4),p+Vector2(-4,0)]),Color("e1c898"))
