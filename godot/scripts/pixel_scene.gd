extends Node2D

@onready var background: Sprite2D = $Background

func _ready() -> void:
	background.texture = _texture_from_b64_webp("res://assets_b64/lume_cafe.b64")
	if background.texture == null:
		push_error("MYU: failed to decode Lume Cafe pixel background")
	else:
		print("MYU_PIXEL_BACKGROUND_READY")

func _texture_from_b64_webp(path: String) -> Texture2D:
	var encoded := FileAccess.get_file_as_string(path).strip_edges()
	if encoded.is_empty():
		push_error("MYU: empty base64 asset: " + path)
		return null
	var bytes := Marshalls.base64_to_raw(encoded)
	if bytes.is_empty():
		push_error("MYU: invalid base64 asset: " + path)
		return null
	var image := Image.new()
	var error := image.load_webp_from_buffer(bytes)
	if error != OK:
		push_error("MYU: WebP decode failed for " + path + " error=" + str(error))
		return null
	return ImageTexture.create_from_image(image)
