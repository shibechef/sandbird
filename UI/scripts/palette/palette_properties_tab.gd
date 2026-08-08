extends UITabExtension
class_name PalettePropertiesTab

func _ready():
	super()
	var blank_palette := VoxelColorPalette.new()
	blank_palette.material = load("res://materials/pbr_basic.tres")
	fill_properties(blank_palette)

func open_and_fill(palette: VoxelColorPalette) -> void:
	extend(true)
	fill_properties(palette)

func fill_properties(palette: VoxelColorPalette) -> void:
	var v_box: VBoxContainer = get_node("%VBoxContainer")
	var children = v_box.get_children()
	for child in children:
		child.queue_free()
	
	var name_scene := UIManager.get_data_entry_UI_scene(palette, "palette_name", palette.palette_name, "Name")
	v_box.add_child(name_scene)
	
	var material: ShaderMaterial = palette.material
	var material_params = material.shader.get_shader_uniform_list()
	
	for param in material_params:
		var param_name = param["name"]
		var param_value = material.get_shader_parameter(param_name)
		var param_scene := UIManager.get_data_entry_UI_scene(material, param_name, param_value, param_name)

func get_sidebar() -> Control:
	return ui_manager.palette_sidebar
