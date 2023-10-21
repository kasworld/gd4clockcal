extends Node2D


func init(x :float, y :float, w :float, h :float, co1 :Color, co2 :Color):
	$LabelDate.size.x = w
	$LabelDate.size.y = h
	$LabelDate.position.x = x
	$LabelDate.position.y = y
	$LabelDate.label_settings = Global.make_label_setting(h, co1, co2)
	_on_timer_timeout()

var old_time_dict = {"day":0} # datetime dict
func _on_timer_timeout() -> void:
	var time_now_dict = Time.get_datetime_dict_from_system()
	if old_time_dict["day"] != time_now_dict["day"]:
		old_time_dict = time_now_dict
		$LabelDate.text = "%04d-%02d-%02d %s" % [
			time_now_dict["year"] , time_now_dict["month"] ,time_now_dict["day"],
			Global.weekdaystring[ time_now_dict["weekday"]]
			]
