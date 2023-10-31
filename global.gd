extends Node

# for calendar ans date_label
const weekdaystring = ["일","월","화","수","목","금","토"]

var colors_dark = {
	weekday = [
		Color.RED.lightened(0.5),  # sunday
		Color.WHITE,  # monday
		Color.WHITE,
		Color.WHITE,
		Color.WHITE,
		Color.WHITE,
		Color.BLUE.lightened(0.5),  # saturday
	],
	today = Color.GREEN,
	timelabel = Color.WHITE,
	infolabel = Color.WHITE,
	paneloption = Color.WHITE,
	default_clear = Color.BLACK,
}
var colors_light = 	{
	weekday = [
		Color.RED,   # sunday
		Color.BLACK,   # monday
		Color.BLACK,
		Color.BLACK,
		Color.BLACK,
		Color.BLACK,
		Color.BLUE,   # saturday
	],
	today = Color.GREEN.darkened(0.5),
	timelabel = Color.BLACK,
	infolabel = Color.BLACK,
	paneloption = Color.BLACK,
	default_clear = Color.WHITE,
}
var colors = colors_dark

# 0:black -> 12:white -> 24:black
func make_gray_by_time()->Color:
	var now = Time.get_datetime_dict_from_system()
	var sec_in_day = ((now.hour * 60) + now.minute )*60 + now.second
	const sec_day = 24*60*60.0
	var v = (sec_in_day/sec_day*2.0)
	if v >1.0 :
		v = 2.0-v
	return Color(v,v,v,1.0)

var font = preload("res://HakgyoansimBareondotumR.ttf")

# common functions
var dark_mode = true
func set_dark_mode(b :bool)->void:
	dark_mode = b
	if dark_mode :
		colors = colors_dark
	else :
		colors = colors_light
	RenderingServer.set_default_clear_color(colors.default_clear)

func make_shadow_color(co :Color)->Color:
	if dark_mode:
		return co.darkened(0.5)
	else :
		return co.lightened(0.5)

func set_label_color(lb :Label, co1 :Color, co2 :Color)->void:
	lb.label_settings.font_color = co1
	lb.label_settings.shadow_color = co2

func make_label_setting(font_size :float , co1 :Color, co2 :Color)->LabelSettings:
	var label_settings = LabelSettings.new()
	label_settings.font = font
	label_settings.font_color = co1
	label_settings.font_size = font_size
	label_settings.shadow_color = co2
	var offset = calc_font_offset_vector2(font_size)
	label_settings.shadow_offset = offset
	return label_settings

func calc_font_offset_vector2(font_size :float)->Vector2:
	var offset = log(font_size)
	offset = clampf(offset, 1, 6)
	return Vector2(offset,offset)

func set_label_font_size(lb :Label, font_size :float)->void:
	lb.label_settings.font_size = font_size
	var offset = calc_font_offset_vector2(font_size)
	lb.label_settings.shadow_offset = offset
