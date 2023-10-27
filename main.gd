extends Node2D

var vp_size :Vector2

var timepos = []
var calpos = []
var infopos = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.set_dark_mode(true)

	vp_size = get_viewport_rect().size
	timepos = [Vector2(0, -vp_size.y*0.04 ), Vector2(0, vp_size.y -vp_size.y*0.35)]
	calpos = [Vector2(vp_size.x/2, vp_size.y*0.35 ), Vector2(0, 0)]
	infopos = [Vector2(0, vp_size.y*0.35 ), Vector2(vp_size.x/2, 0)]

	var co = Global.colors.paneloption
	$PanelOption.init(vp_size.x/10, vp_size.y/3, vp_size.x/2 , vp_size.y/2, co, Global.make_shadow_color(co))
	$PanelOption.config_changed.connect(config_changed)
	init_request_dict()

	bgimage = Image.create(vp_size.x,vp_size.y,true,Image.FORMAT_RGBA8)

	co = Global.colors.timelabel
	$TimeLabel.init(0, 0, vp_size.x, vp_size.y*0.42, co, Global.make_shadow_color(co))
	$Calendar.init(0, 0, vp_size.x/2, vp_size.y*0.65)
	co = Global.colors.infolabel
	$InfoLabel.init(0, 0, vp_size.x/2, vp_size.y*0.65, co, Global.make_shadow_color(co) )
	reset_pos()

func update_color(darkmode :bool):
	Global.set_dark_mode(darkmode)
	$TimeLabel.update_color()
	$InfoLabel.update_color()
	$Calendar.update_color()

func reset_pos():
	$TimeLabel.position = timepos[0]
	$Calendar.position = calpos[0]
	$InfoLabel.position = infopos[0]
	animove_state = 0

func sin_inter(v1 :float, v2 :float, t :float)->float:
	return (cos(t *PI)/2 +0.5) * (v2-v1) + v1

var animove_enable = false
var animove_state = 0
var animove_begin_tick = 0

func animove_toggle() :
	animove_enable = not animove_enable
	if animove_enable:
		animove_state = 0
		animove_begin_tick = Time.get_unix_time_from_system()
		$TimerAniMove.start()
	else:
		$TimerAniMove.stop()
		reset_pos()

func _on_timer_ani_move_timeout() -> void:
	animove_state += 1
	animove_begin_tick = Time.get_unix_time_from_system()

func animove_step():
	var ms = Time.get_unix_time_from_system() - animove_begin_tick
	match animove_state%4:
		0:
			$TimeLabel.position.y = sin_inter(timepos[1].y ,timepos[0].y , ms)
			$Calendar.position.y = sin_inter(calpos[1].y ,calpos[0].y , ms)
			$InfoLabel.position.y = sin_inter(infopos[1].y ,infopos[0].y , ms)
		1:
			$Calendar.position.x = sin_inter(calpos[1].x ,calpos[0].x , ms)
			$InfoLabel.position.x = sin_inter(infopos[1].x ,infopos[0].x , ms)
		2:
			$TimeLabel.position.y = sin_inter(timepos[0].y ,timepos[1].y , ms)
			$Calendar.position.y = sin_inter(calpos[0].y ,calpos[1].y , ms)
			$InfoLabel.position.y = sin_inter(infopos[0].y ,infopos[1].y , ms)
		3:
			$Calendar.position.x = sin_inter(calpos[0].x ,calpos[1].x , ms)
			$InfoLabel.position.x = sin_inter(infopos[0].x ,infopos[1].x , ms)
		_:
			print_debug("invalid state", animove_state)

func _process(delta: float) -> void:
	if not animove_enable:
		return
	animove_step()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED:
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

var bgimage :Image
func bgimage_success(body):
	var image_error = bgimage.load_png_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image.")
	else:
		var bgTexture = ImageTexture.create_from_image(bgimage)
		bgTexture.set_size_override(get_viewport_rect().size)
		$BackgroundSprite.texture = bgTexture
func bgimage_fail():
	pass

# change dark mode by time
var old_time_dict = Time.get_datetime_dict_from_system() # datetime dict
func _on_timer_day_night_timeout() -> void:
	var time_now_dict = Time.get_datetime_dict_from_system()
	if old_time_dict["hour"] != time_now_dict["hour"]:
		old_time_dict = time_now_dict
		match time_now_dict["hour"]:
			6:
				update_color(false)
			18:
				update_color(true)
			_:
#				update_color(not Global.dark_mode)
				pass
