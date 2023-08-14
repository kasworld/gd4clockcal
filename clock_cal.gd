extends Node2D

var weekdaystring = ["일","월","화","수","목","금","토"]

var weather_request :MyHTTPRequest
var dayinfo_request :MyHTTPRequest
var dayinfoDict = {}

func makeDayInfoDict(text):
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

func addLabelDayInfoByKey(key):
	if dayinfoDict.get(key) == null:
		return
	for v in dayinfoDict[key]:
		$LabelDayInfo.text += v +"\n"

func dayinfoDict2LabelDayInfo():
	$LabelDayInfo.text = ""
	var timeNowDict = Time.get_datetime_dict_from_system()

	var daykey :String

	# year repeat day info
	daykey = "%02d-%02d" % [timeNowDict["month"], timeNowDict["day"]]
	addLabelDayInfoByKey(daykey)

	# month repeat day info
	daykey = "%02d" % [timeNowDict["day"]]
	addLabelDayInfoByKey(daykey)

	# week repeat day info
	daykey = "%s" % weekdaystring[timeNowDict["weekday"]]
	addLabelDayInfoByKey(daykey)

	# today's info
	daykey = "%04d-%02d-%02d" % [timeNowDict["year"] , timeNowDict["month"] ,timeNowDict["day"]]
	addLabelDayInfoByKey(daykey)


var bgimage_request :MyHTTPRequest

var backgroundColor = Color(0x808080ff)
var timeColor = Color(0x000000ff)
var dateColor = Color(0x000000ff)
var weatherColor = Color(0x000000ff)
var dayinfoColor = Color(0x000000ff)
var todayColor = Color(0x00ff00ff)
var weekdayColorList = [
	Color(0xff0000ff),  # sunday
	Color(0x000000ff),  # monday
	Color(0x000000ff),
	Color(0x000000ff),
	Color(0x000000ff),
	Color(0x000000ff),
	Color(0x0000ffff),  # saturday
]

# work
func updateLabelsColor():

	$LabelTime.add_theme_color_override("font_color", timeColor )
	$LabelTime.add_theme_color_override("font_shadow_color", timeColor.lightened(0.5) )
	$LabelTime.add_theme_constant_override("shadow_offset_x",10)
	$LabelTime.add_theme_constant_override("shadow_offset_y",10)

	$LabelDate.add_theme_color_override("font_color", dateColor )
	$LabelDate.add_theme_color_override("font_shadow_color", dateColor.lightened(0.5) )
	$LabelDate.add_theme_constant_override("shadow_offset_x",8)
	$LabelDate.add_theme_constant_override("shadow_offset_y",8)

	$LabelWeather.add_theme_color_override("font_color", weatherColor )
	$LabelWeather.add_theme_color_override("font_shadow_color", weatherColor.lightened(0.5) )
	$LabelWeather.add_theme_constant_override("shadow_offset_x",6)
	$LabelWeather.add_theme_constant_override("shadow_offset_y",6)

	$LabelDayInfo.add_theme_color_override("font_color", dayinfoColor )
	$LabelDayInfo.add_theme_color_override("font_shadow_color", dayinfoColor.lightened(0.5) )
	$LabelDayInfo.add_theme_constant_override("shadow_offset_x",6)
	$LabelDayInfo.add_theme_constant_override("shadow_offset_y",6)


# esc to exit
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()

var calenderLabels = []
var bgImage = Image.new()
var bgTexture = ImageTexture.new()

func getWH()->Vector2i:
	var width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height =  ProjectSettings.get_setting("display/window/size/viewport_height")
	return Vector2i(width,height)

# Called when the node enters the scene tree for the first time.
func _ready():
	var wh = getWH()
	bgImage = Image.create(wh.x,wh.y,true,Image.FORMAT_RGBA8)
	bgImage.fill(backgroundColor)
	bgTexture = ImageTexture.create_from_image(bgImage)
	$BackgroundSprite.texture = bgTexture

	weather_request = MyHTTPRequest.new(
		"http://192.168.0.10/","weather.txt",
		60,
		func(body):
			var text = body.get_string_from_utf8()
			$LabelWeather.text = text
	)

	dayinfo_request = MyHTTPRequest.new(
		"http://192.168.0.10/","dayinfo.txt",
		60,
		func(body):
			var text = body.get_string_from_utf8()
			dayinfoDict = makeDayInfoDict(text.strip_edges().split("\n", false,0))
			dayinfoDict2LabelDayInfo()
	)

	bgimage_request = MyHTTPRequest.new(
		"http://192.168.0.10/","background.png",
		60,
		func(body):
			var image_error = bgImage.load_png_from_buffer(body)
			if image_error != OK:
				print("An error occurred while trying to display the image.")
			else:
				bgTexture = ImageTexture.create_from_image(bgImage)
				bgTexture.set_size_override(getWH())
				$BackgroundSprite.texture = bgTexture
	)

	add_child(weather_request)
	add_child(dayinfo_request)
	add_child(bgimage_request)

	weather_request.update()
	dayinfo_request.update()
	bgimage_request.update()

	updateLabelsColor()

	# prepare calendar
	var ln = []
	for i in range(len(weekdaystring)):
		var lb = Label.new()
		lb.text = weekdaystring[i]
		lb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lb.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
		lb.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
		lb.add_theme_color_override("font_color",  weekdayColorList[i] )
		lb.add_theme_color_override("font_shadow_color",  weekdayColorList[i].lightened(0.5) )
		lb.add_theme_constant_override("shadow_offset_x",  6 )
		lb.add_theme_constant_override("shadow_offset_y",  6 )

		$GridCalendar.add_child(lb)
		ln.append(lb)
	calenderLabels.append(ln)
	for _i in range(6):
		ln = []
		for j in range(7):
			var lb = Label.new()
			lb.text = "%d" % j
			lb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lb.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
			lb.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
			lb.add_theme_color_override("font_color",  weekdayColorList[j] )
			lb.add_theme_color_override("font_shadow_color",  weekdayColorList[j].lightened(0.5) )
			lb.add_theme_constant_override("shadow_offset_x",  6 )
			lb.add_theme_constant_override("shadow_offset_y",  6 )
			$GridCalendar.add_child(lb)
			ln.append(lb)
		calenderLabels.append(ln)


var oldDateUpdate = {"day":0} # datetime dict

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

func _on_timer_timeout():
	updateLabelsColor()

	switchWeatherDayInfo()

	var timeNowDict = Time.get_datetime_dict_from_system()

	# update every 1 second
	$LabelTime.text = "%02d:%02d:%02d" % [timeNowDict["hour"] , timeNowDict["minute"] ,timeNowDict["second"]  ]

	weather_request.update()
	dayinfo_request.update()
	bgimage_request.update()

	# date changed, update datelabel, calendar
	if oldDateUpdate["day"] != timeNowDict["day"]:
		oldDateUpdate = timeNowDict
		$LabelDate.text = "%04d-%02d-%02d %s" % [
			timeNowDict["year"] , timeNowDict["month"] ,timeNowDict["day"],
			weekdaystring[ timeNowDict["weekday"]]
			]
		updateCalendar()
		dayinfoDict2LabelDayInfo()

func updateCalendar():
	var tz = Time.get_time_zone_from_system()
	var today = int(Time.get_unix_time_from_system()) +tz["bias"]*60
	var todayDict = Time.get_date_dict_from_unix_time(today)
	var dayIndex = today - (7 + todayDict["weekday"] )*24*60*60 #datetime.timedelta(days=(-today.weekday() - 7))

	for week in range(6):
		for wd in range(7):
			var dayIndexDict = Time.get_date_dict_from_unix_time(dayIndex)
			var curLabel = calenderLabels[week+1][wd]
			curLabel.text = "%d" % dayIndexDict["day"]
			var co = weekdayColorList[wd]
			if dayIndexDict["month"] != todayDict["month"]:
				co = co.lightened(0.5)
			elif dayIndexDict["day"] == todayDict["day"]:
				co = todayColor
			curLabel.add_theme_color_override("font_color",  co )
			curLabel.add_theme_color_override("font_shadow_color",  co.lightened(0.5) )
			dayIndex += 24*60*60

func keyValueFromHeader(key: String ,headers: PackedStringArray ):
	var keyLen = len(key)
	for i in headers:
		if i.left(keyLen) == key:
			return i.right(keyLen)
	return ""

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


