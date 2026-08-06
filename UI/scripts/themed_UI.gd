extends Node
class_name ThemedUI

@export var ui_type: int = 1

func _ready():
	match ui_type:
		1:	
			UserPreferences.primary_theme_set.connect(change_theme)
			change_theme(UserPreferences.primary_UI_theme)
		2:	
			UserPreferences.secondary_theme_set.connect(change_theme)
			change_theme(UserPreferences.secondary_UI_theme)

func change_theme(shader_name: String) -> void:
	var UI_node: Control = get_parent()
	UI_node.material = UserPreferences.UI_themes[shader_name].duplicate()
