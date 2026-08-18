extends UITabExtension
class_name ColorPickingTab

var color_palette_manager: ColorPaletteManager 

var previous_color: Color

var picker: ColorPicker
var sampler: ColorPicker
var slider_1: ColorPicker
var slider_2: ColorPicker
var slider_3: ColorPicker
var hex_input: ColorPicker

func _ready():
	position.x = -size.x
	super()
	color_palette_manager = ProjectManager.current_project.get_node("%ColorPaletteManager")
	
	picker = get_node("%ColorPicker")
	sampler = get_node("%ColorSampler")
	slider_1 = get_node("%ColorSlider1")
	slider_2 = get_node("%ColorSlider2")
	slider_3 = get_node("%ColorSlider3")
	hex_input = get_node("%HexInput")
	
	picker.color_changed.connect(update_wheel)
	sampler.color_changed.connect(update_color_linear)
	slider_1.color_changed.connect(update_slider.bind(slider_1))
	slider_2.color_changed.connect(update_slider.bind(slider_2))
	slider_3.color_changed.connect(update_slider.bind(slider_3))
	hex_input.color_changed.connect(update_color_linear)
	
	update_UI_settings()
	show()
	get_parent().hide()
	
	call_deferred("pin_mask")
	
func pin_mask() -> void:
	var grand_parent = get_parent().get_parent()
	var sidebar = get_sidebar()
	var parent: Control = get_parent()
	ui_manager.pinned_UI[parent] = Vector2(sidebar.position.x + sidebar.size.x, grand_parent.position.y)

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

func update_wheel(color: Color) -> void:
	match picker.picker_shape:
		ColorPicker.PickerShapeType.SHAPE_HSV_RECTANGLE:
			update_color_HSV(color)
		ColorPicker.PickerShapeType.SHAPE_HSV_WHEEL:
			update_color_HSV(color)
		ColorPicker.PickerShapeType.SHAPE_OKHSL_CIRCLE:
			update_color_HSL(color)
		ColorPicker.PickerShapeType.SHAPE_OK_HL_RECTANGLE:
			update_color_HSL(color)
		ColorPicker.PickerShapeType.SHAPE_OK_HS_RECTANGLE:
			update_color_HSL(color)
		ColorPicker.PickerShapeType.SHAPE_VHS_CIRCLE:
			update_color_HSV(color)

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
		palette_color.update_material()
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
		palette_color.update_material()
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
		palette_color.update_material()
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
		palette_color.update_material()
	color_palette_manager.update_color_UI()
	previous_color = color

func update_color_single(color: Color) -> void:
	var color_id = color_palette_manager.currently_selected_colors[0]
	var palette_color: PaletteColor = color_palette_manager.get_color_from_id(color_id)
	palette_color.color = color
	palette_color.update_material()

func update_UI_settings() -> void:
	return

func get_sidebar() -> Control:
	return ui_manager.palette_sidebar

## needs to animate the mask as none of ColorPicker works with shaders!!!!
func extend(auto_close: bool) -> void:
	tab_button.set_pressed_no_signal(true)
	hovered = false
	var grand_parent = get_parent().get_parent()
	var parent = get_parent()
	var sidebar = get_sidebar()
	
	parent.show()
	
	var new_pos := Vector2(sidebar.position.x + sidebar.size.x + size.x, grand_parent.position.y)
	var self_pos: Vector2 = Vector2(0.0, 0.0)

	ui_manager.add_animation(grand_parent, new_pos)
	ui_manager.add_animation(self, self_pos)
	
	for UI_object in hide_on_enable:
		UI_object.hide()
	
	for button in disable_on_enable:
		button.set_pressed_no_signal(false)

func detract() -> void:
	hovered = false
	tab_button.set_pressed_no_signal(false)
	var grand_parent = get_parent().get_parent()
	var parent = get_parent()
	var sidebar = get_sidebar()
	
	var new_pos := Vector2(sidebar.position.x + sidebar.size.x, grand_parent.position.y)
	var self_pos: Vector2 = Vector2(-size.x, 0.0)

	ui_manager.add_animation(grand_parent, new_pos)
	ui_manager.add_animation(self, self_pos, parent.hide)
