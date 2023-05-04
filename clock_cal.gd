extends Node2D

var urlBase = "http://192.168.0.10/"

var weatherFile = "weather.txt"
var updateWeatherSecond = 60*1

func updateWeather():
	$HTTPRequestWeather.request(urlBase + weatherFile)

var backgroundImageFile = "background.png"
var updateBackgroundImageSecond = 60*1

func updateBackgroundImage():
	$HTTPRequestBackgroundImage.request(urlBase + backgroundImageFile)


var weekdaystring = ["일","월","화","수","목","금","토"]
var backgroundColor = Color(0xffffffff)
var timeColor = Color(0x000000ff)
var dateColor = Color(0x000000ff)
var weatherColor = Color(0x000000ff)
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

	if updateWeatherSecond > 0:
		updateWeather()
	if updateBackgroundImageSecond > 0:
		updateBackgroundImage()

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var oldWeatherUpdate = 0.0 # unix time 
var oldBackgroundImageUpdate = 0.0 # unix time 
var oldDateUpdate = {"day":0} # datetime dict

func _on_timer_timeout():
	updateLabelsColor()
	
	var timeNowDict = Time.get_datetime_dict_from_system()
	var timeNowUnix = Time.get_unix_time_from_system()

	# update every 1 second
	$LabelTime.text = "%02d:%02d:%02d" % [timeNowDict["hour"] , timeNowDict["minute"] ,timeNowDict["second"]  ]

	# every updateWeatherSecond, update weather
	if oldBackgroundImageUpdate + updateBackgroundImageSecond < timeNowUnix:
		oldBackgroundImageUpdate = timeNowUnix
		updateBackgroundImage()

	if oldWeatherUpdate + updateWeatherSecond < timeNowUnix:
		oldWeatherUpdate = timeNowUnix
		updateWeather()

	# date changed, update datelabel, calendar
	if oldDateUpdate["day"] != timeNowDict["day"]:
		oldDateUpdate = timeNowDict
		$LabelDate.text = "%04d-%02d-%02d %s" % [
			timeNowDict["year"] , timeNowDict["month"] ,timeNowDict["day"],
			weekdaystring[ timeNowDict["weekday"]]  
			]
		updateCalendar()


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

# Last-Modified: Wed, 19 Oct 2022 03:10:02 GMT
const toFindDate = "Last-Modified: "

var lastWeatherModified 

func _on_http_request_weather_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS:
#		print(headers)
		var thisModified = keyValueFromHeader(toFindDate,headers)
		if lastWeatherModified != thisModified:
			lastWeatherModified = thisModified
			var text = body.get_string_from_utf8()
			$LabelWeather.text = text


var lastBackgroundImageModified 

func _on_http_request_background_image_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS:
		var thisModified = keyValueFromHeader(toFindDate,headers)
		if lastBackgroundImageModified != thisModified:
			lastBackgroundImageModified = thisModified
			var image_error = bgImage.load_png_from_buffer(body)
			if image_error != OK:
				print("An error occurred while trying to display the image.")
			else:
				bgTexture = ImageTexture.create_from_image(bgImage)
				bgTexture.set_size_override(getWH())
				$BackgroundSprite.texture = bgTexture
