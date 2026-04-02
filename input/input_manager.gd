extends Node
class_name InputManager

@export var interaction_mode: InteractionMode = InteractionMode.object
@export var focus_mode: ActionFocusMode = ActionFocusMode.none

var selection_system: ObjectSelectionSystem
var paint_system: PaintSystem

func _ready():
	selection_system = get_node("%ObjectSelectionSystem")
	paint_system = get_node("%PaintSystem")

func _process(delta):
	handle_interaction()
	
	if Input.is_action_just_pressed("switch_edit_mode"):
		if interaction_mode == InteractionMode.voxel:
			enter_object_mode()
		elif interaction_mode == InteractionMode.object:
			if selection_system.currently_selected_objects.size() != 0:
				enter_edit_mode()
			## TODO: Add a pop-up if nothing is selected

func handle_interaction() -> void:
	if interaction_mode == InteractionMode.object:
		if Input.is_action_just_pressed("select"):
			selection_system.try_click()
	elif interaction_mode == InteractionMode.voxel:
		if Input.is_action_just_pressed("select"):
			paint_system.try_click()

func enter_edit_mode() -> void:
	interaction_mode = InteractionMode.voxel
	selection_system.hide_unselected_borders()

func enter_object_mode() -> void:
	interaction_mode = InteractionMode.object
	selection_system.unhide_all_borders()

enum ActionFocusMode {
	none,
	grabbing,
	resizing,
	rotating
}

enum InteractionMode {
	object,
	voxel
} 
