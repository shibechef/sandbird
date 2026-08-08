extends UITabExtension
class_name BrushImportTab

var brush_visual_scene: PackedScene = load("res://UI/scenes/brush/single_brush_import.tscn")
var paint_system: PaintSystem

func _ready():
	super()
	paint_system = ProjectManager.current_project.get_node("%PaintSystem")
	update_folder_visuals()

func export_item_clicked(brush_name: String) -> void:
	ResourceSaver.save(paint_system.brush_list[brush_name], "res://user_data/brushes/" + brush_name + ".tres")
	update_folder_visuals()
	
func import_item_clicked(brush: BaseBrush) -> void:
	paint_system.add_existing_brush(brush)

func update_folder_visuals() -> void:
	var v_box: VBoxContainer = get_node("%VBoxContainer")
	var children = v_box.get_children()
	for child in children:
		child.free()
	
	var brushes = FileReader.get_brushes()
	print(brushes)
	for brush_name in brushes:
		var folder_name: String = brushes[brush_name].get_base_dir().get_file()
		if v_box.get_node(folder_name) == null:
			var name_label := Label.new()
			name_label.use_parent_material = true
			name_label.text = folder_name
			var grid := GridContainer.new()
			grid.use_parent_material = true
			grid.name = folder_name
			grid.columns = 6
			v_box.add_child(name_label)
			v_box.add_child(grid)
		var brush_scene: Control = brush_visual_scene.instantiate()
		var import_button: TextureButton = brush_scene.get_node("%TextureButton")
		import_button.texture_normal
		var brush: BaseBrush = load(brushes[brush_name])
		import_button.pressed.connect(import_item_clicked.bind(brush))
		v_box.get_node(folder_name).add_child(brush_scene)

func get_sidebar() -> Control:
	return ui_manager.brush_sidebar
