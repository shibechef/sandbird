extends Control
class_name SidebarUI

@export var items_per_line: int = 4
@export var horizontal_spacing: int = 10
@export var vertical_spacing: int = 10
@export var item_scene: PackedScene
@export var initial_scene: PackedScene

## Probably just generalize this and swap h/vbox to allow horizontal
func fill_list_vertical(items: Array) -> void:
	var children = get_children()
	for child in children:
		child.queue_free()
	
	var spacing: int = 53
	var current_hbox := HBoxContainer.new()
	current_hbox.add_theme_constant_override("separation", spacing)
	add_child(current_hbox)
	var index_on_line: int = 0
		
	for item in items:
		add_item(item, current_hbox)
		
		index_on_line += 1
		if index_on_line == items_per_line:
			index_on_line = 0
			current_hbox = HBoxContainer.new()
			current_hbox.add_theme_constant_override("separation", spacing)
			add_child(current_hbox)

func add_item(item: Resource, parent: Control) -> void:
	return
