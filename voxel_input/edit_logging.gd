extends Node
class_name EditLogging

var previous_changes: Array[EditLog]
var future_changes: Array[EditLog]

func log_edit(type: EditType, arguments: Array):
	return

enum EditType {
	model_move,
	model_rotate
}
