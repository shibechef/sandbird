extends Control
class_name UI_manager

static var regular_theme: Theme = preload("res://UI/themes/regular.tres")
static var medium_theme: Theme = preload("res://UI/themes/medium.tres")

var color_selection: ColorSelectionInput

func _ready():
	color_selection = get_node("%ColorSelectionInput")
	add_palette_menu(1)

func add_palette_menu(palette_ID: int) -> void:
	var menu = RadialMenu.new()
	add_child(menu)
	color_selection.add_palette_UI(palette_ID, menu)	
