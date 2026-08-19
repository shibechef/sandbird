extends UITabExtension
class_name BrushPropertiesTab

var brush_sidebar: BrushSidebarUI

var available_types: Array

func _ready():
	super()
	brush_sidebar = ProjectManager.current_project.get_node("%BrushSidebarUI")
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
	
	var displayed_property_count: int = 0
	for property in all_propertes:
		var property_name = property["name"]
		if !properties.has(property_name):
			continue
		displayed_property_count += 1
		
		var property_display_name = properties[property_name]
		var property_value = brush.get(property_name)
		
		var scene = UIManager.get_data_entry_UI_scene(brush, property_name, property_value, property)
		v_box.add_child(scene)

func get_sidebar() -> Control:
	return ui_manager.brush_sidebar
