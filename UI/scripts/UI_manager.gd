extends Control
class_name UI_manager

static var regular_theme: Theme = preload("res://UI/data/themes/regular.tres")
static var medium_theme: Theme = preload("res://UI/data/themes/medium.tres")

var brush_sidebar: BrushSidebarUI
var palette_sidebar: PaletteSidebarUI
var extended_brush_sidebar: Control
var extended_palette_sidebar: Control

var color_selection: ColorSelectionInput
var paint_system: PaintSystem

@export var sidebar_mid_point: int = 500
@export var brushes_per_line: int = 6
@export var brush_width: int = 42
@export var colors_per_line: int = 11
@export var color_width: int = 24

func _ready():
	color_selection = get_node("%ColorSelectionInput")
	paint_system = get_node("%PaintSystem")

	brush_sidebar = get_node("%BrushSidebarUI")
	palette_sidebar = get_node("%PaletteSidebarUI")
	extended_brush_sidebar = get_node("%ExtendedBrushSidebarUI")
	extended_palette_sidebar = get_node("%ExtendedPaletteSidebarUI")

	## Remove this later
	#add_palette_menu(1)
	
	extended_brush_sidebar.position = Vector2(8 + brush_width * brushes_per_line, sidebar_mid_point - 145)
	extended_palette_sidebar.position = Vector2(8 + colors_per_line * color_width, sidebar_mid_point + 2)

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

func update_palette_sidebar(values: Array[VoxelColorPalette]) -> void:
	color_selection.color_buttons.clear()
	palette_sidebar.fill_list(values, 11)
	color_selection.update_sidebar_selections()
	
