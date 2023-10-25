extends Node2D

func init(x :float, y :float, w :float, h :float, co1 :Color, co2 :Color):
	$LabelTime.size.x = w
	$LabelTime.size.y = h
	$LabelTime.position.x = x
	$LabelTime.position.y = y
	$LabelTime.label_settings = Global.make_label_setting(w/4.5, co1, co2)
	_on_timer_timeout()

var old_time_dict = {"second":0} # datetime dict
func _on_timer_timeout() -> void:
	var time_now_dict = Time.get_datetime_dict_from_system()
	if old_time_dict["second"] != time_now_dict["second"]:
		old_time_dict = time_now_dict
		$LabelTime.text = "%02d:%02d:%02d" % [time_now_dict["hour"] , time_now_dict["minute"] ,time_now_dict["second"]  ]
