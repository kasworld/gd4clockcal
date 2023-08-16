extends PanelContainer

var cfg :Config

signal config_changed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cfg = Config.new()
	var msg = ""
	if !cfg.FileExist():
		msg = cfg.Save()
	else:
		msg = cfg.Load()
#	print_debug(msg, cfg.config)
	$VBoxContainer/GridContainer/ConfigLabel.text = cfg.file_name
	$VBoxContainer/GridContainer/WeatherLineEdit.text = cfg.config["weather_url"]
	$VBoxContainer/GridContainer/DayInfoLineEdit.text = cfg.config["dayinfo_url"]
	$VBoxContainer/GridContainer/BackgroundLineEdit.text = cfg.config["background_url"]


func _on_button_ok_pressed() -> void:
	hide()
	cfg.config["weather_url"] = $VBoxContainer/GridContainer/WeatherLineEdit.text
	cfg.config["dayinfo_url"] = $VBoxContainer/GridContainer/DayInfoLineEdit.text
	cfg.config["background_url"] = $VBoxContainer/GridContainer/BackgroundLineEdit.text

	config_changed.emit()

func _on_button_cancel_pressed() -> void:
	hide()

