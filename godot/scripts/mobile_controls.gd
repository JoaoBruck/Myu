extends Control

const JOYSTICK_CENTER := Vector2(72, 222)
const JOYSTICK_RADIUS := 42.0
const KNOB_LIMIT := 28.0
const DEAD_ZONE := 0.14

var _joystick_touch_id := -1
var _knob_position := JOYSTICK_CENTER
var _player: CharacterBody2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_player = get_node("../../Player") as CharacterBody2D
	set_process_unhandled_input(true)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if _joystick_touch_id == -1 and touch.position.distance_to(JOYSTICK_CENTER) <= JOYSTICK_RADIUS * 1.6:
				_joystick_touch_id = touch.index
				_update_joystick(touch.position)
				get_viewport().set_input_as_handled()
		elif touch.index == _joystick_touch_id:
			_release_joystick()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _joystick_touch_id:
			_update_joystick(drag.position)
			get_viewport().set_input_as_handled()

func _update_joystick(screen_position: Vector2) -> void:
	var delta := screen_position - JOYSTICK_CENTER
	if delta.length() > KNOB_LIMIT:
		delta = delta.normalized() * KNOB_LIMIT
	_knob_position = JOYSTICK_CENTER + delta
	var direction := delta / KNOB_LIMIT
	if direction.length() < DEAD_ZONE:
		direction = Vector2.ZERO
	elif direction.length() > 1.0:
		direction = direction.normalized()
	_player.set_touch_input(direction)
	queue_redraw()

func _release_joystick() -> void:
	_joystick_touch_id = -1
	_knob_position = JOYSTICK_CENTER
	_player.set_touch_input(Vector2.ZERO)
	queue_redraw()

func _draw() -> void:
	draw_circle(JOYSTICK_CENTER, JOYSTICK_RADIUS, Color(0.04, 0.045, 0.08, 0.50))
	draw_arc(JOYSTICK_CENTER, JOYSTICK_RADIUS, 0.0, TAU, 40, Color(0.77, 0.73, 0.88, 0.42), 2.0, true)
	draw_circle(_knob_position, 14.0, Color(0.80, 0.76, 0.91, 0.68))
