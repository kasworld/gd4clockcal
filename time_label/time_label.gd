extends Node2D

func init(rt :Rect2, co1 :Color, co2 :Color)->void:
	$LabelTime.size = rt.size
	$LabelTime.position = rt.position
	$LabelTime.label_settings = Global.make_label_setting(rt.size.x/4.5, co1, co2)
	_on_timer_timeout()

func update_color()->void:
	var co = Global.colors.timelabel
	Global.set_label_color($LabelTime, co, Global.make_shadow_color(co))

var old_time_dict = {"second":0} # datetime dict
func _on_timer_timeout() -> void:
	var time_now_dict = Time.get_datetime_dict_from_system()
	if old_time_dict["second"] != time_now_dict["second"]:
		old_time_dict = time_now_dict
		$LabelTime.text = "%02d:%02d:%02d" % [time_now_dict["hour"] , time_now_dict["minute"] ,time_now_dict["second"]  ]
