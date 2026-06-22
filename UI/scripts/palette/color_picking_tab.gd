extends UITabExtension
class_name ColorPickingTab

var picker: ColorPicker
var sampler: ColorPicker
var slider_1: ColorPicker
var slider_2: ColorPicker
var slider_3: ColorPicker
var hex_input: ColorPicker

func _ready():
	picker = get_node("%ColorPicker")
	sampler = get_node("%ColorSampler")
	slider_1 = get_node("%ColorSlider1")
	slider_2 = get_node("%ColorSlider2")
	slider_3 = get_node("%ColorSlider3")
	hex_input = get_node("%HexInput")
	
	picker.color_changed.connect(update_color)
	sampler.color_changed.connect(update_color)
	slider_1.color_changed.connect(update_color)
	slider_2.color_changed.connect(update_color)
	slider_3.color_changed.connect(update_color)
	hex_input.color_changed.connect(update_color)

func get_sidebar() -> Control:
	return ui_manager.palette_sidebar

func update_color(color: Color):
	picker.color = color
	sampler.color = color
	slider_1.color = color
	slider_2.color = color
	slider_3.color = color
	hex_input.color = color
