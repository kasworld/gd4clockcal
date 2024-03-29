extends Node2D

var calendar_labels = []

func init(rt :Rect2)->void:
	$GridCalendar.size = rt.size
	$GridCalendar.position = rt.position

	init_calendar_labels(rt.size.y/8)
	update_calendar()

func update_color()->void:
	for i in range(7): # week title + 6 week
		for j in Global.weekdaystring.size():
			var co = Global.colors.weekday[j]
			Global.set_label_color(calendar_labels[i][j], co, Global.make_shadow_color(co))
	update_calendar()

func init_calendar_labels(font_size :float)->void:
	# prepare calendar
	for _i in range(7): # week title + 6 week
		var ln = []
		for j in Global.weekdaystring.size():
			var lb = Label.new()
			lb.text = Global.weekdaystring[j]
			lb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lb.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
			lb.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
			var co = Global.colors.weekday[j]
			lb.label_settings = Global.make_label_setting(font_size, co, Global.make_shadow_color(co))
			$GridCalendar.add_child(lb)
			ln.append(lb)
		calendar_labels.append(ln)

func update_calendar()->void:
	var tz = Time.get_time_zone_from_system()
	var today = int(Time.get_unix_time_from_system()) +tz["bias"]*60
	var today_dict = Time.get_date_dict_from_unix_time(today)
	var day_index = today - (7 + today_dict["weekday"] )*24*60*60 #datetime.timedelta(days=(-today.weekday() - 7))

	for week in range(6):
		for wd in range(7):
			var day_index_dict = Time.get_date_dict_from_unix_time(day_index)
			var curLabel = calendar_labels[week+1][wd]
			curLabel.text = "%d" % day_index_dict["day"]
			var co = Global.colors.weekday[wd]
			if day_index_dict["month"] != today_dict["month"]:
				co = Global.make_shadow_color(co)
			elif day_index_dict["day"] == today_dict["day"]:
				co = Global.colors.today
			Global.set_label_color(curLabel, co, Global.make_shadow_color(co))
			day_index += 24*60*60

var old_time_dict = {"day":0} # datetime dict
func _on_timer_timeout() -> void:
	var time_now_dict = Time.get_datetime_dict_from_system()

	# date changed, update datelabel, calendar
	if old_time_dict["day"] != time_now_dict["day"]:
		old_time_dict = time_now_dict
		update_calendar()

