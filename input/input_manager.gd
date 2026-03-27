extends Node
class_name InputManager

@export var editing_mode: EditMode = EditMode.object
@export var focus_mode: ActionFocusMode = ActionFocusMode.none

var selection_system: ObjectSelectionSystem

func _ready():
	selection_system = get_node("%ObjectSelectionSystem")

func _process(delta):
	if Input.is_action_pressed("switch_edit_mode"):
		if editing_mode == EditMode.voxel:
			switch_edit_mode(EditMode.object)
		else:
			if selection_system.currently_selected_objects.size() != 0:
				switch_edit_mode(EditMode.voxel)
			## TODO: Add a pop-up if nothing is selected


func switch_edit_mode(mode: EditMode) -> void:
	editing_mode = mode

enum ActionFocusMode {
	none,
	grabbing,
	resizing,
	rotating
}

enum EditMode {
	object,
	voxel
} 
