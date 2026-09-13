extends PopupUI
class_name ProjectMenu

func _ready():
	get_node("%ProjectFolderButton").pressed.connect(open_project_window)
	get_node("%SaveProjectButton").pressed.connect(save_clicked)
	get_node("%NameEditor").focus_exited.connect(save_as_clicked)
	get_node("%CloseButton").pressed.connect(close_UI)
	
	fill_menu()

func fill_menu() -> void:
	var recent_projects: VBoxContainer = get_node("%RecentProjects")
	var project_list: Array = recent_projects.get_children()
	var projects = FileReader.get_projects()

func save_clicked() -> void:
	var path: String = "res://user_data/projects/" + ProjectManager.current_project.project_name + ".tres"
	ProjectManager.save_project(path)

func save_as_clicked() -> void:
	ProjectManager.current_project.project_name = get_node("%NameEditor").text
	save_clicked()

func open_project_window() -> void:
	FileReader.open_folder_UI("res://user_data/projects/")
