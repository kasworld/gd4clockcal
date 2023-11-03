class_name MyHTTPRequest extends Node

# for http header Last-Modified: Wed, 19 Oct 2022 03:10:02 GMT
const to_find_data = "Last-Modified: "

var url_to_get :String
var process_body :Callable
var fail_to_get :Callable
var repeat_second :float

var last_modified # from http header
var http_request :HTTPRequest
var timer :Timer

func _init(fileurl:String, repeatsec :float, bodyfn :Callable,failfn :Callable) -> void:
	url_to_get = fileurl
	repeat_second = repeatsec
	process_body = bodyfn
	fail_to_get = failfn
	http_request =  HTTPRequest.new()
	timer = Timer.new()
	timer.one_shot = true

func _ready() -> void:
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	add_child(timer)
	timer.timeout.connect(update)
	update()

func update():
	http_request.request(url_to_get)

# reload on next request, ignore modify date check
func force_update()->void:
	last_modified = ""
	update()

func _http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	timer.start(repeat_second)
	if result == HTTPRequest.RESULT_SUCCESS and response_code==200:
		var this_modified = key_value_from_header(to_find_data,headers)
		if last_modified != this_modified:
			last_modified = this_modified
			process_body.call(body)
	else :
		last_modified = ""
		fail_to_get.call()

func key_value_from_header(key: String ,headers: PackedStringArray )->String:
	var keyLen = len(key)
	for i in headers:
		if i.left(keyLen) == key:
			return i.right(keyLen)
	return ""

