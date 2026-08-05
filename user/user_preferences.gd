extends Node
class_name UserPreference

@export var default_object_size: Vector3i = Vector3i(32, 32, 32)
@export var default_export_size: float = .03125
@export var object_creation_point: ObjectCreationPoint = ObjectCreationPoint.y_zero_cursor

## So higher = more time for each reconstruction but less draw calls which has trade offs maybe.
@export var mesh_chunk_size: int = 24

@export var unselected_color: Color = Color(.05, .02, .04)
@export var selection_color: Color = Color.ALICE_BLUE
@export var hover_color: Color = Color(.6, .8, 9)
@export var outline_selection_width: float = .11

@export var base_UI_color: Color = Color(.54, .56, 1.0)
@export var secondary_UI_color: Color = Color(.75, .5, .74)
@export var current_ui_theme: String

signal theme_set
var ui_themes: Dictionary[String, Material]

@export var object_grabbing_sensitivity: float = 1.0
@export var free_cam_sensitivity: float = 1.0

func _init():
	ui_themes["default"] = load("res://materials/UI/ui_masking.tres")
	ui_themes["dots"] = load("res://materials/UI/masking_dots.tres")
	set_theme("dots")

func set_theme(theme: String) -> void:
	theme_set.emit(theme)
	current_ui_theme = theme

enum ObjectCreationPoint {
	origin,
	cursor,
	y_zero_cursor
}
