extends SceneTree
## Real renderer review: godot --path godot --script res://tools/capture_preview.gd -- OUTPUT_DIR
var world: Node2D
var destination := ""
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty() or DisplayServer.get_name() == "headless":
		push_error("Capture requires a renderer and an output directory.")
		quit(1)
		return
	destination = args[0]
	DirAccess.make_dir_recursive_absolute(destination)
	call_deferred("_capture")
func _save(filename: String) -> void:
	await create_timer(0.35).timeout
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image.is_empty() or image.save_png(destination.path_join(filename+".png")) != OK:
		push_error("Could not save "+filename)
		quit(1)
func _capture() -> void:
	world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	await process_frame
	await _save("lume_cold")
	var weather = world.get_node("Weather")
	weather.set_process(false)
	weather.elapsed = 160.0
	weather.advance_weather(0.0)
	weather.queue_redraw()
	await _save("lume_dry")
	weather.elapsed = 48.0
	weather.advance_weather(0.0)
	weather.queue_redraw()
	await _save("lume_rain")
	weather.set_process(true)
	for entry in [["board",Vector2(516,429)],["sign",Vector2(1338,557)],["lamp",Vector2(1085,393)],["river",Vector2(1250,290)],["utility_left",Vector2(1120,710)],["utility_right",Vector2(1155,730)],["edge",Vector2(1468,620)]]:
		world.player.position = entry[1]*(2.0/3.0)
		await _save("lume_"+entry[0])
	world.player.position = Vector2(340,461)*(2.0/3.0)
	await _save("lume_chair_prompt")
	var seat = world.get_node("SeatInteraction")
	seat.sit_down()
	await create_timer(1.8).timeout
	await _save("lume_seated_dialogue")
	var controls = world.get_node("MobileUI/MobileControls")
	controls.show_joystick = true
	controls.queue_redraw()
	await _save("lume_seated_mobile")
	seat.stand_up()
	await _save("lume_stood_up")
	controls.show_joystick = false
	controls.queue_redraw()
	var newsstand = world.get_node("DepthWorld/Newsstand")
	world.player.position = newsstand.APPROACH
	await _save("lume_newsstand_prompt")
	newsstand.interact()
	await create_timer(2.0).timeout
	await _save("lume_newsstand_dialogue")
	controls.show_joystick = true
	controls.queue_redraw()
	await _save("lume_newsstand_mobile")
	newsstand.close_dialogue()
	controls.show_joystick = false
	controls.queue_redraw()
	world.player.position = Vector2(414,337)
	world.get_node("CollisionDebug").visible = true
	await _save("lume_collision")
	world.get_node("CollisionDebug").visible = false
	world.player.set_physics_process(false)
	world.player.position = Vector2(340,425)
	for index in 72:
		for tick in 5:
			await physics_frame
			world.player.step_motion(Vector2.RIGHT if index < 36 else Vector2.LEFT,1.0/60.0)
		await RenderingServer.frame_post_draw
		var rendered := root.get_texture().get_image()
		var center: Vector2i = Vector2i(world.player.position)
		# Logical viewport is 1024x576; keep the character and nearby ground in view.
		var crop := rendered.get_region(Rect2i(center-Vector2i(96,148),Vector2i(192,192)))
		assert(crop.save_png(destination.path_join("motion_%03d.png" % index)) == OK)
	print("MYU_RENDER_CAPTURE_OK")
	quit()
