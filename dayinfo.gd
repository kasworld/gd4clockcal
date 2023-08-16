class_name DayInfo


const weekdaystring = ["일","월","화","수","목","금","토"]

var data_dict :Dictionary

func make(text):
	data_dict = {}
	text = text.strip_edges().split("\n", false,0)
	for s in text :
		var sss = s.strip_edges().split(" ", false,1)
		var key = sss[0]
		var value = sss[1]
		if data_dict.get(key) == null :
			data_dict[key] = [value]
		else :
			data_dict[key].append( value)

func get_daystringlist()->Array[String]:
	var rtn :Array[String] = []
	var addkey = func(key):
		if data_dict.get(key) == null:
			return
		for v in data_dict[key]:
			rtn.append(v)

	var timeNowDict = Time.get_datetime_dict_from_system()
	# year repeat day info
	addkey.call("%02d-%02d" % [timeNowDict["month"], timeNowDict["day"]] )
	# month repeat day info
	addkey.call("%02d" % [timeNowDict["day"]] )
	# week repeat day info
	addkey.call("%s" % weekdaystring[timeNowDict["weekday"]] )
	# today's info
	addkey.call("%04d-%02d-%02d" % [timeNowDict["year"] , timeNowDict["month"] ,timeNowDict["day"]] )
	return rtn
