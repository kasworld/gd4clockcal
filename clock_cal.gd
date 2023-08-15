extends Node2D

var weekdaystring = ["일","월","화","수","목","금","토"]

var weather_request = MyHTTPRequest.new(
	"http://192.168.0.10/","weather.txt",
	60,
	func(body):
		var text = body.get_string_from_utf8()
		$LabelWeather.text = text
,
	func(): pass
)

var dayinfoDict = {}
var dayinfo_request = MyHTTPRequest.new(
	"http://192.168.0.10/","dayinfo.txt",
	60,
	func(body):
		var text = body.get_string_from_utf8()
		dayinfoDict = makeDayInfoDict(text.strip_edges().split("\n", false,0))
		updateDayInfoLabel( get_daystringlist(dayinfoDict) )
,
	func(): pass
)

func makeDayInfoDict(text)->Dictionary:
	var rtndict = {}
	for s in text :
		var sss = s.strip_edges().split(" ", false,1)
		var key = sss[0]
		var value = sss[1]
		if rtndict.get(key) == null :
			rtndict[key] = [value]
		else :
			rtndict[key].append( value)
	return rtndict

func updateDayInfoLabel( slist : Array[String]):
	$LabelDayInfo.text =  "\n".join(slist)

func get_daystringlist(dayinfo_dict :Dictionary)->Array[String]:
	var rtn :Array[String] = []
	var addkey = func(key):
		if dayinfo_dict.get(key) == null:
			return
		for v in dayinfo_dict[key]:
			rtn.append(v)

	var timeNowDict = Time.get_datetime_dict_from_system()
	# year repeat day info
	addkey.call("%02d-%02d" % [timeNowDict["month"], timeNowDict["day"]] )
	# month repeat day info
	addkey.call("%02d" % [timeNowDict["day"]] )
	# week repeat day info
	addkey.call("%s" % weekdaystring[timeNowDict["weekday"]] )
	# today's info
	addkey.call("%04d-%02d-%02d" % [timeNowDict["year"] , timeNowDict["month"] ,timeNowDict["day"]] )
	return rtn

var bgImage = Image.new()
var bgTexture = ImageTexture.new()
var bgimage_request = MyHTTPRequest.new(
	"http://192.168.0.10/","background.png",
	60,
	func(body):
		var image_error = bgImage.load_png_from_buffer(body)
		if image_error != OK:
			print("An error occurred while trying to display the image.")
		else:
			bgTexture = ImageTexture.create_from_image(bgImage)
			bgTexture.set_size_override(get_viewport_rect().size)
			$BackgroundSprite.texture = bgTexture
,
	func(): pass
)

var weekdayColorList = [
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

# esc to exit
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()

var calendar_labels = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var wh = get_viewport_rect().size
	bgImage = Image.create(wh.x,wh.y,true,Image.FORMAT_RGBA8)
	bgImage.fill(Color.DIM_GRAY)
	bgTexture = ImageTexture.create_from_image(bgImage)
	$BackgroundSprite.texture = bgTexture

	add_child(weather_request)
	add_child(dayinfo_request)
	add_child(bgimage_request)

	setfontshadow($LabelTime, Color.BLACK, 10)
	setfontshadow($LabelDate, Color.BLACK, 8)
	setfontshadow($LabelWeather, Color.BLACK, 6)
	setfontshadow($LabelDayInfo, Color.BLACK, 6)

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

func switchWeatherDayInfo() :
	if $LabelDayInfo.text == "":
		$LabelWeather.visible = true
		$LabelDayInfo.visible = false
		return

	if $LabelWeather.text == "":
		$LabelWeather.visible = false
		$LabelDayInfo.visible = true
		return

	if $LabelWeather.visible :
		$LabelWeather.visible = false
		$LabelDayInfo.visible = true
	else :
		$LabelWeather.visible = true
		$LabelDayInfo.visible = false

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
		updateDayInfoLabel( get_daystringlist(dayinfoDict) )

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

func _on_button_ok_pressed() -> void:
	$PanelOption.hide()
	var url = $PanelOption/LineEdit.text
	weather_request.base_url = url
	dayinfo_request.base_url = url
	bgimage_request.base_url = url

	weather_request.update()
	dayinfo_request.update()
	bgimage_request.update()

func _on_button_cancel_pressed() -> void:
	$PanelOption.hide()

func _on_button_option_pressed() -> void:
	if $PanelOption.visible :
		$PanelOption.hide()
	else:
		$PanelOption.show()


