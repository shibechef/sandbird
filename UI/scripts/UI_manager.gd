extends Control
class_name UI_manager

static var regular_theme: Theme = preload("res://UI/themes/regular.tres")
static var medium_theme: Theme = preload("res://UI/themes/medium.tres")

var brush_sidebar: PackedScene = preload("res://UI/composed_scenes/brush_sidebar.tscn")


var color_selection: ColorSelectionInput

func _ready():
	color_selection = get_node("%ColorSelectionInput")
	## Remove this later
	add_palette_menu(1)
	add_brush_sidebar()

func add_palette_menu(palette_ID: int) -> void:
	var menu = RadialMenu.new()
	add_child(menu)
	color_selection.add_palette_UI(palette_ID, menu)	
	menu.position += Vector2(500., 500.)

func add_brush_sidebar() -> void:
	var sidebar = brush_sidebar.instantiate()
	add_child(sidebar)
