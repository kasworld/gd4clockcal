extends Node2D

var calendar_labels = []

func init(x :float,y :float, w :float,h :float):
	$GridCalendar.size.x = w
	$GridCalendar.size.y = h
	$GridCalendar.position.x = x
	$GridCalendar.position.y = y

	init_calendar_labels(h/8)
	update_calendar()

func invert_font_color()->void:
	for l in calendar_labels:
		for lb in l:
			Global.invert_label_color(lb)

func init_calendar_labels(font_size :float):
	# prepare calendar
	for _i in range(7): # week title + 6 week
		var ln = []
		for j in Global.weekdaystring.size():
			var lb = Label.new()
			lb.text = Global.weekdaystring[j]
			lb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lb.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
			lb.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
			var fi = Global.weekdayColorInfo[j]
			lb.label_settings = Global.make_label_setting(font_size, fi[0], fi[1])
			$GridCalendar.add_child(lb)
			ln.append(lb)
		calendar_labels.append(ln)

func update_calendar():
	var tz = Time.get_time_zone_from_system()
	var today = int(Time.get_unix_time_from_system()) +tz["bias"]*60
	var todayDict = Time.get_date_dict_from_unix_time(today)
	var dayIndex = today - (7 + todayDict["weekday"] )*24*60*60 #datetime.timedelta(days=(-today.weekday() - 7))

	for week in range(6):
		for wd in range(7):
			var dayIndexDict = Time.get_date_dict_from_unix_time(dayIndex)
			var curLabel = calendar_labels[week+1][wd]
			curLabel.text = "%d" % dayIndexDict["day"]
			var co = Global.weekdayColorInfo[wd][0]
			if dayIndexDict["month"] != todayDict["month"]:
				co = Global.weekdayColorInfo[wd][1]
			elif dayIndexDict["day"] == todayDict["day"]:
				co = Global.todayColor
			Global.set_label_color(curLabel, co, co.darkened(0.5))
			dayIndex += 24*60*60

var old_time_dict = {"day":0} # datetime dict
func _on_timer_timeout() -> void:
	var time_now_dict = Time.get_datetime_dict_from_system()

	# date changed, update datelabel, calendar
	if old_time_dict["day"] != time_now_dict["day"]:
		old_time_dict = time_now_dict
		update_calendar()

