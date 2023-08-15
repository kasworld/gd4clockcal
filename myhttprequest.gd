class_name MyHTTPRequest extends Node

# for http header Last-Modified: Wed, 19 Oct 2022 03:10:02 GMT
const to_find_data = "Last-Modified: "

var base_url :String
var filename :String
var process_body :Callable
var fail_to_get :Callable
var update_second :float

var last_request = 0.0 # unix time
var last_modified # from http header
var http_request :HTTPRequest

func _init(url:String, file :String, updatesec :float, bodyfn :Callable,failfn :Callable) -> void:
	base_url = url
	filename = file
	update_second = updatesec
	process_body = bodyfn
	fail_to_get = failfn
	http_request =  HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

func update():
	if update_second > 0:
		var timeNowUnix = Time.get_unix_time_from_system()
		if last_request + update_second < timeNowUnix:
			last_request = timeNowUnix
			http_request.request(base_url + filename)

func _http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
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

