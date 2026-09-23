extends Control
const DEAD_ZONE := 0.15
var joystick_center := Vector2(95,480)
var joystick_radius := 59.0
var knob := Vector2.ZERO
var touch_id := -1
var show_joystick := false
var time_button: Button
var rain_button: Button
@onready var player = get_node("../../DepthWorld/Player")
@onready var world = get_node("../..")
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	show_joystick = DisplayServer.is_touchscreen_available()
	_build_toolbar()
	get_viewport().size_changed.connect(_layout_joystick)
	world.time_changed.connect(_update_time)
	world.rain_changed.connect(_update_rain)
	_layout_joystick()
	_update_time(world.time_index)
	_update_rain(world.rain_enabled)
func _build_toolbar() -> void:
	var title := Label.new()
	title.text = "LUME CAFÉ"
	title.position = Vector2(20,16)
	title.add_theme_font_size_override("font_size",17)
	title.add_theme_color_override("font_color",Color(0.89,0.82,0.74))
	title.add_theme_color_override("font_shadow_color",Color(0.05,0.05,0.10,0.9))
	title.add_theme_constant_override("shadow_offset_x",1)
	title.add_theme_constant_override("shadow_offset_y",2)
	add_child(title)
	var toolbar := HBoxContainer.new()
	toolbar.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	toolbar.position = Vector2(-327,14)
	toolbar.size = Vector2(311,42)
	toolbar.add_theme_constant_override("separation",8)
	add_child(toolbar)
	time_button = _button(Vector2(209,40))
	rain_button = _button(Vector2(94,40))
	toolbar.add_child(time_button)
	toolbar.add_child(rain_button)
	time_button.pressed.connect(world.cycle_time)
	rain_button.pressed.connect(world.toggle_rain)
	var hint := Label.new()
	hint.text = "WASD / setas   ·   T horário   ·   R chuva"
	hint.add_theme_font_size_override("font_size",13)
	hint.add_theme_color_override("font_color",Color(0.85,0.84,0.89,0.8))
	add_child(hint)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	hint.offset_left = -320
	hint.offset_top = -27
	hint.offset_right = -12
	hint.offset_bottom = -8
	hint.visible = not show_joystick
func _button(minimum: Vector2) -> Button:
	var button := Button.new()
	button.custom_minimum_size = minimum
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size",14)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055,0.061,0.105,0.88)
	style.border_color = Color(0.46,0.42,0.54,0.70)
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	button.add_theme_stylebox_override("normal",style)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.15,0.14,0.23,0.94)
	button.add_theme_stylebox_override("hover",hover)
	button.add_theme_stylebox_override("pressed",hover)
	return button
func _update_time(index: int) -> void:
	time_button.text = world.TIME_LABELS[index]
func _update_rain(enabled: bool) -> void:
	rain_button.text = "Chuva: sim" if enabled else "Chuva: não"
func _layout_joystick() -> void:
	joystick_radius = clampf(size.y*0.103,45.0,68.0)
	joystick_center = Vector2(joystick_radius+32.0,size.y-joystick_radius-30.0)
	release_joystick()
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
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
