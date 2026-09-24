extends SceneTree
## Deterministic game import of newly generated art; the old reference is never imported.
func _initialize() -> void:
	_prepare("myu_seated_generated.png","myu_seated.png",Vector2i(32,56),44,54)
	_prepare("myu_portrait_generated.png","myu_portrait.png",Vector2i(48,48),46,47)
	print("MYU_SEATED_ART_IMPORTED")
	quit()
func _prepare(source_name: String, target: String, cell: Vector2i, height: int, baseline: int) -> void:
	var img := Image.load_from_file("res://source_art/"+source_name)
	assert(img != null and img.detect_alpha() != Image.ALPHA_NONE,"New sprite must have real transparency")
	img.convert(Image.FORMAT_RGBA8)
	img = img.get_region(img.get_used_rect())
	var width := mini(cell.x-2,roundi(float(img.get_width())/img.get_height()*height))
	img.resize(width,height,Image.INTERPOLATE_NEAREST)
	var result := Image.create(cell.x,cell.y,false,Image.FORMAT_RGBA8)
	result.blit_rect(img,Rect2i(Vector2i.ZERO,img.get_size()),Vector2i((cell.x-width)/2,baseline-height))
	assert(result.save_png("res://art/"+target) == OK)
