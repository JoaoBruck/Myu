extends SceneTree
## Import the new foreground while retaining every approved café/river pixel.
func _initialize() -> void:
	var original := Image.load_from_file("res://art/lume_day.png")
	var courtyard := Image.load_from_file("res://source_art/courtyard_generated.png")
	assert(original != null and courtyard != null)
	courtyard.convert(Image.FORMAT_RGBA8)
	original.convert(Image.FORMAT_RGBA8)
	courtyard.resize(1536,864,Image.INTERPOLATE_NEAREST)
	courtyard.blit_rect(original,Rect2i(0,0,1536,464),Vector2i.ZERO)
	# This strip preserves the café pavement; only the obsolete left roof is removed.
	courtyard.blit_rect(original,Rect2i(256,464,1280,96),Vector2i(256,464))
	assert(courtyard.save_png("res://art/lume_courtyard.png") == OK)
	print("MYU_COURTYARD_ART_IMPORTED")
	quit()
