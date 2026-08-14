extends Node

var project_menu: ProjectMenu
var settings_menu: SettingsMenu
var export_menu: ExportMenu

func _ready():
	project_menu = ProjectManager.current_project.get_node("%ProjectMenu")
	settings_menu = ProjectManager.current_project.get_node("%SettingsMenu")
	export_menu  = ProjectManager.current_project.get_node("%ExportMenu")
	get_node("%ProjectButton").pressed.connect(click_project_button)
	get_node("%SettingsButton").pressed.connect(click_settings_button)
	get_node("%ExportButton").pressed.connect(click_export_button)

func click_project_button() -> void:
	if project_menu.is_visible_in_tree():
		project_menu.close_UI()
	else:
		project_menu.open_UI()

func click_settings_button() -> void:
	return

func click_export_button() -> void:
	return
