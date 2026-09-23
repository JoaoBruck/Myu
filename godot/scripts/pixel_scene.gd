extends Node2D
const Geometry = preload("res://data/lume_geometry.gd")
const DAY := preload("res://art/lume_day.png")
const NIGHT := preload("res://art/lume_night.png")
const GRADE := preload("res://shaders/time_grade.gdshader")
const WORLD_SIZE := Vector2(1024,576)
const TIME_LABELS := ["Manhã · 08:00","Dia · 13:00","Entardecer · 17:40","Noite · 21:00"]
const PROFILES := [
	{"ambient":Color(1.03,0.98,0.99),"exposure":1.04,"saturation":0.95,"warm":0.35,"sun":Vector2(-0.78,0.30),"length":0.50,"lamp":0.15},
	{"ambient":Color(1.0,0.99,1.0),"exposure":1.02,"saturation":1.0,"warm":0.35,"sun":Vector2(0.25,0.36),"length":0.24,"lamp":0.10},
	{"ambient":Color(0.84,0.82,1.0),"exposure":0.99,"saturation":0.91,"warm":0.95,"sun":Vector2(0.82,0.32),"length":0.66,"lamp":0.85},
	{"ambient":Color(0.75,0.77,0.97),"exposure":0.95,"saturation":0.92,"warm":1.0,"sun":Vector2(-0.30,0.30),"length":0.30,"lamp":1.0}
]
signal time_changed(index: int)
signal rain_changed(enabled: bool)
var time_index := 2
var rain_enabled := true
var grade: ShaderMaterial
var foreground: Array[Polygon2D] = []
@onready var background: Sprite2D = $Background
@onready var collision_root: Node2D = $CollisionGeometry
@onready var depth_world: Node2D = $DepthWorld
@onready var player: CharacterBody2D = $DepthWorld/Player
func _ready() -> void:
	assert(DAY.get_size() == Vector2(1536,864) and NIGHT.get_size() == DAY.get_size())
	background.position = WORLD_SIZE*0.5
	background.scale = Vector2.ONE*Geometry.SCALE
	grade = ShaderMaterial.new()
	grade.shader = GRADE
	background.material = grade
	_build_collision_geometry()
	_build_depth_occluders()
	set_time_of_day(time_index)
	for marker in ["MYU_HD_FILE_READY","MYU_HD_SOURCE_SIZE=(1536, 864)","MYU_PIXEL_BACKGROUND_READY","MYU_HD_BACKGROUND_READY","MYU_COLLISION_READY","MYU_DEPTH_READY","MYU_LUME_1740_READY"]:
		print(marker)
func _process(_delta: float) -> void:
	if grade == null:
		return
	var profile: Dictionary = PROFILES[time_index]
	var ambient: Color = profile.ambient
	var warmth := 0.0
	for source in [Vector2(480,315),Vector2(705,305),Vector2(1115,310),Vector2(1453,445)]:
		warmth = maxf(warmth,(1.0-smoothstep(30.0,220.0,player.position.distance_to(source*Geometry.SCALE)))*profile.lamp)
	player.sprite.modulate = ambient.lerp(Color(1.06,0.96,0.88),warmth*0.5)
func set_time_of_day(index: int) -> void:
	time_index = posmod(index,PROFILES.size())
	var profile: Dictionary = PROFILES[time_index]
	var texture: Texture2D = NIGHT if time_index == 3 else DAY
	background.texture = texture
	for polygon in foreground:
		polygon.texture = texture
	grade.set_shader_parameter("ambient",profile.ambient)
	grade.set_shader_parameter("exposure",profile.exposure)
	grade.set_shader_parameter("saturation",profile.saturation)
	grade.set_shader_parameter("warm_preserve",profile.warm)
	var shadow := player.get_node("Shadow")
	shadow.sun_direction = profile.sun
	shadow.sun_length = profile.length
	shadow.lamp_strength = profile.lamp
	shadow.opacity = 0.20 if time_index == 3 else 0.23
	$Reflections.modulate.a = profile.lamp
	time_changed.emit(time_index)
func cycle_time() -> void:
	set_time_of_day(time_index+1)
func toggle_rain() -> void:
	rain_enabled = not rain_enabled
	$Weather.visible = rain_enabled
	$Weather.set_process(rain_enabled)
	$Reflections.visible = rain_enabled
	rain_changed.emit(rain_enabled)
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
	if event.is_action_pressed("cycle_time"):
		cycle_time()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("toggle_rain"):
		toggle_rain()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("debug_collision"):
		$CollisionDebug.visible = not $CollisionDebug.visible
		get_viewport().set_input_as_handled()
