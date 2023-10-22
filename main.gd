extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var vp_size = get_viewport_rect().size

	var fi = Global.paneloption_color
	$PanelOption.init(vp_size.x/10, vp_size.y/3, vp_size.x/2 , vp_size.y/2, fi[0], fi[1])
	$PanelOption.config_changed.connect(config_changed)
	init_request_dict()

	bgImage = Image.create(vp_size.x,vp_size.y,true,Image.FORMAT_RGBA8)


	$Calendar.init(0, 0, vp_size.x/2, vp_size.y*0.65)
	$Calendar.position = Vector2(vp_size.x/2, vp_size.y*0.35 )

	fi = Global.datelabel_color
	$DateLabel.init( 0, 0, vp_size.x/2, vp_size.y/7.5, fi[0], fi[1])
	$DateLabel.position = Vector2(0, vp_size.y*0.35 )

	fi = Global.timelabel_color
	$TimeLabel.init(0, 0, vp_size.x, vp_size.y*0.42, fi[0], fi[1])
	$TimeLabel.position = Vector2(0, -vp_size.y*0.05 )

	fi = Global.infolabel_color
	$InfoLabel.init(0, 0, vp_size.x/2, vp_size.y*0.55, fi[0], fi[1] )
	$InfoLabel.position = Vector2(0, vp_size.y*0.47 )

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED:
		for k in request_dict:
			request_dict[k].update()

var old_time_dict = {"day":0} # datetime dict
func _on_timer_timeout():
	$InfoLabel.switch_info_label()
	var time_now_dict = Time.get_datetime_dict_from_system()
	if old_time_dict["day"] != time_now_dict["day"]:
		old_time_dict = time_now_dict
		$InfoLabel.update_info_label()

func _on_button_option_pressed() -> void:
	$PanelOption.visible = not $PanelOption.visible

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

func invert_font_color()->void:
	$Calendar.invert_font_color()
	$DateLabel.invert_font_color()
	$TimeLabel.invert_font_color()
	$InfoLabel.invert_font_color()

var request_dict = {}
func init_request_dict():
	request_dict["weather_url"] = MyHTTPRequest.new(
		$PanelOption.cfg.config["weather_url"],
		60,	$InfoLabel.weather_success, $InfoLabel.weather_fail,
	)
	request_dict["dayinfo_url"] = MyHTTPRequest.new(
		$PanelOption.cfg.config["dayinfo_url"],
		60, $InfoLabel.dayinfo_success, $InfoLabel.dayinfo_fail,
	)
	request_dict["todayinfo_url"] = MyHTTPRequest.new(
		$PanelOption.cfg.config["todayinfo_url"],
		60, $InfoLabel.todayinfo_success, $InfoLabel.todayinfo_fail,
	)
	request_dict["background_url"] = MyHTTPRequest.new(
		$PanelOption.cfg.config["background_url"],
		60, bgimage_success, bgimage_fail,
	)
	for k in request_dict:
		add_child(request_dict[k])

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

