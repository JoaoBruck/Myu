extends Node2D

const COLD := Color("#17182a")
const STONE := Color("#343148")
const STONE_DARK := Color("#29283b")
const ROAD := Color("#171a2c")
const ROAD_WET := Color("#21253b")
const BUILDING := Color("#202033")
const BUILDING_EDGE := Color("#343047")
const WARM := Color("#f1a35d")
const WARM_SOFT := Color("#b96c4e")
const RED_LEAF := Color("#6f2735")
const RED_LEAF_DARK := Color("#472331")
const RAIL := Color("#141726")
const RIVER := Color("#1b2742")
const RIVER_LIGHT := Color("#374568")

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	_draw_river()
	_draw_architecture()
	_draw_promenade()
	_draw_road()
	_draw_tree()
	_draw_props()
	_draw_riverside()
	_draw_foreground()

func _draw_river() -> void:
	draw_rect(Rect2(360, 0, 152, 103), RIVER)
	for y in range(10, 98, 13):
		var offset := (y * 3) % 37
		draw_rect(Rect2(372 + offset, y, 46, 2), Color(RIVER_LIGHT, 0.42))
		draw_rect(Rect2(430 + (offset / 2), y + 5, 64, 1), Color("#7a5b61", 0.22))

func _draw_architecture() -> void:
	draw_rect(Rect2(0, 0, 281, 121), BUILDING)
	draw_rect(Rect2(0, 116, 281, 5), BUILDING_EDGE)

	# façade rhythm
	for x in [18, 55, 210, 260]:
		draw_rect(Rect2(x, 8, 4, 102), Color("#161624"))
	for y in [21, 52, 84]:
		draw_rect(Rect2(0, y, 281, 2), Color("#2d2b40"))

	# café awning and windows
	draw_rect(Rect2(111, 24, 127, 33), Color("#2a2638"))
	draw_rect(Rect2(118, 59, 76, 50), Color("#241f2e"))
	draw_rect(Rect2(121, 65, 68, 38), Color("#d68454"))
	draw_rect(Rect2(125, 69, 60, 30), Color("#5a3b3f"))
	draw_rect(Rect2(198, 62, 31, 47), Color("#3a2935"))
	draw_rect(Rect2(203, 69, 20, 32), Color("#b76647"))

	# warm window scatter
	draw_rect(Rect2(25, 87, 24, 21), Color("#9b523d"))
	draw_rect(Rect2(29, 91, 17, 14), Color("#df8652"))
	draw_rect(Rect2(136, 76, 8, 14), Color("#f1a35d"))
	draw_rect(Rect2(163, 75, 9, 13), Color("#c8734a"))

	# wall lamps
	_draw_lamp(Vector2(229, 77), 0.75)
	_draw_lamp(Vector2(349, 84), 0.9)

func _draw_promenade() -> void:
	draw_rect(Rect2(0, 121, 512, 77), STONE)
	for y in range(126, 195, 11):
		draw_line(Vector2(0, y), Vector2(512, y), Color("#44405b", 0.55), 1.0)
	for x in range(8, 512, 25):
		draw_line(Vector2(x, 121), Vector2(x - 10, 198), Color("#2b2b40", 0.44), 1.0)

	# tactile stripe / warm wet patches
	draw_rect(Rect2(0, 158, 427, 5), Color("#7b5b55", 0.42))
	for x in [36, 143, 242, 353]:
		draw_rect(Rect2(x, 160, 23, 3), Color(WARM, 0.25))

func _draw_road() -> void:
	draw_rect(Rect2(0, 198, 512, 90), ROAD)
	draw_rect(Rect2(0, 203, 512, 7), ROAD_WET)
	draw_rect(Rect2(0, 232, 512, 3), Color("#2b304b"))

	# crosswalk
	for x in range(12, 180, 31):
		draw_rect(Rect2(x, 214, 18, 70), Color("#8b8395", 0.34))

	# drain + manhole
	draw_circle(Vector2(282, 220), 11, Color("#121422"))
	draw_circle(Vector2(282, 220), 8, Color("#24283b"))
	draw_rect(Rect2(245, 195, 24, 3), Color("#10121d"))

func _draw_tree() -> void:
	draw_rect(Rect2(262, 69, 12, 69), Color("#291d29"))
	draw_rect(Rect2(266, 66, 5, 72), Color("#3e2932"))
	for p in [
		Vector2(247, 37), Vector2(271, 25), Vector2(292, 39),
		Vector2(244, 59), Vector2(286, 63), Vector2(263, 47),
		Vector2(310, 53), Vector2(232, 48)
	]:
		draw_circle(p, 24, RED_LEAF_DARK)
		draw_circle(p + Vector2(3, -3), 18, RED_LEAF)

func _draw_props() -> void:
	# café exterior plants/tables
	draw_rect(Rect2(74, 124, 8, 35), Color("#1b1c2b"))
	draw_rect(Rect2(92, 132, 38, 5), Color("#3d2a34"))
	draw_rect(Rect2(97, 137, 5, 20), Color("#211d2a"))
	draw_rect(Rect2(122, 137, 5, 20), Color("#211d2a"))
	draw_rect(Rect2(161, 129, 19, 28), Color("#2b2636"))

	# bench
	draw_rect(Rect2(291, 136, 61, 8), Color("#3e2933"))
	draw_rect(Rect2(296, 146, 52, 8), Color("#4f323a"))
	draw_rect(Rect2(299, 154, 5, 18), Color("#171824"))
	draw_rect(Rect2(342, 154, 5, 18), Color("#171824"))

	# lamp post
	draw_rect(Rect2(362, 95, 7, 78), Color("#151725"))
	draw_rect(Rect2(356, 102, 19, 5), Color("#1d1e2c"))
	_draw_lamp(Vector2(365, 81), 1.0)

	# bin and signs
	draw_rect(Rect2(403, 132, 28, 35), Color("#222434"))
	draw_rect(Rect2(405, 129, 24, 5), Color("#34374b"))
	for y in [150, 161, 172]:
		draw_rect(Rect2(437, y, 53, 9), Color("#29283a"))
		draw_rect(Rect2(481, y + 3, 5, 2), Color("#968298"))

func _draw_riverside() -> void:
	# riverside stones
	draw_rect(Rect2(371, 102, 141, 47), Color("#302f45"))
	for x in range(377, 510, 22):
		draw_line(Vector2(x, 105), Vector2(x - 5, 147), Color("#45425a", 0.45), 1.0)

	# top railing
	draw_rect(Rect2(372, 105, 140, 4), RAIL)
	for x in range(378, 511, 18):
		draw_rect(Rect2(x, 101, 5, 28), RAIL)

	# descending path at right
	var stair_poly := PackedVector2Array([
		Vector2(451, 149), Vector2(512, 171), Vector2(512, 215), Vector2(458, 190)
	])
	draw_colored_polygon(stair_poly, Color("#302f44"))
	for y in range(157, 202, 8):
		draw_line(Vector2(456, y), Vector2(512, y + 18), Color("#464258"), 1.0)

func _draw_foreground() -> void:
	draw_rect(Rect2(0, 247, 123, 41), Color("#0f111c"))
	draw_rect(Rect2(405, 258, 107, 30), Color("#10121d"))
	for p in [Vector2(55, 251), Vector2(93, 261), Vector2(424, 257), Vector2(474, 267)]:
		draw_circle(p, 25, Color("#291c2a"))
		draw_circle(p + Vector2(-6, -4), 17, RED_LEAF_DARK)

	# overhead utilities as foreground depth cue
	draw_line(Vector2(0, 239), Vector2(512, 232), Color("#10111b"), 3.0)
	draw_line(Vector2(0, 248), Vector2(512, 235), Color("#12131d"), 2.0)

func _draw_lamp(position: Vector2, strength: float) -> void:
	draw_circle(position, 12.0 * strength, Color(WARM, 0.08))
	draw_circle(position, 7.0 * strength, Color(WARM, 0.14))
	draw_rect(Rect2(position.x - 3, position.y - 6, 6, 12), Color("#e59a58"))
	draw_rect(Rect2(position.x - 5, position.y - 8, 10, 3), Color("#181925"))
