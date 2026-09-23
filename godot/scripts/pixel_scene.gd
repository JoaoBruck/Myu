extends Node2D

const WORLD_SIZE := Vector2(1024, 576)
const HD_CHUNKS := [
	"res://assets_b64/lume_hd_0.b64",
	"res://assets_b64/lume_hd_1.b64",
	"res://assets_b64/lume_hd_2.b64",
	"res://assets_b64/lume_hd_3.b64",
	"res://assets_b64/lume_hd_4.b64",
]

@onready var background: Sprite2D = $Background
@onready var collision_root: Node2D = $CollisionGeometry
@onready var depth_world: Node2D = $DepthWorld

var _background_texture: Texture2D
var _source_size := Vector2.ZERO
var _source_to_world := Vector2.ONE

func _ready() -> void:
	_background_texture = _texture_from_b64_webp_chunks(HD_CHUNKS)
	if _background_texture == null:
		push_error("MYU: failed to decode HD Lume Cafe background")
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

func _texture_from_b64_webp_chunks(paths: Array) -> Texture2D:
	var encoded := ""
	for path in paths:
		var chunk := FileAccess.get_file_as_string(path).strip_edges()
		if chunk.is_empty():
			push_error("MYU: empty HD background chunk: " + str(path))
			return null
		encoded += chunk

	var bytes := Marshalls.base64_to_raw(encoded)
	if bytes.is_empty():
		push_error("MYU: invalid HD background base64")
		return null

	var image := Image.new()
	var error := image.load_webp_from_buffer(bytes)
	if error != OK:
		push_error("MYU: HD WebP decode failed error=" + str(error))
		return null

	print("MYU_HD_SOURCE_SIZE=" + str(image.get_size()))
	return ImageTexture.create_from_image(image)

func _build_collision_geometry() -> void:
	# Scene bounds.
	_add_static_rect(Vector2(512, 190), Vector2(1100, 18), "NorthWalkLimit")
	_add_static_rect(Vector2(512, 568), Vector2(1100, 18), "SouthWalkLimit")
	_add_static_rect(Vector2(8, 330), Vector2(16, 500), "WestLimit")
	_add_static_rect(Vector2(1016, 330), Vector2(16, 500), "EastLimit")

	# Café / patio.
	_add_static_rect(Vector2(240, 157), Vector2(480, 176), "CafeFacade")
	_add_static_rect(Vector2(292, 286), Vector2(155, 44), "CafeTables")
	_add_static_rect(Vector2(348, 319), Vector2(52, 50), "CafeBoard")

	# Street furniture / tree.
	_add_static_rect(Vector2(566, 256), Vector2(34, 104), "TreeTrunk")
	_add_static_rect(Vector2(654, 304), Vector2(118, 34), "Bench")
	_add_static_rect(Vector2(716, 258), Vector2(22, 124), "LampPost")
	_add_static_rect(Vector2(814, 306), Vector2(48, 56), "Bin")

	# Riverside rail and descending side.
	_add_static_rect(Vector2(870, 226), Vector2(300, 16), "RiverRailTop")
	_add_static_rect(Vector2(935, 317), Vector2(16, 132), "RiverRailSide")

	# Foreground architecture keeps the crosswalk corridor open.
	_add_static_rect(Vector2(116, 548), Vector2(232, 56), "ForegroundLeft")
	_add_static_rect(Vector2(930, 548), Vector2(188, 56), "ForegroundRight")

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
	# These polygons redraw selected pieces of the original HD scene above/below
	# the player according to each object's ground contact point.
	_add_textured_occluder(
		"TreeCanopy",
		[
			Vector2(630, 0), Vector2(1120, 0), Vector2(1135, 120),
			Vector2(1090, 220), Vector2(1010, 295), Vector2(890, 320),
			Vector2(780, 292), Vector2(690, 230), Vector2(650, 145)
		],
		430.0
	)
	_add_textured_occluder(
		"TreeTrunkFront",
		[
			Vector2(858, 215), Vector2(938, 215),
			Vector2(936, 455), Vector2(875, 455)
		],
		455.0
	)
	_add_textured_occluder(
		"MainLamp",
		[
			Vector2(1034, 35), Vector2(1092, 35),
			Vector2(1092, 500), Vector2(1034, 500)
		],
		500.0
	)
	_add_textured_occluder(
		"CafeBoardFront",
		[
			Vector2(438, 365), Vector2(540, 365),
			Vector2(540, 545), Vector2(438, 545)
		],
		545.0
	)
	_add_textured_occluder(
		"RightSignAndRail",
		[
			Vector2(1190, 355), Vector2(1515, 355), Vector2(1515, 605),
			Vector2(1450, 605), Vector2(1380, 535), Vector2(1190, 520)
		],
		605.0
	)
	_add_textured_occluder(
		"ForegroundUtility",
		[
			Vector2(1000, 585), Vector2(1225, 570), Vector2(1300, 864),
			Vector2(930, 864), Vector2(930, 705)
		],
		790.0
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
		var source := source_point as Vector2
		var world := source * _source_to_world
		world_points.append(world - holder.position)
		uv_points.append(source)

	polygon.polygon = world_points
	polygon.uv = uv_points
	polygon.texture = _background_texture
	polygon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	holder.add_child(polygon)
	depth_world.add_child(holder)
