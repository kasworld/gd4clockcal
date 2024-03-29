extends Node2D

func init(rt :Rect2, co1 :Color, co2 :Color)->void:
	$LabelInfo.size = rt.size
	$LabelInfo.position = rt.position
	$LabelInfo.label_settings = Global.make_label_setting(rt.size.y/8, co1, co2)
	height = rt.size.y # use to fontsize by line count

var height :float

func get_req_callable()->Dictionary:
	return {
		weather_success = weather_success,
		weather_fail = weather_fail,
		dayinfo_success = dayinfo_success,
		dayinfo_fail = dayinfo_fail,
		todayinfo_success = todayinfo_success,
		todayinfo_fail = todayinfo_fail,
	}

var weather_info :Array[String]
func weather_success(body)->void:
	var text = body.get_string_from_utf8()
	weather_info = split2list( text )
	update_info_label()
func weather_fail()->void:
	weather_info.clear()
	update_info_label()

var day_info = DayInfo.new()
func dayinfo_success(body)->void:
	day_info.make(body.get_string_from_utf8())
	update_info_label()
func dayinfo_fail()->void:
	day_info.clear()
	update_info_label()

var today_info :Array[String]
func todayinfo_success(body)->void:
	today_info = split2list( body.get_string_from_utf8().strip_edges() )
	update_info_label()
func todayinfo_fail()->void:
	today_info.clear()
	update_info_label()

func update_color()->void:
	var co = Global.colors.infolabel
	Global.set_label_color($LabelInfo, co, Global.make_shadow_color(co))

func update_info_label()->void:
	var dayinfo = day_info.get_daystringlist()
	var all = [make_date_string()]
	if weather_info.size() > 0:
		all.append_array(weather_info)		
	all.append_array(dayinfo)
	all.append_array(today_info)
	$LabelInfo.text = "\n".join(all)
	var line2calcfont = clampf(all.size(), 7, 20)
	var fontsize = height*0.9/line2calcfont
	Global.set_label_font_size($LabelInfo, fontsize )

# remove empty line
func split2list(text :String)->Array[String]:
	var lines = text.strip_edges().split("\n", false,0)
	var rtn :Array[String]
	for l in lines:
		if not l.is_empty():
			rtn.append(l.strip_edges())
	return rtn

func make_date_string()->String:
	var time_now_dict = Time.get_datetime_dict_from_system()
	return "%4d년%2d월%2d일 %s요일" % [
		time_now_dict["year"] , time_now_dict["month"] ,time_now_dict["day"],
		Global.weekdaystring[ time_now_dict["weekday"]]
		]

var old_time_dict = {"day":0} # datetime dict
func _on_timer_timeout() -> void:
	var time_now_dict = Time.get_datetime_dict_from_system()
	if old_time_dict["day"] != time_now_dict["day"]:
		old_time_dict = time_now_dict
		update_info_label()
