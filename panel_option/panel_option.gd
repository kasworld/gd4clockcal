extends PanelContainer

var cfg :Config

signal config_changed()

var lineedit_dict = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cfg = Config.new()
	var msg = ""
	if !cfg.file_exist():
		msg = cfg.save_json()
	else:
		var new_config = cfg.new_by_load()
		if not new_config.load_error.is_empty():
			print_debug(new_config.load_error)
			cfg.save_json()
		else :
			cfg = new_config

	# make label, lineedit
	for k in cfg.editable_keys:
		var lb = Label.new()
		lb.text = k
		$VBoxContainer/GridContainer.add_child(lb)
		var le = LineEdit.new()
		le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		le.text = cfg.config[k]
		lineedit_dict[k]= le
		$VBoxContainer/GridContainer.add_child(le)

#	print_debug(msg, cfg.config)
	config_to_control()

func config_to_control():
	$VBoxContainer/ConfigLabel.text = cfg.file_full_path()
	$VBoxContainer/VersionLabel.text = cfg.config[cfg.version_key]
	for k in cfg.editable_keys:
		lineedit_dict[k].text = cfg.config[k]

func reset_config():
	cfg = Config.new()
	cfg.save_json()
	config_to_control()

func _on_button_ok_pressed() -> void:
	hide()
	for k in cfg.editable_keys:
		cfg.config[k] = lineedit_dict[k].text
	cfg.Save()

	config_changed.emit()

func _on_button_cancel_pressed() -> void:
	hide()

func _on_button_reset_pressed() -> void:
	reset_config()