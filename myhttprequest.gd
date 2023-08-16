class_name MyHTTPRequest extends Node

# for http header Last-Modified: Wed, 19 Oct 2022 03:10:02 GMT
const to_find_data = "Last-Modified: "

var base_url :String
var filename :String
var process_body :Callable
var fail_to_get :Callable
var repeat_second :float

var last_modified # from http header
var http_request :HTTPRequest
var timer :Timer

func _init(url:String, file :String, repeatsec :float, bodyfn :Callable,failfn :Callable) -> void:
	base_url = url
	filename = file
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
	http_request.request(base_url + filename)

func _http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	timer.start(repeat_second)
	if result == HTTPRequest.RESULT_SUCCESS and response_code==200:
		var thisModified = key_value_from_header(to_find_data,headers)
		if last_modified != thisModified:
			last_modified = thisModified
			process_body.call(body)
	else :
		fail_to_get.call()


func key_value_from_header(key: String ,headers: PackedStringArray ):
	var keyLen = len(key)
	for i in headers:
		if i.left(keyLen) == key:
			return i.right(keyLen)
	return ""
