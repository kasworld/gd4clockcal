extends Node2D

func init(x :float, y :float, w :float, h :float, co1 :Color, co2 :Color):
	$LabelDay.size.x = w
	$LabelDay.size.y = h
	$LabelDay.position.x = x
	$LabelDay.position.y = y
	$LabelDay.label_settings = Global.make_label_setting(h/9, co1, co2)

	$LabelWeather.size.x = w
	$LabelWeather.size.y = h
	$LabelWeather.position.x = x
	$LabelWeather.position.y = y
	$LabelWeather.label_settings = Global.make_label_setting(h/9, co1, co2)

func invert_font_color()->void:
	Global.invert_label_color($LabelDay)
	Global.invert_label_color($LabelWeather)

func switch_info_label() :
	if $LabelDay.text == "":
		$LabelWeather.visible = true
		$LabelDay.visible = false
		return

	if $LabelWeather.text == "":
		$LabelWeather.visible = false
		$LabelDay.visible = true
		return

	$LabelWeather.visible = not $LabelWeather.visible
	$LabelDay.visible = not $LabelWeather.visible

func weather_success(body):
	var text = body.get_string_from_utf8()
	$LabelWeather.text = text
func weather_fail():
	pass

var day_info = DayInfo.new()
func dayinfo_success(body):
	day_info.make(body.get_string_from_utf8())
	update_info_label()
func dayinfo_fail():
	pass

var today_str = ""
func todayinfo_success(body):
	today_str = body.get_string_from_utf8().strip_edges()
	update_info_label()
func todayinfo_fail():
	pass

func update_info_label( ):
	var dayinfo = day_info.get_daystringlist()
	if len(dayinfo) > 0 :
		if today_str != "":
			$LabelDay.text = "\n".join(dayinfo) +"\n"+ today_str
		else :
			$LabelDay.text = "\n".join(dayinfo)
	else:
		$LabelDay.text = today_str
