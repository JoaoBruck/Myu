extends SceneTree
## Keep the generated source intact; trim invisible alpha noise for game import.
func _initialize() -> void:
	var art := Image.load_from_file("res://source_art/newsstand_generated.png")
	assert(art != null and art.detect_alpha() != Image.ALPHA_NONE)
	art.convert(Image.FORMAT_RGBA8)
	for y in art.get_height():
		for x in art.get_width():
			if art.get_pixel(x,y).a < 0.025:
				art.set_pixel(x,y,Color(0,0,0,0))
	art = art.get_region(art.get_used_rect())
	var height := roundi(126.0*art.get_height()/art.get_width())
	assert(height <= 110)
	art.resize(126,height,Image.INTERPOLATE_NEAREST)
	var cell := Image.create(128,112,false,Image.FORMAT_RGBA8)
	cell.blit_rect(art,Rect2i(Vector2i.ZERO,art.get_size()),Vector2i(1,110-height))
	assert(cell.save_png("res://art/newsstand.png") == OK)
	print("MYU_NEWSSTAND_ART_IMPORTED")
	quit()
