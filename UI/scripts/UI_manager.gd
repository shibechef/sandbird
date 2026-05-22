extends Control
class_name UI_manager

static var regular_theme: Theme = preload("res://UI/data/themes/regular.tres")
static var medium_theme: Theme = preload("res://UI/data/themes/medium.tres")

var brush_sidebar: BrushSidebarUI
var palette_sidebar: PaletteSidebarUI
var extended_brush_sidebar: Control
var extended_palette_sidebar: Control

var color_selection: ColorSelectionInput

@export var sidebar_mid_point: int = 500
@export var sidebar_width: int = 6
@export var brush_width: int = 42

func _ready():
	color_selection = get_node("%ColorSelectionInput")

	brush_sidebar = get_node("%BrushSidebarUI")
	palette_sidebar = get_node("%PaletteSidebarUI")
	extended_brush_sidebar = get_node("%ExtendedBrushSidebarUI")

	## Remove this later
	#add_palette_menu(1)
	
	extended_brush_sidebar.position = Vector2(4 + brush_width * sidebar_width, sidebar_mid_point - 144)

func add_palette_menu(palette_ID: int) -> void:
	var menu = RadialMenu.new()
	add_child(menu)
	color_selection.add_palette_UI(palette_ID, menu)	
	menu.position += Vector2(500., 500.)

func update_brush_sidebar(values: Array[BaseBrush]) -> void:
	brush_sidebar.fill_list(values, sidebar_width, 8, sidebar_mid_point, brush_width)

func update_palette_sidebar(values: Array[VoxelColorPalette]) -> void:
	palette_sidebar.fill_list(values)
