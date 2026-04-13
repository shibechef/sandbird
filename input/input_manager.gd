extends Node
class_name InputManager

@export var interaction_mode: InteractionMode = InteractionMode.object
@export var focus_mode: ActionFocusMode = ActionFocusMode.none

var selection_system: ObjectSelectionSystem
var paint_system: PaintSystem
var creation_system: ObjectCreationSystem
var color_palette_manager: ColorPaletteManager

var number_selection_sequence: String

func _ready():
	selection_system = get_node("%ObjectSelectionSystem")
	paint_system = get_node("%PaintSystem")
	creation_system = get_node("%ObjectCreationSystem")
	color_palette_manager = get_node("%ColorPaletteManager")

func _process(delta):
	handle_interaction()
	## Need to make this unique with other things that use 0-9
	handle_color_selection_inputs()
	save_number_input_chain()
	
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
	if Input.is_action_just_pressed("create_new_object"):
		creation_system.create_new_object()
		
	elif interaction_mode == InteractionMode.voxel:
		if Input.is_action_just_pressed("select"):
			paint_system.try_click()

func handle_color_selection_inputs() -> void:
	if !Input.is_action_just_released("color_selection"):
		return
		
	if color_palette_manager.currently_selected_palette == 0:
		return
	var palette: VoxelColorPalette = color_palette_manager.all_palettes[color_palette_manager.currently_selected_palette]
	
	var color_num = int(number_selection_sequence) - 1
	if color_num < 0:
		color_num = 10
	
	if palette.color_order.size() <= color_num:
		## Maybe an out of bounds popup here
		return
		
	var color_id: int = palette.color_order[color_num]
	
	if Input.is_action_pressed("select_one"):
		if !color_palette_manager.currently_selected_colors.has(color_id):
			color_palette_manager.currently_selected_colors.append(color_id)
		else:
			color_palette_manager.currently_selected_colors.erase(color_id)
	elif Input.is_action_pressed("select_several"):
		if !color_palette_manager.currently_selected_colors.has(color_id):
			color_palette_manager.currently_selected_colors.append(color_id)
	else:
		color_palette_manager.currently_selected_colors = [color_id]
		
func save_number_input_chain() -> void:
	## Get any other action like moving or resizing
	if Input.is_action_pressed("color_selection"):
		if Input.is_action_just_pressed("1"):
			number_selection_sequence += "1"
		if Input.is_action_just_pressed("2"):
			number_selection_sequence += "2"
		if Input.is_action_just_pressed("3"):
			number_selection_sequence += "3"
		if Input.is_action_just_pressed("4"):
			number_selection_sequence += "4"
		if Input.is_action_just_pressed("5"):
			number_selection_sequence += "5"
		if Input.is_action_just_pressed("6"):
			number_selection_sequence += "6"
		if Input.is_action_just_pressed("7"):
			number_selection_sequence += "7"
		if Input.is_action_just_pressed("8"):
			number_selection_sequence += "8"
		if Input.is_action_just_pressed("9"):
			number_selection_sequence += "9"
		if Input.is_action_just_pressed("0"):
			number_selection_sequence += "0"
		if Input.is_action_just_pressed("numerical decimal"):
			number_selection_sequence += "."
	else:
		number_selection_sequence = ""

func enter_edit_mode() -> void:
	interaction_mode = InteractionMode.voxel
	selection_system.deselect_all_but_recent()
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
