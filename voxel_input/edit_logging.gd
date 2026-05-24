extends Node
class_name EditLogging

var move_obj_system: MoveObjectSystem
var hierarchy: Hierarchy

var past_edits: Array[EditLog]
var undone_edits: Array[EditLog]

func _ready():
	move_obj_system = get_node("%MoveObjectSystem")
	hierarchy = get_node("%Hierarchy")

func log_edit(type: EditType, arguments: Array) -> void:
	var edit_log := EditLog.new()
	edit_log.type = type
	edit_log.arguments = arguments
	print(arguments)
	past_edits.append(edit_log)
	print(past_edits)

func undo_last_edit() -> void:
	if past_edits.is_empty():
		## popup here
		return
	
	var last_edit: EditLog = past_edits.back()
	revert_edit(last_edit, true)
	
	undone_edits.append(last_edit)
	past_edits.pop_back()

	
func redo_last_edit() -> void:
	if undone_edits.is_empty():
		## popup here
		return
	
	var last_undone_edit: EditLog = undone_edits.back()
	revert_edit(last_undone_edit, false)
	
	past_edits.append(last_undone_edit)
	undone_edits.pop_back()

func revert_edit(edit: EditLog, undo: bool):
	match edit.type:
		EditType.voxel_change:
			return
		EditType.model_move:
			move(edit.arguments, undo)
		EditType.model_rotate:
			return

func move(args: Array, undo: bool):
	var offset = args[0] * -1 if undo else args[0]
	var objs = args[1]
	
	for obj_id in objs:
		hierarchy.all_objects[obj_id].position += offset

enum EditType {
	voxel_change,
	model_move,
	model_rotate
}
