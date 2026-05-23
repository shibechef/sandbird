extends Node
class_name EditLogging

var previous_changes: Array[EditLog]
var future_changes: Array[EditLog]

func log_edit(type: EditType, arguments: Array) -> void:
	return

func undo_edit() -> void:
	return

func redo_edit() -> void:
	return

enum EditType {
	voxel_change,
	model_move,
	model_rotate
}
