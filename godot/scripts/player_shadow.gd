extends Node2D
## Animated ground projection and contact shadow, responding to painted lights.
var direction := Vector2(0.78,0.34)
var length_factor := 0.60
var opacity := 0.22
var sun_direction := Vector2(0.78,0.34)
var sun_length := 0.60
var lamp_strength := 0.8
const LAMPS: Array[Vector2] = [Vector2(704,235),Vector2(1115,90),Vector2(1453,278)]
@onready var sprite: AnimatedSprite2D = get_node("../AnimatedSprite2D")
func _process(delta: float) -> void:
	var position_in_art := global_position*1.5
	var influence := 0.0
	var target_direction := sun_direction
	var target_length := sun_length
	for lamp in LAMPS:
		var ground_light := lamp+Vector2(0,220)
		var distance := position_in_art.distance_to(ground_light)
		var weight := (1.0-smoothstep(35.0,310.0,distance))*lamp_strength
		if weight > influence:
			influence = weight
			target_direction = sun_direction.lerp((position_in_art-ground_light).normalized()*Vector2(1.0,0.45),weight)
			target_length = lerpf(sun_length,0.28+distance/520.0,weight)
	var blend := 1.0-exp(-delta*7.0)
	direction = direction.lerp(target_direction,blend)
	length_factor = lerpf(length_factor,target_length,blend)
	queue_redraw()
func _draw() -> void:
	var points := PackedVector2Array()
	for i in 24:
		var angle := TAU*float(i)/24.0
		points.append(Vector2(cos(angle)*15.0,sin(angle)*4.5-2.0))
	draw_colored_polygon(points,Color(0.02,0.017,0.04,0.30))
	if not is_instance_valid(sprite) or sprite.sprite_frames == null:
		return
	var texture := sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame)
	var basis_x := Vector2(2.0,0.0)
	var basis_y := -direction*length_factor*2.0
	draw_set_transform_matrix(Transform2D(basis_x,basis_y,Vector2.ZERO))
	draw_texture_rect(texture,Rect2(-16,-55,32,56),false,Color(0.035,0.025,0.07,opacity))
	draw_set_transform_matrix(Transform2D.IDENTITY)
