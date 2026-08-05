extends Node
class_name ThemedUI

func _ready():
	UserPreferences.theme_set.connect(change_theme)
	change_theme(UserPreferences.current_ui_theme)

func change_theme(shader_name: String) -> void:
	var ui_node: Control = get_parent()
	ui_node.material = UserPreferences.ui_themes[shader_name].duplicate()
	print(ui_node.material.get_shader_parameter("tiling_size"))
