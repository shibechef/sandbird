extends UITabExtension
class_name BrushImportTab

func export_item_clicked(palette_name: String) -> void:
	if Input.is_action_pressed("export_import_asset"):
		return

func import_item_clicked() -> void:
	if Input.is_action_pressed("export_import_asset"):
		return

func get_sidebar() -> Control:
	return ui_manager.brush_sidebar
