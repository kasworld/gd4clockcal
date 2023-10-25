extends Node

# for calendar ans date_label
const weekdaystring = ["일","월","화","수","목","금","토"]

var colors_dark = {
	weekday = [
		[Color.RED, make_shadow_color(Color.RED)],  # sunday
		[Color.WHITE, make_shadow_color(Color.WHITE)],  # monday
		[Color.WHITE, make_shadow_color(Color.WHITE)],
		[Color.WHITE, make_shadow_color(Color.WHITE)],
		[Color.WHITE, make_shadow_color(Color.WHITE)],
		[Color.WHITE, make_shadow_color(Color.WHITE)],
		[Color.BLUE, make_shadow_color(Color.BLUE)],  # saturday
	],
	today = Color.GREEN,
	timelabel = Color.WHITE,
	infolabel = Color.WHITE,
	paneloption = Color.WHITE,
	default_clear = Color.BLACK,
}
var colors_light = 	{
	weekday = [
		[Color.RED, make_shadow_color(Color.RED)],  # sunday
		[Color.BLACK, make_shadow_color(Color.BLACK)],  # monday
		[Color.BLACK, make_shadow_color(Color.BLACK)],
		[Color.BLACK, make_shadow_color(Color.BLACK)],
		[Color.BLACK, make_shadow_color(Color.BLACK)],
		[Color.BLACK, make_shadow_color(Color.BLACK)],
		[Color.BLUE, make_shadow_color(Color.BLUE)],  # saturday
	],
	today = Color.GREEN,
	timelabel = Color.BLACK,
	infolabel = Color.BLACK,
	paneloption = Color.BLACK,
	default_clear = Color.WHITE,
}
var colors = colors_dark

var font = preload("res://HakgyoansimBareondotumR.ttf")

# common functions
var dark_mode = true
func set_dark_mode(b :bool):
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
