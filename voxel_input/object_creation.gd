extends Node
class_name ObjectCreationSystem

var prefs: ProjectPreferences
var hierarchy: Hierarchy

func _ready():
	prefs = get_parent().get_node("%ProjectPreferences")
	hierarchy = get_parent().get_node("%Hierarchy")

func create_new_object() -> void:
	var pos = get_placement()
	var object: VoxelObject = VoxelObject.new()
	object.position = pos
	hierarchy.add_object(object, false)

## Maybe make it on the pivot for when there's the pivot camera
func get_placement() -> Vector3i:
	var dimensions: Vector3i = prefs.default_object_size
	
	if UserPreferences.object_creation_point == UserPreference.ObjectCreationPoint.origin:
		return Vector3i.ZERO - Vector3i(dimensions / 2.0)
	
	var click_data = get_parent().get_node("%WorldClick").get_forwards_pos()
	var dir: Vector3 = click_data[1]
	dir *= (dimensions.x + dimensions.y + dimensions.z) / 3.0 * 1.25
	var offset = click_data[0] - dimensions / 2.0	
	var pos: Vector3i = Vector3i(offset - dir)
	
	if UserPreferences.object_creation_point == UserPreference.ObjectCreationPoint.y_zero_cursor:
		pos.y = 0
	
	return pos
