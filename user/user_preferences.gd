extends Node
class_name UserPreference

@export var default_object_size: Vector3i = Vector3i(32, 32, 32)
@export var default_export_size: float = .03125
@export var object_creation_point: ObjectCreationPoint = ObjectCreationPoint.y_zero_cursor

@export var unselected_outline_color: Color = Color.BLACK
@export var selection_outline_color: Color = Color.ALICE_BLUE
@export var outline_selection_width: float = .11

@export var free_cam_sensitivity: float = 1.0

enum ObjectCreationPoint {
	origin,
	cursor,
	y_zero_cursor
}
