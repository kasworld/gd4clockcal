extends Node2D

var enabled = false
var state = 0
var begin_tick = 0

func toggle()->void:
	if enabled:
		stop()
	else:
		start()

func start()->void:
	enabled = true
	state = 0
	begin_tick = Time.get_unix_time_from_system()
	$Timer.start()

func stop()->void:
	enabled = false
	$Timer.stop()

func calc_inter(v1 :float, v2 :float, t :float)->float:
	return (cos(t *PI)/2 +0.5) * (v2-v1) + v1

func move_x_by_ms(o :Node2D, p1 :Vector2, p2 :Vector2, ms:float)->void:
	o.position.x = calc_inter(p1.x ,p2.x , ms)

func move_y_by_ms(o :Node2D, p1 :Vector2, p2 :Vector2, ms:float)->void:
	o.position.y = calc_inter(p1.y ,p2.y , ms)

func get_ms()->float:
	return Time.get_unix_time_from_system() - begin_tick

func _on_timer_timeout() -> void:
	state += 1
	begin_tick = Time.get_unix_time_from_system()
