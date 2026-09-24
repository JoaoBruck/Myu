extends SceneTree
## Real-engine physics and input regression checks.
const MAIN := preload("res://scenes/main.tscn")
var world: Node2D
var player: CharacterBody2D
var checks := 0
var failures := 0
const DT := 1.0/60.0
func _initialize() -> void:
	call_deferred("_run")
func check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS ",description)
	else:
		failures += 1
		push_error("FAIL "+description)
func place(source_position: Vector2) -> void:
	player.stop_motion()
	player.position = source_position*(2.0/3.0)
	await physics_frame
func drive(direction: Vector2, frames: int) -> void:
	for i in frames:
		await physics_frame
		player.step_motion(direction,DT)
func walk_to(source_target: Vector2) -> bool:
	var target := source_target*(2.0/3.0)
	for i in 600:
		var offset := target-player.position
		if offset.length() < 3.0:
			player.stop_motion()
			return true
		await physics_frame
		player.step_motion(offset.normalized(),DT)
	return false
func _run() -> void:
	world = MAIN.instantiate()
	root.add_child(world)
	await physics_frame
	player = world.player
	player.set_physics_process(false)
	check(world.grade.get_shader_parameter("ambient").b > world.grade.get_shader_parameter("ambient").r,"cold dusk palette")
	check(world.background.texture.get_size() == Vector2(1536,864),"source artwork included")
	check(player.get_node("FeetCollision").shape is CapsuleShape2D,"rounded foot collider")
	check(world.collision_root.get_child_count() >= 20,"ground footprints loaded")
	for entry in [[Vector2.LEFT,&"left"],[Vector2.RIGHT,&"right"],[Vector2.UP,&"up"],[Vector2.DOWN,&"down"]]:
		await place(Vector2(775,640))
		var start := player.position
		await drive(entry[0],24)
		check((player.position-start).dot(entry[0]) > 30.0 and player.facing == entry[1],"movement and facing "+String(entry[1]))
		await drive(Vector2.ZERO,12)
		check(player.velocity.length() < 0.01 and player.sprite.animation == StringName("idle_"+String(entry[1])),"stop keeps facing "+String(entry[1]))
	await place(Vector2(700,640))
	var origin := player.position
	await drive(Vector2.RIGHT,30)
	var cardinal := player.position.distance_to(origin)
	await place(Vector2(700,640))
	origin = player.position
	await drive(Vector2.ONE,30)
	check(absf(player.position.distance_to(origin)-cardinal) < 0.7,"diagonal speed equals cardinal")
	for probe in [
		{"position":Vector2(514,515),"minimum":472.0,"name":"cafe board"},
		{"position":Vector2(941,490),"minimum":457.0,"name":"bench"},
		{"position":Vector2(1074,488),"minimum":446.0,"name":"lamp foot"},
		{"position":Vector2(609,486),"minimum":410.0,"name":"cafe facade"}]:
		await place(probe.position)
		await drive(Vector2.UP,60)
		check(player.position.y*1.5 >= probe.minimum and player.position.y*1.5 < probe.position.y-15,"collision "+probe.name)
		check(player.sprite.animation.begins_with("idle_"),"no walking in place at "+probe.name)
	await place(Vector2(1340,587))
	origin = player.position
	await drive(Vector2.UP,32)
	check(origin.y-player.position.y > 45.0,"overhead panels do not block road")
	await place(Vector2(1260,777))
	await drive(Vector2.RIGHT,40)
	check(player.position.x*1.5 < 1282,"sign pole has solid base")
	await place(Vector2(1100,296))
	await drive(Vector2.UP,75)
	check(player.position.y*1.5 >= 257.0,"river bank blocks entry")
	await place(Vector2(580,760))
	await drive(Vector2.DOWN,85)
	check(player.position.y*1.5 <= 864.2,"world boundary")
	await place(Vector2(621,505))
	var route_clear := true
	for waypoint in [Vector2(1130,507),Vector2(1400,570),Vector2(1512,562),Vector2(1512,415),Vector2(1400,346),Vector2(1220,285),Vector2(1108,285)]:
		if not await walk_to(waypoint):
			route_clear = false
			print("BLOCKED_ROUTE ",waypoint," at ",player.position*1.5)
			break
	check(route_clear,"continuous cafe -> ramp -> riverside route")
	var saved_position := player.position
	var matching := true
	for polygon in world.foreground:
		matching = matching and polygon.texture == world.background.texture and polygon.material == world.grade
	check(matching,"foreground and background share the same palette")
	var weather = world.get_node("Weather")
	weather.set_process(false)
	var minimum := 1.0
	var maximum := 0.0
	var biggest_jump := 0.0
	var damp_when_dry := false
	for i in 60*260:
		var previous_intensity: float = weather.intensity
		weather.advance_weather(DT)
		minimum = minf(minimum,weather.intensity)
		maximum = maxf(maximum,weather.intensity)
		biggest_jump = maxf(biggest_jump,absf(weather.intensity-previous_intensity))
		if weather.intensity < 0.001 and weather.wetness > 0.35:
			damp_when_dry = true
	check(minimum == 0.0 and maximum > 0.65,"automatic rain includes a dry pause and stronger rain")
	check(biggest_jump < 0.001,"weather changes smoothly including cycle wrap")
	check(damp_when_dry,"ground stays wet after the rain stops")
	check(player.position == saved_position,"weather never moves the player")
	check(not InputMap.has_action("cycle_time") and not InputMap.has_action("toggle_rain"),"no manual time or weather shortcuts")
	weather.set_process(true)
	await place(Vector2(700,640))
	await drive(Vector2.RIGHT,15)
	var previous_phase: float = player.gait_distance
	await drive(Vector2.DOWN,1)
	var expected_phase: float = fposmod(previous_phase+player.moved_distance,player.STRIDE_DISTANCE)
	check(absf(player.gait_distance-expected_phase) < 0.01 and player.sprite.animation == &"walk_down","turn preserves the step phase")
	await place(Vector2(700,640))
	previous_phase = player.gait_distance
	await drive(Vector2.RIGHT*0.3,10)
	var slow_travel: float = player.gait_distance-previous_phase
	check(absf(fposmod(slow_travel,player.STRIDE_DISTANCE)-fposmod(player.position.x-700.0*(2.0/3.0),player.STRIDE_DISTANCE)) < 0.02,"analog gait matches actual distance")
	await place(Vector2(700,640))
	player.set_physics_process(true)
	var key := InputEventKey.new()
	key.physical_keycode = KEY_D
	key.pressed = true
	Input.parse_input_event(key)
	origin = player.position
	for i in 20:
		await physics_frame
	check(Input.is_action_pressed("move_right") and player.position.x > origin.x+15,"D drives actual physics process")
	key.pressed = false
	Input.parse_input_event(key)
	for i in 12:
		await physics_frame
	check(player.velocity.length() < 0.01,"key release stops movement")
	player.set_physics_process(false)
	var controls = world.get_node("MobileUI/MobileControls")
	var clean_ui: bool = controls.find_children("*","Button",true,false).size() == 1 and controls.action_button.name == &"ChairAction"
	for label in controls.find_children("*","Label",true,false):
		clean_ui = clean_ui and not label.text.contains("17:40") and not label.text.contains("Chuva")
	check(clean_ui,"no clock, weather selector or time label in the UI")
	controls.update_joystick(controls.joystick_center+Vector2(1,0))
	check(player.touch_input == Vector2.ZERO,"touch dead zone")
	controls.update_joystick(controls.joystick_center+Vector2(100,0))
	check(player.touch_input.x > 0.99,"touch reaches full speed")
	controls.notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT)
	player.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(player.touch_input == Vector2.ZERO and player.velocity == Vector2.ZERO,"focus loss releases movement")
	var atlas: Image = player.SHEET.get_image()
	var solid := true
	for row in 5:
		for column in (4 if row == 0 else 6):
			var head_pixels := 0
			var body_pixels := 0
			for y in range(3,22):
				for x in range(5,27):
					if atlas.get_pixel(column*32+x,row*56+y).a > 0.9:
						head_pixels += 1
			for y in range(28,45):
				for x in range(11,22):
					if atlas.get_pixel(column*32+x,row*56+y).a > 0.9:
						body_pixels += 1
			solid = solid and head_pixels > 90 and body_pixels > 80
	check(solid,"all poses retain head and opaque clothing")
	var stable_head := true
	var moving_boots := true
	for row in [3,4]:
		for column in range(1,6):
			for y in 32:
				for x in 32:
					var reference := atlas.get_pixel(x,row*56+y)
					var actual := atlas.get_pixel(column*32+x,row*56+y)
					# Importer alpha-border RGB is invisible; compare visible pixels.
					if maxf(reference.a,actual.a) > 0.0:
						stable_head = stable_head and reference == actual
		moving_boots = moving_boots and atlas.get_region(Rect2i(0,row*56+44,32,12)).get_data() != atlas.get_region(Rect2i(32,row*56+44,32,12)).get_data()
	check(stable_head and moving_boots,"side gait keeps the face stable while the feet animate")
	check(InputMap.action_get_events("move_up").size() == 2 and InputMap.action_get_events("move_left")[1].physical_keycode == KEY_LEFT,"WASD and arrow bindings")
	var seated_bounds: Rect2i = player.SEATED.get_image().get_used_rect()
	check(seated_bounds.size.y >= 43 and seated_bounds.end.y == 54,"seated art fills its cell and meets its foot baseline")
	var seat = world.get_node("SeatInteraction")
	await place(Vector2(800,640))
	seat.toggle()
	check(not player.seated and not seat.occupied,"cannot sit or teleport from far away")
	await place(Vector2(340,461))
	controls._process(0.0)
	check(seat.can_interact() and controls.action_button.visible,"chair action appears within reach")
	var interact := InputEventKey.new()
	interact.physical_keycode = KEY_E
	interact.pressed = true
	Input.parse_input_event(interact)
	await process_frame
	await process_frame
	check(player.seated and seat.occupied and player.sprite.animation == &"seated","E seats the player using the new sprite")
	var held := interact.duplicate() as InputEventKey
	held.echo = true
	Input.parse_input_event(held)
	await process_frame
	await process_frame
	check(seat.occupied,"holding E does not toggle repeatedly")
	var released := interact.duplicate() as InputEventKey
	released.pressed = false
	Input.parse_input_event(released)
	var seated_position := player.position
	await drive(Vector2.RIGHT,10)
	check(player.position == seated_position and player.velocity == Vector2.ZERO,"seated pose does not slide")
	check(seat.bubble.visible and seat.bubble.text_label.text == "Quando será que sai a continuação daquele livro?","requested thought appears in the bubble")
	seat.bubble.reveal()
	check(seat.bubble.text_label.visible_characters == -1,"dialogue can be revealed without waiting")
	player.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(player.seated and player.sprite.animation == &"seated","focus loss preserves sitting pose")
	controls.action_button.pressed.emit()
	check(not player.seated and not seat.bubble.visible and seat._exit_is_clear(player.position),"button stands up onto clear pavement and closes dialogue")
	await place(Vector2(340,461))
	var tap := InputEventScreenTouch.new()
	tap.index = 4
	tap.position = Vector2(339,379)*(2.0/3.0)
	tap.pressed = true
	# Pointer fixtures use viewport coordinates; a headless window is only 64x64.
	root.push_input(tap,true)
	await process_frame
	await process_frame
	check(player.seated,"touching the nearby chair also sits down")
	var tap_release := tap.duplicate() as InputEventScreenTouch
	tap_release.pressed = false
	root.push_input(tap_release,true)
	seat.stand_up()
	seat.sit_down()
	check(seat.bubble.age < 0.1 and not seat.bubble.revealed,"a new sit resets the dialogue cleanly")
	seat.stand_up()
	for probe in [["CafeBoard",Vector2(516,430)],["DirectionBoards",Vector2(1320,532)],["UtilityPoleLeft",Vector2(1120,710)],["ForegroundRight",Vector2(1468,620)]]:
		await place(probe[1])
		world.update_occlusion(1.0)
		check(world.depth_world.get_node(probe[0]).modulate.a < 0.30,"player remains visible behind "+probe[0])
	await place(Vector2(516,488))
	world.update_occlusion(1.0)
	check(world.depth_world.get_node("CafeBoard").modulate.a > 0.99,"foreground returns to opaque when player is in front")
	check(world.depth_world.has_node("UtilityPoleLeft") and world.depth_world.has_node("UtilityPoleRight"),"utility poles have independent silhouettes")
	print("MYU_TEST_RESULT checks=%d failures=%d" % [checks,failures])
	world.queue_free()
	await process_frame
	quit(1 if failures else 0)
