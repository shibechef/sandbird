extends Control
class_name UI_manager

static var regular_theme: Theme = preload("res://UI/themes/regular.tres")
static var medium_theme: Theme = preload("res://UI/themes/medium.tres")

var brush_sidebar_scene: PackedScene = preload("res://UI/composed_scenes/brush_sidebar.tscn")
var color_sidebar_scene: PackedScene = preload("res://UI/composed_scenes/palette_sidebar.tscn")

var brush_sidebar: Control
var palette_sidebar: Control

var color_selection: ColorSelectionInput

func _ready():
	color_selection = get_node("%ColorSelectionInput")
	## Remove this later
	add_palette_menu(1)
	var v_box = VBoxContainer.new()
	## Find out how to make it not manual!
	v_box.add_theme_constant_override("separation", 0)
	add_child(v_box)
	add_brush_sidebar(v_box)
	add_palette_sidebar(v_box)

func add_palette_menu(palette_ID: int) -> void:
	var menu = RadialMenu.new()
	add_child(menu)
	color_selection.add_palette_UI(palette_ID, menu)	
	menu.position += Vector2(500., 500.)

func add_brush_sidebar(parent: Control) -> void:
	brush_sidebar = brush_sidebar_scene.instantiate()
	parent.add_child(brush_sidebar)

func add_palette_sidebar(parent: Control) -> void:
	palette_sidebar = color_sidebar_scene.instantiate()
	parent.add_child(palette_sidebar)
