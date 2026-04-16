extends Node
class_name PaintSystem

var object_selection: ObjectSelectionSystem
var collision_system: CollisionSystem
var palette_manager: ColorPaletteManager
var mesh_system: MeshSystem

var brush_paths: Dictionary[String, String]
var brush_list: Dictionary[String, BaseBrush] 
var current_brush: String

func _ready():
	object_selection = get_node("%ObjectSelectionSystem")
	collision_system = get_node("%CollisionSystem")
	palette_manager = get_node("%ColorPaletteManager")
	mesh_system = get_node("%MeshSystem")

func try_click() -> void:
	if current_brush.is_empty():
		## No brush selected!
		return
	
	var click_data = get_parent().get_node("%WorldClick").get_mouse_world_pos()
	var obj = object_selection.currently_selected_objects[object_selection.currently_selected_objects.keys()[0]]
	var voxel_diff: Dictionary[Vector3i, VoxelData] = brush_list[current_brush].get_voxels(click_data[0], click_data[1], obj)
	obj.add_voxels(voxel_diff)

func ready_brushes() -> void:
	brush_paths = FileReader.get_brushes()

enum PaintingMode{
	basic,
	rail
}
