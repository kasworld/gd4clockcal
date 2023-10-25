extends Node

# for calendar ans date_label
const weekdaystring = ["일","월","화","수","목","금","토"]

# for calendar
var weekdayColorInfo = [
	[Color.RED, Color.RED.darkened(0.5)],  # sunday
	[Color.WHITE, Color.WHITE.darkened(0.5)],  # monday
	[Color.WHITE, Color.WHITE.darkened(0.5)],
	[Color.WHITE, Color.WHITE.darkened(0.5)],
	[Color.WHITE, Color.WHITE.darkened(0.5)],
	[Color.WHITE, Color.WHITE.darkened(0.5)],
	[Color.BLUE, Color.BLUE.darkened(0.5)],  # saturday
]
var todayColor = Color.GREEN
var timelabel_color = [Color.WHITE,Color.WHITE.darkened(0.5)]
var infolabel_color = [Color.WHITE,Color.WHITE.darkened(0.5)]
var paneloption_color = [Color.WHITE,Color.WHITE.darkened(0.5)]

var font = preload("res://HakgyoansimBareondotumR.ttf")

# common functions
func invert_label_color(lb :Label)->void:
	lb.label_settings.font_color = lb.label_settings.font_color.inverted()
	lb.label_settings.shadow_color = lb.label_settings.shadow_color.inverted()

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
