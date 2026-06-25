extends UITabExtension
class_name ColorPickingTab

## EXTREME SHITCODE!! COLOR AND COLORPICKER ARE BOTH QUESTIONABLE TO USE AT BEST!!
## I WISH I HADN'T USED EITHER!!

var color_palette_manager: ColorPaletteManager 

var previous_color: Color

var picker: ColorPicker
var sampler: ColorPicker
var slider_1: ColorPicker
var slider_2: ColorPicker
var slider_3: ColorPicker
var hex_input: ColorPicker

func _ready():
	super()
	color_palette_manager = ProjectManager.current_project.get_node("%ColorPaletteManager")
	
	picker = get_node("%ColorPicker")
	sampler = get_node("%ColorSampler")
	slider_1 = get_node("%ColorSlider1")
	slider_2 = get_node("%ColorSlider2")
	slider_3 = get_node("%ColorSlider3")
	hex_input = get_node("%HexInput")
	
	picker.color_changed.connect(update_color)
	sampler.color_changed.connect(update_color)
	slider_1.color_changed.connect(update_slider.bind(slider_1))
	slider_2.color_changed.connect(update_slider.bind(slider_2))
	slider_3.color_changed.connect(update_slider.bind(slider_3))
	hex_input.color_changed.connect(update_color_linear)
	
	update_UI_settings()

func set_new_color(color: Color) -> void:
	previous_color = color
	update_color(color)

func update_color(color: Color) -> void:
	picker.color = color
	sampler.color = color
	slider_1.color = color
	slider_2.color = color
	slider_3.color = color
	hex_input.color = color

func update_slider(color: Color, slider: ColorPicker) -> void:
	match slider.color_mode:
		ColorPicker.ColorModeType.MODE_HSV:
			update_color_HSV(color)
		ColorPicker.ColorModeType.MODE_LINEAR:
			update_color_linear(color)
		ColorPicker.ColorModeType.MODE_OKHSL:
			update_color_HSL(color)
		ColorPicker.ColorModeType.MODE_RGB:
			update_color_RGB(color)

func update_color_RGB(color: Color) -> void:
	update_color(color)
	
	if color_palette_manager.currently_selected_colors.size() == 1:
		update_color_single(color)
		color_palette_manager.update_color_UI()
		previous_color = color
		return
		
	var linear_old = previous_color.srgb_to_linear()
	var linear_new = color.srgb_to_linear()
	var diff_r: float = linear_new.r - linear_old.r
	var diff_g: float = linear_new.g - linear_old.g
	var diff_b: float = linear_new.b - linear_old.b
	
	for color_id in color_palette_manager.currently_selected_colors:
		var palette_color: PaletteColor = color_palette_manager.get_color_from_id(color_id)
		var srgb_color: Color = palette_color.color.srgb_to_linear()
		srgb_color.r += diff_r
		srgb_color.g += diff_g
		srgb_color.b += diff_b
		palette_color.color = srgb_color.linear_to_srgb()
		palette_color.update_hsl()
		palette_color.update_hsv()
	color_palette_manager.update_color_UI()
	previous_color = color

func update_color_linear(color: Color) -> void:
	update_color(color)
	
	if color_palette_manager.currently_selected_colors.size() == 1:
		update_color_single(color)
		color_palette_manager.update_color_UI()
		previous_color = color
		return
		
	var diff_r: float = color.r - previous_color.r
	var diff_g: float = color.g - previous_color.g
	var diff_b: float = color.b - previous_color.b
	for color_id in color_palette_manager.currently_selected_colors:
		var palette_color: PaletteColor = color_palette_manager.get_color_from_id(color_id)
		palette_color.color.r += diff_r
		palette_color.color.g += diff_g
		palette_color.color.b += diff_b
		palette_color.update_hsl()
		palette_color.update_hsv()
	color_palette_manager.update_color_UI()
	previous_color = color

func update_color_HSV(color: Color) -> void:
	update_color(color)
	
	if color_palette_manager.currently_selected_colors.size() == 1:
		update_color_single(color)
		color_palette_manager.update_color_UI()
		previous_color = color
		return
	
	var diff_h: float = color.h - previous_color.h
	var diff_s: float = color.s - previous_color.s
	var diff_v: float = color.v - previous_color.v
	
	for color_id in color_palette_manager.currently_selected_colors:
		var palette_color: PaletteColor = color_palette_manager.get_color_from_id(color_id)
		palette_color.color.v = clamp(palette_color.color.v + diff_v, .01, .99)
		palette_color.hsv_hue += diff_h
		palette_color.hsv_saturation += diff_s
		palette_color.color.h = palette_color.hsv_hue
		palette_color.color.s = palette_color.hsv_saturation
		palette_color.update_hsl()
	color_palette_manager.update_color_UI()
	previous_color = color

func update_color_HSL(color: Color) -> void:
	update_color(color)
	
	if color_palette_manager.currently_selected_colors.size() == 1:
		update_color_single(color)
		color_palette_manager.update_color_UI()
		previous_color = color
		return
	
	var diff_h: float = color.ok_hsl_h - previous_color.ok_hsl_h
	var diff_s: float = color.ok_hsl_s - previous_color.ok_hsl_s
	var diff_l: float = color.ok_hsl_l - previous_color.ok_hsl_l
	for color_id in color_palette_manager.currently_selected_colors:
		var palette_color: PaletteColor = color_palette_manager.get_color_from_id(color_id)
		palette_color.color.ok_hsl_l = clamp(palette_color.color.ok_hsl_l + diff_l, .01, .99)
		palette_color.hsl_hue += diff_h
		palette_color.hsl_saturation += diff_s
		palette_color.color.ok_hsl_h = palette_color.hsl_hue
		palette_color.color.ok_hsl_s = palette_color.hsl_saturation
		palette_color.update_hsv()
	color_palette_manager.update_color_UI()
	previous_color = color

func update_color_single(color: Color) -> void:
	var color_id = color_palette_manager.currently_selected_colors[0]
	var palette_color: PaletteColor = color_palette_manager.get_color_from_id(color_id)
	palette_color.color = color

func update_UI_settings() -> void:
	return

func get_sidebar() -> Control:
	return ui_manager.palette_sidebar
