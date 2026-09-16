extends PopupUI
class_name ProjectMenu

func _ready():
	fill_menu()

func fill_menu() -> void:
	return
	
func save_clicked() -> void:
	var path: String = "res://user_data/projects/" + ProjectManager.current_project.project_name + ".tres"
	ProjectManager.save_project(path)

func save_as_clicked() -> void:
	#ProjectManager.current_project.project_name = get_node("%NameEditor").text
	save_clicked()

#func open_project_window() -> void:
	#FileReader.open_folder_UI("res://user_data/projects/")
