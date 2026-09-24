extends Node2D
## Crisp, localized lettering replaces baked, malformed glyphs on both depth layers.
const FONT := preload("res://art/fonts/Tiny5-Regular.ttf")
const SCALE := 2.0/3.0
const INK := Color("c5cddb")
var kind: StringName = &"CafeBoard"
func _draw() -> void:
	if kind == &"CafeBoard":
		_line("ESPRESSO",Rect2(484,351,62,16),10)
		_line("CAPPUCCINO",Rect2(484,373,62,16),10)
		_line("BOLO DO DIA",Rect2(484,395,62,16),10)
		_line("CHÁ QUENTE",Rect2(481,418,68,15),9)
		var heart := PackedVector2Array([Vector2(512,437),Vector2(509,434),Vector2(506,437),Vector2(512,443),Vector2(518,437),Vector2(515,434),Vector2(512,437)])
		for i in range(heart.size()-1):
			draw_line((heart[i]*SCALE).round(),(heart[i+1]*SCALE).round(),INK,1.0)
	else:
		for entry in [["Centro",430.0],["Rio",468.0],["Memórias",507.0]]:
			var y: float = entry[1]
			_line(entry[0],Rect2(1276,y,98,18),12,false)
			var tip := (Vector2(1389,y+10)*SCALE).round()
			draw_line(tip-Vector2(12,0),tip,INK,1.0)
			draw_line(tip-Vector2(4,4),tip,INK,1.0)
			draw_line(tip-Vector2(4,-4),tip,INK,1.0)
func _line(value: String, source_rect: Rect2, font_size: int, centered: bool = true) -> void:
	var rect := Rect2(source_rect.position*SCALE,source_rect.size*SCALE)
	var width := FONT.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
	var x := rect.position.x+(rect.size.x-width)*0.5 if centered else rect.position.x
	var baseline := rect.position.y+(rect.size.y+FONT.get_ascent(font_size)-FONT.get_descent(font_size))*0.5
	draw_string(FONT,Vector2(x,baseline).round(),value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,INK)
