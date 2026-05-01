extends Node
class_name UserPreference

@export var default_object_size: Vector3i = Vector3i(32, 32, 32)
@export var default_export_size: float = .03125
@export var object_creation_point: ObjectCreationPoint = ObjectCreationPoint.y_zero_cursor

## So higher = more time for each reconstruction but less draw calls which has trade offs maybe.
@export var mesh_chunk_size: int = 40

@export var unselected_color: Color = Color(.05, .02, .04)
@export var selection_color: Color = Color.ALICE_BLUE
@export var hover_color: Color = Color(.6, .8, 9)
@export var outline_selection_width: float = .11

@export var free_cam_sensitivity: float = 1.0

enum ObjectCreationPoint {
	origin,
	cursor,
	y_zero_cursor
}
