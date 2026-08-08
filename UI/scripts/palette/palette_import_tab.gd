extends UITabExtension
class_name PaletteImportTab

var palette_preview_scene: PackedScene = load("res://UI/scenes/palette/palette_preview.tscn")
var color_manager: ColorPaletteManager

func _ready():
	super()
	color_manager = ProjectManager.current_project.get_node("%ColorPaletteManager")
	update_folder_visuals()

func export_item_clicked(palette: VoxelColorPalette) -> void:
	ResourceSaver.save(palette, "res://user_data/palettes/" + str(palette.id) + ".tres")
	update_folder_visuals()

func import_item_clicked(palette: VoxelColorPalette) -> void:
	color_manager.add_existing_palette(palette)
		
func update_folder_visuals() -> void:
	var v_box: VBoxContainer = get_node("%VBoxContainer")
	var children = v_box.get_children()
	for child in children:
		child.free()
	
	var palettes = FileReader.get_palettes()
	for palette_name in palettes:
		var folder_name: String = palettes[palette_name].get_base_dir().get_file()
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
		var palette_scene: Control = palette_preview_scene.instantiate()
		var import_button: Button = palette_scene.get_node("%Button")
		var palette: VoxelColorPalette = load(palettes[palette_name])
		import_button.pressed.connect(import_item_clicked.bind(palette))
		var name_label: Label = palette_scene.get_node("%NameLabel")
		name_label.text = palette_name
		var texture: Texture = palette.get_node("%Texture")
		texture.texture
		v_box.get_node(folder_name).add_child(palette_scene)

func get_sidebar() -> Control:
	return ui_manager.palette_sidebar
