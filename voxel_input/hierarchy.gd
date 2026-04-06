extends Node
class_name Hierarchy

@export var all_objects: Dictionary[int, VoxelObject]

func _ready():
	var children = self.find_children("*", "", true, false)
	for child in children:
		if child is VoxelObject:
			add_object(child)

func add_object(object: VoxelObject, is_child: bool = true):
	all_objects[object.get_instance_id()] = object
	if !is_child:
		add_child(object)

func remove_object(id: int):
	## Add more stuff here like checking if the object exists and whatever!
	var object = all_objects[id]
	
	all_objects.erase(id)
	object.queue_free()
	
