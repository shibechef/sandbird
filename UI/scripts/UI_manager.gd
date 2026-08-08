extends Control
class_name UIManager

static var regular_theme: Theme = preload("res://UI/data/themes/regular.tres")
static var medium_theme: Theme = preload("res://UI/data/themes/medium.tres")

static var hover_focus_script: Script = preload("res://UI/scripts/hover_focus.gd")

var brush_sidebar: BrushSidebarUI
var palette_sidebar: PaletteSidebarUI

var extended_brush_sidebar: Control
var extended_palette_sidebar: Control

var brush_properties_tab: BrushPropertiesTab
var brush_import_tab: BrushImportTab
var color_picking_tab: ColorPickingTab
var palette_properties_tab: PalettePropertiesTab
var palette_import_tab: PaletteImportTab

var color_selection: ColorSelectionInput
var paint_system: PaintSystem

@export var sidebar_mid_point: int = 500
@export var brushes_per_line: int = 6
@export var brush_width: int = 42
@export var colors_per_line: int = 11
@export var color_width: int = 24

@export var animation_pixels_per_sec: float = 1400.0
var animation_tasks: Dictionary[Control, Array]
var pinned_UI: Dictionary[Control, Vector2]

func _ready():
	color_selection = get_node("%ColorSelectionInput")
	paint_system = get_node("%PaintSystem")

	brush_sidebar = get_node("%BrushSidebarUI")
	palette_sidebar = get_node("%PaletteSidebarUI")
	extended_brush_sidebar = get_node("%ExtendedBrushSidebarUI")
	extended_palette_sidebar = get_node("%ExtendedPaletteSidebarUI")
	
	brush_properties_tab = extended_brush_sidebar.get_node("%BrushProperties")
	brush_import_tab = extended_brush_sidebar.get_node("%BrushImport")
	color_picking_tab = extended_palette_sidebar.get_node("%ColorPickingTab")
	palette_properties_tab = extended_palette_sidebar.get_node("%PalettePropertiesTab")
	palette_import_tab = extended_palette_sidebar.get_node("%ImportPaletteTab")

	## Remove this later
	#add_palette_menu(1)
	
	extended_brush_sidebar.position = Vector2(4 + brush_width * brushes_per_line, sidebar_mid_point - 145)
	extended_palette_sidebar.position = Vector2(8 + colors_per_line * color_width, sidebar_mid_point + 2)
	set_cutoffs()

func _process(delta):
	animate_UI(delta)
	keep_UI_pinned()

func add_palette_menu(palette_ID: int) -> void:
	var menu = RadialMenu.new()
	add_child(menu)
	color_selection.add_palette_UI(palette_ID, menu)	
	menu.position += Vector2(500., 500.)

func set_cutoffs() -> void:
	var brush_cutoff_point = Vector2(extended_brush_sidebar.position.x, 0.0)
	brush_properties_tab.set_clipping_point(brush_cutoff_point)
	brush_import_tab.set_clipping_point(brush_cutoff_point)
	
	var palette_cutoff_point = Vector2(extended_palette_sidebar.position.x, 0.0)
	color_picking_tab.set_clipping_point(palette_cutoff_point)
	palette_properties_tab.set_clipping_point(palette_cutoff_point)
	palette_import_tab.set_clipping_point(palette_cutoff_point)

func update_brush_sidebar(values: Array[BaseBrush]) -> void:
	paint_system.brush_UI_buttons.clear()
	brush_sidebar.fill_list(values, brushes_per_line, 8, sidebar_mid_point, brush_width)
	if paint_system.current_brush != "":
		paint_system.brush_UI_buttons[paint_system.current_brush].set_pressed_no_signal(true)
	
func update_palette_sidebar(values: Array[VoxelColorPalette]) -> void:
	color_selection.color_buttons.clear()
	palette_sidebar.fill_list(values, 11)
	color_selection.update_sidebar_selections()

func add_animation(UI_node: Control, new_pos: Vector2, callable = null) -> void:
	if animation_tasks.has(UI_node):
		if animation_tasks[UI_node][1] == new_pos:
			return
	
	var anim_speed: float = animation_pixels_per_sec / UI_node.position.distance_to(new_pos)
	anim_speed = clamp(anim_speed, .1, 10.0)
	animation_tasks[UI_node] = [UI_node.position, new_pos, 0.0, anim_speed, callable]

func animate_UI(delta: float) -> void:
	var finished_anims: Array[Control]
	
	for UI_node in animation_tasks:
		var args = animation_tasks[UI_node]
		var speed = args[3]
		
		args[2] += delta * speed
		var progress = smoothstep(0.0, 1.0, args[2])
		UI_node.position = lerp(args[0], args[1], progress)
		
		if args[2] > 1.0:
			finished_anims.append(UI_node)
			
	for UI_node in finished_anims:
		if animation_tasks[UI_node][4] != null:
			animation_tasks[UI_node][4].call()
		animation_tasks.erase(UI_node)

func keep_UI_pinned() -> void:
	for pinned_obj in pinned_UI:
		pinned_obj.global_position = pinned_UI[pinned_obj]

static func get_data_entry_UI_scene(sync_location: Object, property_name: String, property_value, property_data) -> HBoxContainer:
	var display_name: String
	var input_scenes: Array[Control]
	var final_scene := HBoxContainer.new()
	final_scene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	assert(property_data is String or property_data is Dictionary, "property data has incorrect input")
	if property_data is String:
		display_name = property_data
	else:
		display_name = property_data["name"]
		if property_data.has("min_value"):
			var slider := HSlider.new()
			slider.min_value = property_data["min_value"]
			slider.max_value = property_data["max_value"]
			slider.value = property_value
			slider.value_changed.connect(sync_value.bind(sync_location, property_name))
			input_scenes.append(slider)
		elif property_data.has("options"):
			return
	
	input_scenes.append(get_input_scene_from_property(sync_location, property_name, property_value))
	
	var name_scene = Label.new()
	name_scene.text = display_name
	name_scene.use_parent_material = true
	final_scene.add_child(name_scene)
	for input_scene in input_scenes:
		input_scene.use_parent_material = true
		final_scene.add_child(input_scene)
	
	final_scene.use_parent_material = true
	return final_scene
	
static func get_input_scene_from_property(sync_location: Object, property_name: String, property_value) -> Control:
	if property_value is String or property_value is int or property_value is float:
		var text_edit := LineEdit.new()
		text_edit.text = str(property_value)
		text_edit.text_changed.connect(sync_value.bind(sync_location, property_name))
		text_edit.set_script(hover_focus_script)
		text_edit.caret_blink = true
		return text_edit
	if property_value is bool:
		var check_box := CheckBox.new()
		check_box.set_pressed_no_signal(property_value)
		check_box.toggled.connect(sync_value.bind(sync_location, property_name))
		check_box.set_script(hover_focus_script)
		return check_box
	
	return Control.new()

static func sync_value(value, sync_location: Object, property_name: String) -> void:
	if sync_location is ShaderMaterial:
		sync_location.set_shader_parameter(property_name, value)
	else:
		sync_location.set(property_name, value)
