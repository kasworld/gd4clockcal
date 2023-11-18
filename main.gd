extends Node2D

var vp_rect :Rect2

var timepos = []
var calpos = []
var infopos = []

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	vp_rect = get_viewport_rect()
	timepos = [Vector2(0, -vp_rect.size.y*0.04 ), Vector2(0, vp_rect.size.y -vp_rect.size.y*0.35)]
	calpos = [Vector2(vp_rect.size.x/2, vp_rect.size.y*0.35 ), Vector2(0, 0)]
	infopos = [Vector2(0, vp_rect.size.y*0.35 ), Vector2(vp_rect.size.x/2, 0)]

	var co = Global.colors.paneloption
	var optrect = Rect2( vp_rect.size.x * 0.1 ,vp_rect.size.y * 0.3 , vp_rect.size.x * 0.8 , vp_rect.size.y * 0.4 )
	$PanelOption.init( optrect, co, Global.make_shadow_color(co))
	$PanelOption.config_changed.connect(config_changed)
	init_request_dict()

	bgimage = Image.create(vp_rect.size.x,vp_rect.size.y,true,Image.FORMAT_RGBA8)

	co = Global.colors.timelabel
	$TimeLabel.init( Rect2(0, 0, vp_rect.size.x, vp_rect.size.y*0.42), co, Global.make_shadow_color(co))
	$Calendar.init( Rect2(0, 0, vp_rect.size.x/2, vp_rect.size.y*0.65) )
	co = Global.colors.infolabel
	$InfoLabel.init( Rect2(0, 0, vp_rect.size.x/2, vp_rect.size.y*0.65), co, Global.make_shadow_color(co) )
	reset_pos()
	update_color(get_color_by_time())
#	$AniMove.period = 2

func reset_pos()->void:
	$TimeLabel.position = timepos[0]
	$Calendar.position = calpos[0]
	$InfoLabel.position = infopos[0]
	$AniMove.stop()

func animove_toggle()->void:
	$AniMove.toggle()
	if not $AniMove.enabled:
		reset_pos()

func animove_step():
	if not $AniMove.enabled:
		return
	var ms = $AniMove.get_ms()
	match $AniMove.state%4:
		0:
			$AniMove.move_y_by_ms($TimeLabel, timepos[0], timepos[1], ms)
			$AniMove.move_y_by_ms($Calendar, calpos[0], calpos[1], ms)
			$AniMove.move_y_by_ms($InfoLabel, infopos[0], infopos[1], ms)
		1:
			$AniMove.move_x_by_ms($Calendar, calpos[0], calpos[1], ms)
			$AniMove.move_x_by_ms($InfoLabel, infopos[0], infopos[1], ms)
		2:
			$AniMove.move_y_by_ms($TimeLabel, timepos[1], timepos[0], ms)
			$AniMove.move_y_by_ms($Calendar, calpos[1], calpos[0], ms)
			$AniMove.move_y_by_ms($InfoLabel, infopos[1], infopos[0], ms)
		3:
			$AniMove.move_x_by_ms($Calendar, calpos[1], calpos[0], ms)
			$AniMove.move_x_by_ms($InfoLabel, infopos[1], infopos[0], ms)
		_:
			print_debug("invalid state", $AniMove.state)

func _process(delta: float) -> void:
	animove_step()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED:
		app_resumed()

func app_resumed()->void:
	update_color(get_color_by_time())
	for k in request_dict:
		request_dict[k].update()

func _on_button_option_pressed() -> void:
	$PanelOption.visible = not $PanelOption.visible

func config_changed():
	for k in request_dict:
		request_dict[k].url_to_get = $PanelOption.cfg.config[k]
		request_dict[k].force_update()

func _on_auto_hide_option_panel_timeout() -> void:
	$PanelOption.hide()

# esc to exit
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		elif event.keycode == KEY_ENTER:
			_on_button_option_pressed()
		elif event.keycode == KEY_SPACE:
			animove_toggle()
		elif event.keycode == KEY_MENU:
			animove_toggle()
		elif event.keycode == KEY_UP:
			animove_toggle()
		else:
			update_color(not Global.dark_mode)

	elif event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			1:
				animove_toggle()
			2:
				update_color(not Global.dark_mode)
			_:
				pass

var request_dict = {}
func init_request_dict()->void:
	var callable_dict = $InfoLabel.get_req_callable()
	request_dict["weather_url"] = MyHTTPRequest.new(
		$PanelOption.cfg.config["weather_url"],
		60,	callable_dict.weather_success, callable_dict.weather_fail,
	)
	request_dict["dayinfo_url"] = MyHTTPRequest.new(
		$PanelOption.cfg.config["dayinfo_url"],
		60, callable_dict.dayinfo_success, callable_dict.dayinfo_fail,
	)
	request_dict["todayinfo_url"] = MyHTTPRequest.new(
		$PanelOption.cfg.config["todayinfo_url"],
		60, callable_dict.todayinfo_success, callable_dict.todayinfo_fail,
	)
	request_dict["background_url"] = MyHTTPRequest.new(
		$PanelOption.cfg.config["background_url"],
		60, bgimage_success, bgimage_fail,
	)
	for k in request_dict:
		add_child(request_dict[k])

var bgimage :Image
func bgimage_success(body)->void:
	var image_error = bgimage.load_png_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image.")
	else:
		var bgTexture = ImageTexture.create_from_image(bgimage)
		bgTexture.set_size_override(get_viewport_rect().size)
		$BackgroundSprite.texture = bgTexture
func bgimage_fail()->void:
	$BackgroundSprite.texture = null

# return darkmode by time
func get_color_by_time()->bool:
	var now = Time.get_datetime_dict_from_system()
	return now["hour"] < 6 or now["hour"] >= 18

func update_color(darkmode :bool)->void:
	Global.set_dark_mode(darkmode)
	$TimeLabel.update_color()
	$InfoLabel.update_color()
	$Calendar.update_color()

# change dark mode by time
var old_hour_dict = Time.get_datetime_dict_from_system() # datetime dict
var old_minute_dict = Time.get_datetime_dict_from_system() # datetime dict
func _on_timer_day_night_timeout() -> void:
#	var bg = Global.make_gray_by_time()
#	RenderingServer.set_default_clear_color(bg)
#	print_debug(bg)
#	return
	var time_now_dict = Time.get_datetime_dict_from_system()
	if old_minute_dict["minute"] != time_now_dict["minute"]:
		$AniMove.start_with_step(1)
		old_minute_dict = time_now_dict

	if old_hour_dict["hour"] != time_now_dict["hour"]:
		update_color(get_color_by_time())
		old_hour_dict = time_now_dict

