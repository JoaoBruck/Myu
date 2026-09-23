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
	for mode in 4:
		world.set_time_of_day(mode)
		await _save("lume_mode_%d" % mode)
	world.set_time_of_day(2)
	for entry in [["board",Vector2(516,429)],["sign",Vector2(1338,557)],["lamp",Vector2(1085,393)],["river",Vector2(1250,290)]]:
		world.player.position = entry[1]*(2.0/3.0)
		await _save("lume_"+entry[0])
	world.player.position = Vector2(414,337)
	world.get_node("CollisionDebug").visible = true
	await _save("lume_collision")
	print("MYU_RENDER_CAPTURE_OK")
	quit()
