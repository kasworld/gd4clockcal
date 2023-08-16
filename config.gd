class_name Config

extends Object

var file_name = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/gd4clockcal_config.json"

var config = {
	"version" : "gd4clockcal 2.1.0",
	"weather_url" : "http://192.168.0.10/weather.txt",
	"dayinfo_url" : "http://192.168.0.10/dayinfo.txt",
	"todayinfo_url" : "http://192.168.0.10/todayinfo.txt",
	"background_url" : "http://192.168.0.10/background.png",
}

func FileExist():
	return FileAccess.file_exists(file_name)

func Save()-> String:
	var fileobj = FileAccess.open(file_name, FileAccess.WRITE)
	var json_string = JSON.stringify(config)
	fileobj.store_line(json_string)
	return "%s save" % [file_name]

func Load()->String:
	var fileobj = FileAccess.open(file_name, FileAccess.READ)
	var json_string = fileobj.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		config = data_received
		return "%s loaded" % [file_name]
	else:
		return "JSON Parse Error: %s in %s at line %s" % [ json.get_error_message(),  json_string,  json.get_error_line()]
