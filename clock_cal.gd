extends Node2D

var request_dict = {
	"weather_url" : null,
	"dayinfo_url" : null,
	"todayinfo_url" : null,
	"background_url" : null,
}

func weather_success(body):
	var text = body.get_string_from_utf8()
	$LabelWeather.text = text
func weather_fail():
	pass

var day_info = DayInfo.new()
func dayinfo_success(body):
	day_info.make(body.get_string_from_utf8())
	updateDayInfoLabel()
func dayinfo_fail():
	pass

var today_str = ""
func todayinfo_success(body):
	today_str = body.get_string_from_utf8().strip_edges()
	updateDayInfoLabel()
func todayinfo_fail():
	pass

func updateDayInfoLabel( ):
	var dayinfo = day_info.get_daystringlist()
	if len(dayinfo) > 0 :
		if today_str != "":
			$LabelDayInfo.text = "\n".join(dayinfo) +"\n"+ today_str
		else :
			$LabelDayInfo.text = "\n".join(dayinfo)
	else:
		$LabelDayInfo.text = today_str

var bgImage :Image
func bgimage_success(body):
	var image_error = bgImage.load_png_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image.")
	else:
		var bgTexture = ImageTexture.create_from_image(bgImage)
		bgTexture.set_size_override(get_viewport_rect().size)
		$BackgroundSprite.texture = bgTexture
func bgimage_fail():
	pass

const weekdaystring = ["일","월","화","수","목","금","토"]
const weekdayColorList = [
	Color.RED,  # sunday
	Color.BLACK,  # monday
	Color.BLACK,
	Color.BLACK,
	Color.BLACK,
	Color.BLACK,
	Color.BLUE,  # saturday
]

func setfontshadow(o, fontcolor,offset):
	o.add_theme_color_override("font_color", fontcolor )
	o.add_theme_color_override("font_shadow_color", fontcolor.lightened(0.5) )
	o.add_theme_constant_override("shadow_offset_x",offset)
	o.add_theme_constant_override("shadow_offset_y",offset)

var calendar_labels = []
func init_calendar_labels():
	# prepare calendar
	for _i in range(7): # week title + 6 week
		var ln = []
		for j in weekdaystring.size():
			var lb = Label.new()
			lb.text = weekdaystring[j]
			lb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lb.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
			lb.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
			setfontshadow(lb, weekdayColorList[j], 6)
			$GridCalendar.add_child(lb)
			ln.append(lb)
		calendar_labels.append(ln)

# Called when the node enters the scene tree for the first time.
func _ready():
	$PanelOption.config_changed.connect(config_changed)

	request_dict["weather_url"] = MyHTTPRequest.new(
		$PanelOption.cfg.config["weather_url"],
		60,
		weather_success,
		weather_fail,
	)
	request_dict["dayinfo_url"] = MyHTTPRequest.new(
		$PanelOption.cfg.config["dayinfo_url"],
		60,
		dayinfo_success,
		dayinfo_fail,
	)
	request_dict["todayinfo_url"] = MyHTTPRequest.new(
		$PanelOption.cfg.config["todayinfo_url"],
		60,
		todayinfo_success,
		todayinfo_fail,
	)
	request_dict["background_url"] = MyHTTPRequest.new(
		$PanelOption.cfg.config["background_url"],
		60,
		bgimage_success,
		bgimage_fail,
	)

	for k in request_dict:
		add_child(request_dict[k])

	var wh = get_viewport_rect().size
	bgImage = Image.create(wh.x,wh.y,true,Image.FORMAT_RGBA8)

	setfontshadow($LabelTime, Color.BLACK, 10)
	setfontshadow($LabelDate, Color.BLACK, 8)
	setfontshadow($LabelWeather, Color.BLACK, 6)
	setfontshadow($LabelDayInfo, Color.BLACK, 6)

	init_calendar_labels()

func switchWeatherDayInfo() :
	if $LabelDayInfo.text == "":
		$LabelWeather.visible = true
		$LabelDayInfo.visible = false
		return

	if $LabelWeather.text == "":
		$LabelWeather.visible = false
		$LabelDayInfo.visible = true
		return

	$LabelWeather.visible = not $LabelWeather.visible
	$LabelDayInfo.visible = not $LabelWeather.visible

var oldDateUpdate = {"day":0} # datetime dict
func _on_timer_timeout():
	switchWeatherDayInfo()

	var timeNowDict = Time.get_datetime_dict_from_system()

	# update every 1 second
	$LabelTime.text = "%02d:%02d:%02d" % [timeNowDict["hour"] , timeNowDict["minute"] ,timeNowDict["second"]  ]

	# date changed, update datelabel, calendar
	if oldDateUpdate["day"] != timeNowDict["day"]:
		oldDateUpdate = timeNowDict
		$LabelDate.text = "%04d-%02d-%02d %s" % [
			timeNowDict["year"] , timeNowDict["month"] ,timeNowDict["day"],
			weekdaystring[ timeNowDict["weekday"]]
			]
		updateCalendar()
		updateDayInfoLabel()

func updateCalendar():
	var tz = Time.get_time_zone_from_system()
	var today = int(Time.get_unix_time_from_system()) +tz["bias"]*60
	var todayDict = Time.get_date_dict_from_unix_time(today)
	var dayIndex = today - (7 + todayDict["weekday"] )*24*60*60 #datetime.timedelta(days=(-today.weekday() - 7))

	for week in range(6):
		for wd in range(7):
			var dayIndexDict = Time.get_date_dict_from_unix_time(dayIndex)
			var curLabel = calendar_labels[week+1][wd]
			curLabel.text = "%d" % dayIndexDict["day"]
			var co = weekdayColorList[wd]
			if dayIndexDict["month"] != todayDict["month"]:
				co = co.lightened(0.5)
			elif dayIndexDict["day"] == todayDict["day"]:
				co = Color.GREEN
			curLabel.add_theme_color_override("font_color",  co )
			curLabel.add_theme_color_override("font_shadow_color",  co.lightened(0.5) )
			dayIndex += 24*60*60

func _on_button_option_pressed() -> void:
	if $PanelOption.visible :
		$PanelOption.hide()
	else:
		$PanelOption.show()

func config_changed():
	for k in request_dict:
		request_dict[k].url_to_get = $PanelOption.cfg.config[k]
		request_dict[k].force_update()

func _on_auto_hide_option_panel_timeout() -> void:
	$PanelOption.hide()

# esc to exit
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
