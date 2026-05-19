extends SidebarUI
class_name PaletteImportUI

func add_item(item: Resource, parent: Control) -> void:
	var palette_scene: Control = item_scene.instantiate()
	parent.add_child(palette_scene)
	var texture: TextureRect = palette_scene.get_node("%Texture")
	var button: Button = palette_scene.get_node("%Button")
	
	## make it import from double click/dragging and dropping
