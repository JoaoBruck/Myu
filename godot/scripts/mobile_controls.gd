extends Control

const JOYSTICK_CENTER := Vector2(72, 222)
const JOYSTICK_RADIUS := 43.0
const KNOB_LIMIT := 29.0
const DEAD_ZONE := 0.16

var _joystick_touch_id := -1
var _knob_position := JOYSTICK_CENTER
var _player: CharacterBody2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_player = get_node("../../Characters/Player") as CharacterBody2D
	set_process_unhandled_input(true)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if _joystick_touch_id == -1 and touch.position.distance_to(JOYSTICK_CENTER) <= JOYSTICK_RADIUS * 1.45:
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
	var outer := Color(0.08, 0.09, 0.15, 0.58)
	var border := Color(0.68, 0.66, 0.82, 0.42)
	var knob := Color(0.76, 0.72, 0.88, 0.68)

	draw_circle(JOYSTICK_CENTER, JOYSTICK_RADIUS, outer)
	draw_arc(JOYSTICK_CENTER, JOYSTICK_RADIUS, 0.0, TAU, 40, border, 2.0, true)
	draw_circle(_knob_position, 15.0, knob)
	draw_arc(_knob_position, 15.0, 0.0, TAU, 28, Color(0.92, 0.88, 1.0, 0.52), 1.0, true)

	_draw_direction_mark(Vector2(0, -1), Vector2(72, 190))
	_draw_direction_mark(Vector2(0, 1), Vector2(72, 254))
	_draw_direction_mark(Vector2(-1, 0), Vector2(40, 222))
	_draw_direction_mark(Vector2(1, 0), Vector2(104, 222))

func _draw_direction_mark(direction: Vector2, center: Vector2) -> void:
	var side := Vector2(-direction.y, direction.x)
	var tip := center + direction * 4.0
	var back := center - direction * 3.0
	var points := PackedVector2Array([
		tip,
		back + side * 3.0,
		back - side * 3.0,
	])
	draw_colored_polygon(points, Color(0.88, 0.85, 0.96, 0.45))
