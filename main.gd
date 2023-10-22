extends Node2D

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

var request_dict = {}
func init_request_dict():
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

# Called when the node enters the scene tree for the first time.
func _ready():
	$PanelOption.config_changed.connect(config_changed)
	init_request_dict()

	var vp_size = get_viewport_rect().size
	bgImage = Image.create(vp_size.x,vp_size.y,true,Image.FORMAT_RGBA8)

	var fi = Global.weatherinfolabel_color
	$LabelWeather.label_settings = Global.make_label_setting(vp_size.y/16, fi[0], fi[1])
	$LabelWeather.position = Vector2(0, vp_size.y*0.47 )
	$LabelWeather.size = Vector2(vp_size.x/2, vp_size.y*0.55 )

	fi = Global.dayinfolabel_color
	$LabelDayInfo.label_settings = Global.make_label_setting(vp_size.y/16, fi[0], fi[1])
	$LabelDayInfo.position = Vector2(0, vp_size.y*0.47 )
	$LabelDayInfo.size = Vector2(vp_size.x/2, vp_size.y*0.55 )

	$Calendar.init(0, 0, vp_size.x/2, vp_size.y*0.65)
	$Calendar.position = Vector2(vp_size.x/2, vp_size.y*0.35 )

	fi = Global.datelabel_color
	$DateLabel.init( 0, 0, vp_size.x/2, vp_size.y/7.5, fi[0], fi[1])
	$DateLabel.position = Vector2(0, vp_size.y*0.35 )

	fi = Global.timelabel_color
	$TimeLabel.init(0, 0, vp_size.x, vp_size.y*0.42, fi[0], fi[1])
	$TimeLabel.position = Vector2(0, -vp_size.y*0.05 )

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED:
		for k in request_dict:
			request_dict[k].update()

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
	# date changed, update datelabel, calendar
	if oldDateUpdate["day"] != timeNowDict["day"]:
		oldDateUpdate = timeNowDict
		updateDayInfoLabel()

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
