extends Node2D
## Crisp, localized lettering replaces baked, malformed glyphs on both depth layers.
const FONT := preload("res://art/fonts/Tiny5-Regular.ttf")
const SCALE := 2.0/3.0
const INK := Color("d6d2cb")
const ACCENT := Color("d4a06f")
const BOARD_BG := Color("202333")
const BOARD_EDGE := Color("817b83")
var kind: StringName = &"CafeBoard"

func _draw() -> void:
	if kind == &"CafeBoard":
		_draw_cafe_board()
	else:
		for entry in [["Centro",430.0],["Rio",468.0],["Memórias",507.0]]:
			var y: float = entry[1]
			_line(entry[0],Rect2(1276,y,98,18),12,false)
			var tip := (Vector2(1389,y+10)*SCALE).round()
			draw_line(tip-Vector2(12,0),tip,INK,1.0)
			draw_line(tip-Vector2(4,4),tip,INK,1.0)
			draw_line(tip-Vector2(4,-4),tip,INK,1.0)

func _draw_cafe_board() -> void:
	# Cover the baked placeholder lettering so the outdoor board reads as an
	# actual café menu instead of decorative/random text.
	var panel := Rect2(477,345,77,104)
	var rect := Rect2(panel.position*SCALE,panel.size*SCALE)
	draw_rect(rect,BOARD_BG)
	draw_rect(rect,BOARD_EDGE,false,1.0)
	draw_rect(Rect2(rect.position+Vector2(2,2),rect.size-Vector2(4,4)),Color("343648"),false,1.0)

	_line("LUME",Rect2(482,349,67,17),11)
	_line("CAFÉ",Rect2(482,365,67,14),8)
	var divider_y := roundf(382.0*SCALE)
	draw_line(Vector2(485*SCALE,divider_y),Vector2(546*SCALE,divider_y),ACCENT,1.0)

	_line("ESPRESSO",Rect2(481,386,69,14),7)
	_line("CAPPUCCINO",Rect2(480,401,71,14),7)
	_line("BOLO DO DIA",Rect2(480,416,71,14),7)

	# Tiny cup mark at the foot of the board; simple enough to stay legible in
	# the game's native pixel scale.
	var cup := Rect2(Vector2(507,434)*SCALE,Vector2(15,7)*SCALE)
	draw_rect(cup,ACCENT,false,1.0)
	draw_line(Vector2(510,433)*SCALE,Vector2(510,429)*SCALE,INK,1.0)
	draw_line(Vector2(515,433)*SCALE,Vector2(515,428)*SCALE,INK,1.0)
	draw_arc(Vector2(523,437)*SCALE,4.0*SCALE,-PI/2.0,PI/2.0,5,ACCENT,1.0)

func _line(value: String, source_rect: Rect2, font_size: int, centered: bool = true) -> void:
	var rect := Rect2(source_rect.position*SCALE,source_rect.size*SCALE)
	var width := FONT.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
	var x := rect.position.x+(rect.size.x-width)*0.5 if centered else rect.position.x
	var baseline := rect.position.y+(rect.size.y+FONT.get_ascent(font_size)-FONT.get_descent(font_size))*0.5
	draw_string(FONT,Vector2(x,baseline).round(),value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,INK)
