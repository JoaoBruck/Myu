extends Control
const PORTRAIT := preload("res://art/myu_portrait.png")
const FONT := preload("res://art/fonts/Tiny5-Regular.ttf")
const THOUGHT := "Quando será que sai a continuação daquele livro?"
var message := THOUGHT
var portrait_texture: Texture2D = PORTRAIT
var speaker_name := ""
var text_label: RichTextLabel
var age := 0.0
var revealed := false
func _ready() -> void:
	size = Vector2(392,112)
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var portrait := TextureRect.new()
	portrait.texture = portrait_texture
	portrait.visible = portrait_texture != null
	portrait.position = Vector2(14,16)
	portrait.size = Vector2(80,80)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)
	text_label = RichTextLabel.new()
	text_label.position = Vector2(108,18)
	text_label.size = Vector2(268,82)
	if portrait_texture == null:
		text_label.position = Vector2(18,38)
		text_label.size = Vector2(356,68)
	if not speaker_name.is_empty():
		var speaker := Label.new()
		speaker.position = Vector2(18,12)
		speaker.text = speaker_name
		speaker.add_theme_font_override("font",FONT)
		speaker.add_theme_font_size_override("font_size",16)
		speaker.add_theme_color_override("font_color",Color("d8bd94"))
		speaker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(speaker)
	text_label.add_theme_font_override("normal_font",FONT)
	text_label.add_theme_font_size_override("normal_font_size",20)
	text_label.add_theme_color_override("default_color",Color("ece5d8"))
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.scroll_active = false
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_label.text = message
	add_child(text_label)
	hide_bubble()
func show_at(feet: Vector2) -> void:
	position = Vector2(clampf(feet.x+40.0,20.0,612.0),clampf(feet.y-183.0,20.0,410.0)).round()
	age = 0.0
	revealed = false
	text_label.visible_characters = 0
	modulate.a = 0.0
	visible = true
	set_process(true)
func hide_bubble() -> void:
	visible = false
	set_process(false)
func reveal() -> void:
	revealed = true
	text_label.visible_characters = -1
func _process(delta: float) -> void:
	age += delta
	modulate.a = minf(age/0.18,1.0)
	if not revealed:
		text_label.visible_characters = int(age*34.0)
func _gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		reveal()
		accept_event()
func _draw() -> void:
	var outline := Color("8295b1")
	var ink := Color("172132")
	draw_rect(Rect2(2,5,392,112),Color(0.015,0.02,0.035,0.35))
	draw_rect(Rect2(Vector2.ZERO,size),outline)
	draw_rect(Rect2(2,2,size.x-4,size.y-4),ink)
	draw_colored_polygon(PackedVector2Array([Vector2(1,75),Vector2(-17,97),Vector2(1,91)]),outline)
	draw_colored_polygon(PackedVector2Array([Vector2(3,77),Vector2(-12,93),Vector2(3,88)]),ink)
	if portrait_texture != null:
		draw_rect(Rect2(12,14,84,84),Color("243348"))
	draw_line(Vector2(108,9),Vector2(151,9),Color("b6a382"),2.0)
