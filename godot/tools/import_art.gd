extends SceneTree
## Import original JPEGs and supplied sprite poses without inventing frames.
func _initialize() -> void:
	for period in ["day","night"]:
		var backdrop := Image.load_from_file("res://source_art/lume_%s.jpg" % period)
		assert(backdrop != null and backdrop.get_size() == Vector2i(1536,864))
		assert(backdrop.save_png("res://art/lume_%s.png" % period) == OK)
	var source := Image.load_from_file("res://source_art/myu_reference.jpg")
	assert(source != null and source.get_size() == Vector2i(1229,1536))
	var atlas := Image.create(192,280,false,Image.FORMAT_RGBA8)
	var row_y := [58,378,669,948,1206]
	var row_h := [290,270,260,238,240]
	for row in 5:
		for column in (4 if row == 0 else 6):
			var x: int = 260+column*192 if row == 0 else 236+column*154
			var crop := source.get_region(Rect2i(x,row_y[row],166 if row == 0 else 148,row_h[row]))
			crop.convert(Image.FORMAT_RGBA8)
			_remove_border_matte(crop)
			_remove_speckles(crop)
			var bounds := crop.get_used_rect()
			assert(bounds.size.y > 100,"Missing character in crop")
			crop = crop.get_region(bounds)
			var width := mini(30,roundi(float(crop.get_width())/crop.get_height()*53.0))
			crop.resize(width,53,Image.INTERPOLATE_NEAREST)
			atlas.blit_rect(crop,Rect2i(Vector2i.ZERO,crop.get_size()),Vector2i(column*32+(32-width)/2,row*56+2))
	assert(atlas.save_png("res://art/myu_walk.png") == OK)
	print("MYU_ART_IMPORT_OK")
	quit()
func _is_matte(c: Color) -> bool:
	return c.r < 0.17 and c.g < 0.20 and c.b < 0.29 and c.b > c.r*1.04 and c.g >= c.r*0.90
func _remove_border_matte(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var seen := PackedByteArray()
	seen.resize(w*h)
	var queue: Array[Vector2i] = []
	for x in w:
		queue.append(Vector2i(x,0))
		queue.append(Vector2i(x,h-1))
	for y in h:
		queue.append(Vector2i(0,y))
		queue.append(Vector2i(w-1,y))
	var cursor := 0
	while cursor < queue.size():
		var p := queue[cursor]
		cursor += 1
		if p.x < 0 or p.y < 0 or p.x >= w or p.y >= h:
			continue
		var index := p.y*w+p.x
		if seen[index]:
			continue
		seen[index] = 1
		if not _is_matte(img.get_pixelv(p)):
			continue
		img.set_pixelv(p,Color.TRANSPARENT)
		for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			queue.append(p+offset)
func _remove_speckles(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var seen := PackedByteArray()
	seen.resize(w*h)
	var retained: Array[Vector2i] = []
	for y in h:
		for x in w:
			var p := Vector2i(x,y)
			if seen[y*w+x] or img.get_pixelv(p).a == 0:
				continue
			var component: Array[Vector2i] = [p]
			seen[y*w+x] = 1
			var cursor := 0
			while cursor < component.size():
				var current := component[cursor]
				cursor += 1
				for dy in range(-1,2):
					for dx in range(-1,2):
						var next := current+Vector2i(dx,dy)
						if next.x < 0 or next.y < 0 or next.x >= w or next.y >= h:
							continue
						var index := next.y*w+next.x
						if not seen[index] and img.get_pixelv(next).a > 0:
							seen[index] = 1
							component.append(next)
			# Keep disconnected head/scarf parts; remove only JPEG speckles.
			if component.size() >= 32:
				retained.append_array(component)
	var mask := Image.create(w,h,false,Image.FORMAT_RGBA8)
	for p in retained:
		mask.set_pixelv(p,img.get_pixelv(p))
	img.copy_from(mask)
