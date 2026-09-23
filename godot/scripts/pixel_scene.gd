extends Node2D

const WORLD_SIZE := Vector2(1024, 576)

@onready var background: Sprite2D = $Background
@onready var collision_root: Node2D = $CollisionGeometry
@onready var depth_world: Node2D = $DepthWorld

var _background_texture: Texture2D
var _source_size := Vector2.ZERO
var _source_to_world := Vector2.ONE

func _ready() -> void:
	_background_texture = _load_hd_background()
	if _background_texture == null:
		push_error("MYU: failed to load HD Lume Cafe background")
		return

	_source_size = _background_texture.get_size()
	_source_to_world = Vector2(
		WORLD_SIZE.x / _source_size.x,
		WORLD_SIZE.y / _source_size.y
	)

	background.texture = _background_texture
	background.position = WORLD_SIZE * 0.5
	background.scale = _source_to_world
	background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	_build_collision_geometry()
	_build_depth_occluders()

	print("MYU_PIXEL_BACKGROUND_READY")
	print("MYU_HD_BACKGROUND_READY")
	print("MYU_COLLISION_READY")
	print("MYU_DEPTH_READY")

func _load_hd_background() -> Texture2D:
	var hd_path := "res://assets/lume_cafe_hd.png"
	var image := Image.new()
	var error := image.load(hd_path)

	if error != OK:
		push_error("MYU: HD PNG load failed error=" + str(error))
		return null

	if image.get_size() != Vector2i(1672, 941):
		push_error("MYU: unexpected HD source size=" + str(image.get_size()))
		return null

	print("MYU_HD_FILE_READY")
	print("MYU_HD_SOURCE_SIZE=" + str(image.get_size()))
	return ImageTexture.create_from_image(image)

func _build_collision_geometry() -> void:
	# World perimeter. The lower corners remain blocked while the crosswalk stays open.
	_add_static_rect(Vector2(512, 184), Vector2(1100, 16), "NorthWalkLimit")
	_add_static_rect(Vector2(512, 568), Vector2(1100, 16), "SouthWalkLimit")
	_add_static_rect(Vector2(8, 360), Vector2(16, 430), "WestLimit")
	_add_static_rect(Vector2(1016, 360), Vector2(16, 430), "EastLimit")

	# Café façade and exterior furniture, aligned to the 1672×941 source.
	_add_static_rect(Vector2(247, 143), Vector2(494, 254), "CafeFacade")
	_add_static_rect(Vector2(254, 250), Vector2(138, 54), "CafeTables")
	_add_static_rect(Vector2(342, 252), Vector2(50, 70), "CafeBoard")
	_add_static_rect(Vector2(455, 258), Vector2(38, 70), "CafePlanters")

	# Tree / bench / lamp / bin.
	_add_static_rect(Vector2(563, 248), Vector2(40, 96), "TreeTrunk")
	_add_static_rect(Vector2(628, 258), Vector2(92, 30), "Bench")
	_add_static_rect(Vector2(716, 246), Vector2(22, 122), "LampPost")
	_add_static_rect(Vector2(793, 255), Vector2(44, 52), "Bin")

	# Riverside guard rails and the right descending path.
	_add_static_rect(Vector2(875, 167), Vector2(292, 18), "UpperRiverRail")
	_add_static_rect(Vector2(702, 211), Vector2(276, 14), "FrontRiverRail")
	_add_static_rect(Vector2(936, 329), Vector2(16, 154), "RightRampRail")
	_add_static_rect(Vector2(844, 313), Vector2(58, 74), "DirectionSign")

	# Foreground masses: they close the corners but preserve the central road/crosswalk.
	_add_static_rect(Vector2(112, 548), Vector2(224, 56), "ForegroundLeft")
	_add_static_rect(Vector2(927, 548), Vector2(194, 56), "ForegroundRight")

func _add_static_rect(center: Vector2, size: Vector2, body_name: String) -> void:
	var body := StaticBody2D.new()
	body.name = body_name
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 1

	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	shape_node.shape = shape

	body.add_child(shape_node)
	collision_root.add_child(body)

func _build_depth_occluders() -> void:
	# Re-draw selected regions of the original scene inside the y-sorted layer.
	# The player therefore passes naturally behind the original painted objects.
	_add_textured_occluder(
		"TreeCanopy",
		[
			Vector2(620, 0), Vector2(1140, 0), Vector2(1150, 120),
			Vector2(1110, 220), Vector2(1045, 290), Vector2(980, 330),
			Vector2(885, 330), Vector2(795, 290), Vector2(710, 235),
			Vector2(650, 155)
		],
		430.0
	)
	_add_textured_occluder(
		"TreeTrunkFront",
		[
			Vector2(880, 165), Vector2(988, 165),
			Vector2(980, 458), Vector2(895, 458)
		],
		458.0
	)
	_add_textured_occluder(
		"MainLamp",
		[
			Vector2(1142, 42), Vector2(1210, 42),
			Vector2(1210, 482), Vector2(1142, 482)
		],
		482.0
	)
	_add_textured_occluder(
		"BenchFront",
		[
			Vector2(958, 348), Vector2(1110, 348),
			Vector2(1110, 466), Vector2(958, 466)
		],
		466.0
	)
	_add_textured_occluder(
		"CafeBoardFront",
		[
			Vector2(515, 348), Vector2(606, 348),
			Vector2(606, 466), Vector2(515, 466)
		],
		466.0
	)
	_add_textured_occluder(
		"RightDirectionSign",
		[
			Vector2(1330, 412), Vector2(1468, 412),
			Vector2(1468, 575), Vector2(1330, 575)
		],
		575.0
	)
	_add_textured_occluder(
		"RightRampFrontRail",
		[
			Vector2(1432, 388), Vector2(1672, 388), Vector2(1672, 690),
			Vector2(1600, 690), Vector2(1510, 590), Vector2(1432, 520)
		],
		690.0
	)
	_add_textured_occluder(
		"ForegroundUtility",
		[
			Vector2(1115, 646), Vector2(1270, 640), Vector2(1330, 941),
			Vector2(1010, 941), Vector2(1035, 785)
		],
		900.0
	)
	_add_textured_occluder(
		"ForegroundLeftMass",
		[
			Vector2(0, 500), Vector2(255, 500), Vector2(500, 700),
			Vector2(500, 941), Vector2(0, 941)
		],
		900.0
	)
	_add_textured_occluder(
		"ForegroundRightMass",
		[
			Vector2(1370, 590), Vector2(1672, 570),
			Vector2(1672, 941), Vector2(1335, 941)
		],
		900.0
	)

func _add_textured_occluder(
	occluder_name: String,
	source_points: Array,
	base_source_y: float
) -> void:
	var holder := Node2D.new()
	holder.name = occluder_name
	holder.position = Vector2(0, base_source_y * _source_to_world.y)

	var polygon := Polygon2D.new()
	var world_points := PackedVector2Array()
	var uv_points := PackedVector2Array()

	for source_point in source_points:
		var source: Vector2 = source_point
		var world := source * _source_to_world
		world_points.append(world - holder.position)
		uv_points.append(source)

	polygon.polygon = world_points
	polygon.uv = uv_points
	polygon.texture = _background_texture
	polygon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	holder.add_child(polygon)
	depth_world.add_child(holder)
