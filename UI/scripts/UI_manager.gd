extends Control
class_name UI_manager

static var regular_theme: Theme = preload("res://UI/data/themes/regular.tres")
static var medium_theme: Theme = preload("res://UI/data/themes/medium.tres")

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

func _process(delta):
	animate_UI(delta)

func add_palette_menu(palette_ID: int) -> void:
	var menu = RadialMenu.new()
	add_child(menu)
	color_selection.add_palette_UI(palette_ID, menu)	
	menu.position += Vector2(500., 500.)

func update_brush_sidebar(values: Array[BaseBrush]) -> void:
	paint_system.brush_UI_buttons.clear()
	brush_sidebar.fill_list(values, brushes_per_line, 8, sidebar_mid_point, brush_width)
	if paint_system.current_brush != "":
		paint_system.brush_UI_buttons[paint_system.current_brush].set_pressed_no_signal(true)

	var cutoff_point = extended_brush_sidebar.position
	brush_properties_tab.set_clipping_point(cutoff_point)
	brush_import_tab.set_clipping_point(cutoff_point)
	
func update_palette_sidebar(values: Array[VoxelColorPalette]) -> void:
	color_selection.color_buttons.clear()
	palette_sidebar.fill_list(values, 11)
	color_selection.update_sidebar_selections()
	
	var cutoff_point = extended_palette_sidebar.position
	color_picking_tab.set_clipping_point(cutoff_point)
	palette_properties_tab.set_clipping_point(cutoff_point)
	palette_import_tab.set_clipping_point(cutoff_point)

func add_animation(UI_node: Control, new_pos: Vector2) -> void:
	if animation_tasks.has(UI_node):
		if animation_tasks[UI_node][1] == new_pos:
			return
	
	var anim_speed: float = animation_pixels_per_sec / UI_node.position.distance_to(new_pos)
	anim_speed = clamp(anim_speed, .1, 10.0)
	animation_tasks[UI_node] = [UI_node.position, new_pos, 0.0, anim_speed]

func animate_UI(delta: float) -> void:
	var finished_anims: Array[Node]
	
	for UI_node in animation_tasks:
		var args = animation_tasks[UI_node]
		var speed = args[3]
		
		args[2] += delta * speed
		var progress = smoothstep(0.0, 1.0, args[2])
		UI_node.position = lerp(args[0], args[1], progress)
		
		if args[2] > 1.0:
			finished_anims.append(UI_node)
			
	for UI_node in finished_anims:
		animation_tasks.erase(UI_node)
