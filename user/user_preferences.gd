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
@export var complimentary_UI_color: Color = Color(.75, .5, .74)

@export var primary_UI_theme: String
@export var secondary_UI_theme: String

signal UI_color_changed
signal primary_theme_set
signal secondary_theme_set
var UI_themes: Dictionary[String, Material]

@export var object_grabbing_sensitivity: float = 1.0
@export var free_cam_sensitivity: float = 1.0

func _init():
	UI_themes["default"] = load("res://materials/UI/ui_masking.tres")
	UI_themes["dots"] = load("res://materials/UI/masking_dots.tres")
	set_primary_theme("default")
	set_secondary_theme("dots")

func set_primary_theme(theme: String) -> void:
	primary_theme_set.emit(theme)
	primary_UI_theme = theme

func set_secondary_theme(theme: String) -> void:
	secondary_theme_set.emit(theme)
	secondary_UI_theme = theme

func change_UI_color(base: Color, complimentary: Color) -> void:
	base_UI_color = base
	complimentary_UI_color = complimentary
	UI_color_changed.emit(base, complimentary)

enum ObjectCreationPoint {
	origin,
	cursor,
	y_zero_cursor
}
