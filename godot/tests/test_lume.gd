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
	check(world.time_index == 2,"17:40 is default")
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
	for mode in 4:
		world.set_time_of_day(mode)
		check(world.background.texture == (world.NIGHT if mode == 3 else world.DAY),"correct art at time "+str(mode))
		var matching := true
		for polygon in world.foreground:
			matching = matching and polygon.texture == world.background.texture and polygon.material == world.grade
		check(matching and player.position == saved_position,"foreground/physics aligned at time "+str(mode))
	world.set_time_of_day(2)
	world.toggle_rain()
	check(not world.get_node("Weather").visible and not world.get_node("Reflections").visible,"rain and wet reflections disabled")
	world.toggle_rain()
	check(world.get_node("Weather").visible,"rain restored")
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
	check(InputMap.action_get_events("move_up").size() == 2 and InputMap.action_get_events("move_left")[1].physical_keycode == KEY_LEFT,"WASD and arrow bindings")
	print("MYU_TEST_RESULT checks=%d failures=%d" % [checks,failures])
	world.queue_free()
	await process_frame
	quit(1 if failures else 0)
