extends UITabExtension
class_name PaletteImportTab

var palette_scene: PackedScene

func export_item_clicked(palette: VoxelColorPalette) -> void:
	return

func import_item_clicked() -> void:
	return

func add_item(item: Resource, parent: Control) -> void:
	var palette_scene: Control = palette_scene.instantiate()
	parent.add_child(palette_scene)
	var texture: TextureRect = palette_scene.get_node("%Texture")
	var button: Button = palette_scene.get_node("%Button")
	
	## make it import from double click/dragging and dropping

func get_sidebar() -> Control:
	return ui_manager.palette_sidebar
	
