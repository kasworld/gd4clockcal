extends PanelContainer

var cfg :Config

signal config_changed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cfg_default = Config.new()
	cfg = Config.new()
	var msg = ""
	if !cfg.FileExist():
		msg = cfg.Save()
	else:
		msg = cfg.Load()
		for k in cfg_default.config:
			if cfg.config.get(k) == null :
				reset_config()
				break
	if cfg.config["version"] != cfg_default.config["version"]:
		reset_config()

#	print_debug(msg, cfg.config)
	config_to_control()

func config_to_control():
	$VBoxContainer/GridContainer/ConfigLabel.text = cfg.file_name
	$VBoxContainer/GridContainer/VersionLabel.text = cfg.config["version"]
	$VBoxContainer/GridContainer/WeatherLineEdit.text = cfg.config["weather_url"]
	$VBoxContainer/GridContainer/DayInfoLineEdit.text = cfg.config["dayinfo_url"]
	$VBoxContainer/GridContainer/BackgroundLineEdit.text = cfg.config["background_url"]

func reset_config():
	cfg = Config.new()
	cfg.Save()
	config_to_control()

func _on_button_ok_pressed() -> void:
	hide()
	cfg.config["weather_url"] = $VBoxContainer/GridContainer/WeatherLineEdit.text
	cfg.config["dayinfo_url"] = $VBoxContainer/GridContainer/DayInfoLineEdit.text
	cfg.config["background_url"] = $VBoxContainer/GridContainer/BackgroundLineEdit.text
	cfg.Save()

	config_changed.emit()

func _on_button_cancel_pressed() -> void:
	hide()

func _on_button_reset_pressed() -> void:
	reset_config()
