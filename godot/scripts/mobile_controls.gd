extends Control
const DEAD_ZONE := 0.15
var joystick_center := Vector2(95,480)
var joystick_radius := 59.0
var knob := Vector2.ZERO
var touch_id := -1
var show_joystick := false
var hint: Label
var hint_age := 0.0
@onready var player = get_node("../../DepthWorld/Player")
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	show_joystick = DisplayServer.is_touchscreen_available()
	hint = Label.new()
	hint.text = "WASD / setas para caminhar"
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.add_theme_font_size_override("font_size",13)
	hint.add_theme_color_override("font_color",Color(0.83,0.87,0.94,0.85))
	hint.add_theme_color_override("font_shadow_color",Color(0.02,0.03,0.06,0.9))
	hint.add_theme_constant_override("shadow_offset_y",1)
	add_child(hint)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	hint.offset_left = -205
	hint.offset_top = -29
	hint.offset_right = -16
	hint.offset_bottom = -10
	get_viewport().size_changed.connect(_layout_joystick)
	_layout_joystick()
func _process(delta: float) -> void:
	hint_age += delta
	hint.visible = not show_joystick
	hint.modulate.a = 1.0-smoothstep(5.0,8.0,hint_age)
func _layout_joystick() -> void:
	joystick_radius = clampf(size.y*0.103,45.0,68.0)
	joystick_center = Vector2(joystick_radius+32.0,size.y-joystick_radius-30.0)
	release_joystick()
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		show_joystick = true
		queue_redraw()
		if event.pressed and touch_id == -1 and event.position.distance_to(joystick_center) < joystick_radius*1.45:
			show_joystick = true
			touch_id = event.index
			update_joystick(event.position)
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index == touch_id:
			release_joystick()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == touch_id:
		update_joystick(event.position)
		get_viewport().set_input_as_handled()
func update_joystick(position_on_screen: Vector2) -> void:
	knob = (position_on_screen-joystick_center).limit_length(joystick_radius*0.66)
	var raw := knob/(joystick_radius*0.66)
	var direction := Vector2.ZERO
	if raw.length() > DEAD_ZONE:
		direction = raw.normalized()*inverse_lerp(DEAD_ZONE,1.0,raw.length())
	player.set_touch_input(direction)
	queue_redraw()
func release_joystick() -> void:
	touch_id = -1
	knob = Vector2.ZERO
	if is_instance_valid(player):
		player.set_touch_input(Vector2.ZERO)
	queue_redraw()
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		release_joystick()
func _draw() -> void:
	if not show_joystick:
		return
	draw_circle(joystick_center,joystick_radius,Color(0.04,0.04,0.09,0.40))
	draw_arc(joystick_center,joystick_radius,0,TAU,48,Color(0.84,0.78,0.88,0.35),2.0,true)
	draw_circle(joystick_center+knob,22.0,Color(0.81,0.76,0.88,0.60))
