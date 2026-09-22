extends Node2D

const WORLD_SIZE := Vector2(512, 288)

func _ready() -> void:
	_build_collision_geometry()
	_configure_camera()

func _configure_camera() -> void:
	var camera := get_node_or_null("Characters/Player/Camera2D") as Camera2D
	if camera == null:
		return
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(WORLD_SIZE.x)
	camera.limit_bottom = int(WORLD_SIZE.y)

func _build_collision_geometry() -> void:
	var root := get_node("CollisionGeometry")

	# World perimeter.
	_add_static_rect(root, Vector2(256, -6), Vector2(524, 12), "NorthBoundary")
	_add_static_rect(root, Vector2(256, 294), Vector2(524, 12), "SouthBoundary")
	_add_static_rect(root, Vector2(-6, 144), Vector2(12, 300), "WestBoundary")
	_add_static_rect(root, Vector2(518, 144), Vector2(12, 300), "EastBoundary")

	# Café façade / exterior furniture based on the approved TopDown scene.
	_add_static_rect(root, Vector2(131, 71), Vector2(262, 118), "CafeMass")
	_add_static_rect(root, Vector2(113, 143), Vector2(46, 14), "CafeTables")
	_add_static_rect(root, Vector2(175, 144), Vector2(26, 20), "CafeSign")

	# Tree, bench, lamp and bins.
	_add_static_rect(root, Vector2(267, 104), Vector2(18, 32), "TreeTrunk")
	_add_static_rect(root, Vector2(321, 143), Vector2(60, 15), "Bench")
	_add_static_rect(root, Vector2(365, 118), Vector2(10, 50), "LampPost")
	_add_static_rect(root, Vector2(414, 144), Vector2(24, 26), "Bin")

	# Riverside railings. Gaps intentionally remain where the stairs/path continue.
	_add_static_rect(root, Vector2(420, 109), Vector2(116, 8), "RiverRailTop")
	_add_static_rect(root, Vector2(460, 153), Vector2(8, 72), "RiverRailSide")

	# Foreground masses matching the lower frame of the source composition.
	_add_static_rect(root, Vector2(78, 269), Vector2(156, 38), "ForegroundLeft")
	_add_static_rect(root, Vector2(445, 273), Vector2(134, 30), "ForegroundRight")

func _add_static_rect(parent: Node, center: Vector2, size: Vector2, body_name: String) -> void:
	var body := StaticBody2D.new()
	body.name = body_name
	body.position = center

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape

	body.add_child(collision)
	parent.add_child(body)
