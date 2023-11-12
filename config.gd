class_name Config

var file_name = "gd4clockcal_config.json"
var version_key = "version"
var editable_keys = [
	"weather_url",
	"dayinfo_url",
	"todayinfo_url",
	"background_url",
	]

var config = {
	version_key : "gd4clockcal 4.5.4",
	"weather_url" : "http://192.168.0.10/weather.txt",
	"dayinfo_url" : "http://192.168.0.10/dayinfo.txt",
	"todayinfo_url" : "http://192.168.0.10/todayinfo.txt",
	"background_url" : "http://192.168.0.10/background.png",
}

func file_full_path()->String:
	return OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/" + file_name

func file_exist()->bool:
	return FileAccess.file_exists(file_full_path())

func save_json()-> String:
	var fileobj = FileAccess.open( file_full_path(), FileAccess.WRITE)
	var json_string = JSON.stringify(config)
	fileobj.store_line(json_string)
	return "%s save" % [file_full_path()]

var load_error :String
func new_by_load()->Config:
	var rtn = Config.new()
	var fileobj = FileAccess.open(file_full_path(), FileAccess.READ)
	var json_string = fileobj.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		rtn.config = json.data
		for k in config:
			if rtn.config.get(k) == null :
				rtn.load_error = "field not found %s" % [ k ]
				break
		if rtn.load_error.is_empty() and ( rtn.config[version_key] != config[version_key] ):
			rtn.load_error = "version not match %s %s" % [rtn.config[version_key] , config[version_key]]
	else:
		rtn.load_error = "JSON Parse Error: %s in %s at line %s" % [ json.get_error_message(),  json_string,  json.get_error_line()]
	return rtn
