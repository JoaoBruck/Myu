extends Node2D
const Geometry = preload("res://data/lume_geometry.gd")
const DAY := preload("res://art/lume_day.png")
const GRADE := preload("res://shaders/time_grade.gdshader")
const WORLD_SIZE := Vector2(1024,576)
# 17:40 is the art direction, not a clock or a selectable time of day.
const AMBIENT := Color(0.74,0.82,1.0)
const CHARACTER_AMBIENT := Color(0.82,0.88,1.0)
var grade: ShaderMaterial
var foreground: Array[Polygon2D] = []
@onready var background: Sprite2D = $Background
@onready var collision_root: Node2D = $CollisionGeometry
@onready var depth_world: Node2D = $DepthWorld
@onready var player: CharacterBody2D = $DepthWorld/Player
func _ready() -> void:
	assert(DAY.get_size() == Vector2(1536,864))
	background.position = WORLD_SIZE*0.5
	background.scale = Vector2.ONE*Geometry.SCALE
	grade = ShaderMaterial.new()
	grade.shader = GRADE
	background.material = grade
	_build_collision_geometry()
	_build_depth_occluders()
	_apply_palette()
	for marker in ["MYU_HD_FILE_READY","MYU_HD_SOURCE_SIZE=(1536, 864)","MYU_PIXEL_BACKGROUND_READY","MYU_HD_BACKGROUND_READY","MYU_COLLISION_READY","MYU_DEPTH_READY","MYU_LUME_1740_READY"]:
		print(marker)
func _process(_delta: float) -> void:
	if grade == null:
		return
	var warmth := 0.0
	for source in [Vector2(480,315),Vector2(705,305),Vector2(1115,310),Vector2(1453,445)]:
		warmth = maxf(warmth,1.0-smoothstep(30.0,220.0,player.position.distance_to(source*Geometry.SCALE)))
	player.sprite.modulate = CHARACTER_AMBIENT.lerp(Color(1.06,0.96,0.88),warmth*0.45)
	grade.set_shader_parameter("cloud_cover",$Weather.intensity*0.035)
	$Reflections.wetness = $Weather.wetness
	$Reflections.rain_intensity = $Weather.intensity
func _apply_palette() -> void:
	background.texture = DAY
	grade.set_shader_parameter("ambient",AMBIENT)
	grade.set_shader_parameter("exposure",0.99)
	grade.set_shader_parameter("saturation",0.78)
	grade.set_shader_parameter("warm_preserve",0.98)
	var shadow := player.get_node("Shadow")
	shadow.sun_direction = Vector2(0.82,0.32)
	shadow.sun_length = 0.56
	shadow.lamp_strength = 0.85
	shadow.opacity = 0.19
func _build_collision_geometry() -> void:
	for entry in Geometry.blockers():
		var body := StaticBody2D.new()
		body.name = entry.name
		body.collision_layer = 1
		body.collision_mask = 2
		var shape := CollisionPolygon2D.new()
		shape.polygon = Geometry.to_world(entry.polygon)
		body.add_child(shape)
		collision_root.add_child(body)
func _build_depth_occluders() -> void:
	for entry in Geometry.occluders():
		var holder := Node2D.new()
		holder.name = entry.name
		holder.position.y = entry.base*Geometry.SCALE
		var polygon := Polygon2D.new()
		var points := PackedVector2Array()
		for source_point in entry.polygon:
			points.append(source_point*Geometry.SCALE-holder.position)
		polygon.polygon = points
		polygon.uv = entry.polygon
		polygon.texture = DAY
		polygon.material = grade
		polygon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		holder.add_child(polygon)
		depth_world.add_child(holder)
		foreground.append(polygon)
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_collision"):
		$CollisionDebug.visible = not $CollisionDebug.visible
		get_viewport().set_input_as_handled()
