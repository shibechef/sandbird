extends UITabExtension
class_name BrushPropertiesTab

var available_types: Array

func _ready():
	super()
	available_types = BrushManager.brush_metadata.keys()
	fill_properties(PointBrush.new())

func fill_properties(brush: BaseBrush) -> void:
	var v_box: VBoxContainer = get_node("%VBoxContainer")
	var children = v_box.get_children()
	for child in children:
		child.queue_free()
	
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
		
		var scene = UI_manager.get_data_entry_UI_scene(brush, property_name, property_value, property)
		v_box.add_child(scene)
		
	var over_flow_scenes: int = max(v_box.get_child_count() - 5, 0)
	size.y += over_flow_scenes * 36
	position.y -= over_flow_scenes * 36

func get_sidebar() -> Control:
	return ui_manager.brush_sidebar
