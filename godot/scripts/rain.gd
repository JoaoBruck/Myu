extends Node2D
## Autonomous rain: slow transitions, dry pauses and persistent ground wetness.
const WORLD_SIZE := Vector2(1024,576)
const DROP_COUNT := 180
const CYCLE_SECONDS := 252.0
const KEY_TIMES := [0.0,48.0,112.0,148.0,192.0,222.0,252.0]
const KEY_INTENSITIES := [0.34,0.68,0.22,0.0,0.0,0.44,0.34]
var intensity := 0.34
var wetness := 0.72
var elapsed := 0.0
var wind := -0.14
var _drops: Array[Vector2] = []
var _speeds: Array[float] = []
var _rng := RandomNumberGenerator.new()
func _ready() -> void:
	_rng.seed = 1740
	for i in DROP_COUNT:
		_drops.append(Vector2(_rng.randf_range(0,1024),_rng.randf_range(0,576)))
		_speeds.append(_rng.randf_range(175.0,330.0))
	print("MYU_RAIN_READY")
	print("MYU_AUTO_WEATHER_READY")
func intensity_at(seconds: float) -> float:
	var moment := fposmod(seconds,CYCLE_SECONDS)
	for i in range(KEY_TIMES.size()-1):
		if moment <= KEY_TIMES[i+1]:
			var blend := smoothstep(KEY_TIMES[i],KEY_TIMES[i+1],moment)
			return lerpf(KEY_INTENSITIES[i],KEY_INTENSITIES[i+1],blend)
	return KEY_INTENSITIES[0]
func advance_weather(delta: float) -> void:
	elapsed = fposmod(elapsed+maxf(delta,0.0),CYCLE_SECONDS)
	intensity = intensity_at(elapsed)
	wind = -0.14+sin(elapsed*0.047)*0.045
	# Puddles linger through a dry spell instead of disappearing with the rain.
	var target_wetness := clampf(intensity*1.7,0.18,0.95)
	var rate := 0.035 if target_wetness > wetness else 0.006
	wetness = lerpf(wetness,target_wetness,1.0-exp(-rate*maxf(delta,0.0)))
func _process(delta: float) -> void:
	advance_weather(delta)
	for i in _drops.size():
		var speed := _speeds[i]
		var p := _drops[i]+Vector2(wind,1.0)*speed*delta
		if p.y > WORLD_SIZE.y+16.0:
			p.y = fposmod(p.y+16.0,WORLD_SIZE.y+32.0)-16.0
			p.x = _rng.randf_range(0.0,1100.0)
		_drops[i] = p
	queue_redraw()
func _draw() -> void:
	var amount := intensity*DROP_COUNT
	for i in mini(ceili(amount),_drops.size()):
		var layer := i%3
		var fade := clampf(amount-i,0.0,1.0)
		var alpha := (0.09+layer*0.035)*fade
		var length := 5.0+layer*3.0+float(i%4)
		draw_line(_drops[i],_drops[i]+Vector2(wind,1.0)*length,Color(0.70,0.80,0.94,alpha),1.0,true)
