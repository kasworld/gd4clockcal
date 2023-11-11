extends Node2D

var enabled = false
var state = 0
var begin_tick = 0
var period = 1.0
var remain_step :int

func toggle()->void:
	if enabled:
		stop()
	else:
		start(period)

func start(p :float = 1)->void:
	period = p
	enabled = true
	begin_tick = Time.get_unix_time_from_system()
	$Timer.start(period)

# auto stop after step state change
func start_with_step(step :int, p :float = 1, )->void:
	remain_step = step
	start(p)

func stop()->void:
	enabled = false
	$Timer.stop()

func calc_inter(v1 :float, v2 :float, t :float)->float:
	return (cos(t *PI / period)/2 +0.5) * (v1-v2) + v2

func move_x_by_ms(o :Node2D, p1 :Vector2, p2 :Vector2, ms:float)->void:
	o.position.x = calc_inter(p1.x ,p2.x , ms)

func move_y_by_ms(o :Node2D, p1 :Vector2, p2 :Vector2, ms:float)->void:
	o.position.y = calc_inter(p1.y ,p2.y , ms)

func move_by_ms(o :Node2D, p1 :Vector2, p2 :Vector2, ms:float)->void:
	o.position.x = calc_inter(p1.x ,p2.x , ms)
	o.position.y = calc_inter(p1.y ,p2.y , ms)

func get_ms()->float:
	return Time.get_unix_time_from_system() - begin_tick

func _on_timer_timeout() -> void:
	state += 1
	begin_tick = Time.get_unix_time_from_system()
	if remain_step > 0 :
		remain_step -= 1
		stop()
