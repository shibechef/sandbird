extends UITabExtension
class_name BrushPropertiesTab

var available_types: Array

func _ready():
	available_types = BrushManager.brush_metadata.keys()
	fill_properties(PointBrush.new())

func get_sidebar() -> Control:
	return ui_manager.brush_sidebar

func fill_properties(brush: BaseBrush) -> void:
	var all_propertes: Array[Dictionary] = brush.get_property_list()
	
	var brush_type = brush.get_script().get_global_name()
	var brush_data: Dictionary = BrushManager.brush_metadata
	var properties: Dictionary = brush_data[brush_type]["exposed_properties"]
	for property in all_propertes:
		var property_name = property["name"]
		if !properties.has(property_name):
			continue
		
		var property_display_name = properties[property_name]
		var property_value = brush.get(property_name)
		
		var scene = get_input_scene(properties[property])
		
## use the json to determine what data entry to use,
## like if its just a string to the property assume the scene,
## if theres a min_value on an int or float use a slider + text edit,
## string int or float use text edit
## if its an enum use a drop down
func get_input_scene(property_data: Dictionary) -> Control:
	return
