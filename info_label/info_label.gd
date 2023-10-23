extends Node2D

func init(x :float, y :float, w :float, h :float, co1 :Color, co2 :Color):
	$LabelInfo.size.x = w
	$LabelInfo.size.y = h
	$LabelInfo.position.x = x
	$LabelInfo.position.y = y
	$LabelInfo.label_settings = Global.make_label_setting(h/9, co1, co2)

func invert_font_color()->void:
	Global.invert_label_color($LabelInfo)

func switch_info_label() :
	pass

var weather_info :Array[String]
func weather_success(body):
	var text = body.get_string_from_utf8()
	weather_info = split2list( text )
	update_info_label()
func weather_fail():
	pass

var day_info = DayInfo.new()
func dayinfo_success(body):
	day_info.make(body.get_string_from_utf8())
	update_info_label()
func dayinfo_fail():
	pass

var today_info :Array[String]
func todayinfo_success(body):
	today_info = split2list( body.get_string_from_utf8().strip_edges() )
	update_info_label()
func todayinfo_fail():
	pass

func update_info_label( ):
	var dayinfo = day_info.get_daystringlist()
	var all = []
	all.append_array(dayinfo)
	all.append_array(today_info)
	all.append_array(weather_info)
	$LabelInfo.text = "\n".join(all)

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
	return "%04d-%02d-%02d %s" % [
		time_now_dict["year"] , time_now_dict["month"] ,time_now_dict["day"],
		Global.weekdaystring[ time_now_dict["weekday"]]
		]
