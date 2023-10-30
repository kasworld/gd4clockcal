class_name DayInfo

""" dayinfo.txt format
2023-05-21 이날의일정
05-21 매년의 일정
21 매달의 일정
일 매주 일요일 주반복
2023-08-20/2 2일 반복
* 매일 반복
"""

const weekday_name = ["일","월","화","수","목","금","토"]

var data_dict :Dictionary
"""
{
	"2023-05-21" : [ "이 날의 일정" ],
	"05-21" :  [ "매년의 일정" ],
	"21" :  [ "매달의 일정" ],
	"일" : [ "매주 일요일 주반복" ],
	"*" : [매일 반복],
}
"""

var day_repeat_list :Array
"""
[
	["2023-08-20", 2 , "2일 반복" ],
]
"""

func clear()->void:
	day_repeat_list.clear()
	data_dict.clear()

# return true if added
func add_day_repeat_data(k :String, v :String)->bool:
	var klist = k.split("/", false,1)
	if klist.size() != 2:
		return false
	var repeat_day = klist[1]
	if repeat_day.is_valid_int() == false:
		print_debug("unknown day repeat data", k,v)
		return false
	day_repeat_list.append( [ klist[0], repeat_day.to_int(), v ] )
	return true

func make(text:String)->void:
	clear()
	var lines = text.strip_edges().split("\n", false,0)
	for s in lines :
		var slist = s.strip_edges().split(" ", false,1)
		if slist.size() != 2:
			print_debug(slist)
			continue
		var key = slist[0]
		var value = slist[1]
		if add_day_repeat_data(key,value):
			continue # day repeat data
		# process non repeat data
		if data_dict.get(key) == null :
			data_dict[key] = [value]
		else :
			data_dict[key].append(value)
#	print_debug(day_repeat_list)

func get_daystringlist()->Array[String]:
	var rtn :Array[String] = []
	var addkey = func(key):
		if data_dict.get(key) == null:
			return
		for v in data_dict[key]:
			rtn.append(v)

	# every day
	addkey.call("*")

	var time_now_dict = Time.get_datetime_dict_from_system()
	# year repeat day info
	addkey.call("%02d-%02d" % [time_now_dict["month"], time_now_dict["day"]] )
	# month repeat day info
	addkey.call("%02d" % [time_now_dict["day"]] )
	# week repeat day info
	addkey.call(weekday_name[time_now_dict["weekday"]] )
	# today's info
	var todaystr = "%04d-%02d-%02d" % [time_now_dict["year"] , time_now_dict["month"] ,time_now_dict["day"]]
	addkey.call(todaystr)
	for v in day_repeat_list:
		var diffday = calc_day_diff(v[0], todaystr)
		if diffday % v[1] == 0:
			rtn.append(v[2])
	return rtn

# string must YYYY-MM-DD no time zone
func calc_day_diff(from :String, to :String)->int:
	var from_tick = Time.get_unix_time_from_datetime_string (from)
	var to_tick = Time.get_unix_time_from_datetime_string (to)
	return (to_tick-from_tick)/(24*60*60)
