extends PopupUI
class_name ProjectMenu

var folder_vbox: VBoxContainer

var folder_dict: Dictionary[String, String] = {}
var current_folder: String

var folder_button_scene: PackedScene = preload("res://UI/scenes/project/project_folder_button.tscn")
var project_button_scene: PackedScene = preload("res://UI/scenes/project/project_list_button.tscn")

func _ready():
	get_node("%AddFolderButton").pressed.connect(add_folder)
	get_node("%ProjectFolderButton").pressed.connect(open_project_window)
	get_node("%FolderName").text_changed.connect(change_folder_name)
	get_node("%ProjectName").text_changed.connect(change_project_name)
	get_node("%SaveButton").pressed.connect(save_clicked)
	get_node("%UpdateThumbnailButton").pressed.connect(enter_thumbnail_mode)
	get_node("%CloseButton").pressed.connect(close_UI)
	
	folder_vbox = get_node("%FolderList")
	
	fill_menu()

func fill_menu() -> void:
	fill_folders()

func fill_folders() -> void:
	var children = folder_vbox.get_children()
	for child in children:
		child.queue_free()
	
	var parent = get_node("%FolderList")
	var folder_list: Array[String] = FileReader.get_folder_contents("res://user_data/projects", "")
	
	for file_path in folder_list:
		if file_path.ends_with("/"):
			file_path = file_path.left(-1)
		folder_dict[file_path.get_file()] = file_path
	
	for folder_name in folder_dict:
		var folder_button: Button = folder_button_scene.instantiate()
		folder_button.text = folder_name
		folder_button.pressed.connect(open_folder.bind(folder_name))
		folder_vbox.add_child(folder_button)
	
	if !folder_list.is_empty():
		open_folder("projects")
	
func fill_project_list() -> void:
	var project_vbox: GridContainer = get_node("%ProjectList")
	
	var children = project_vbox.get_children()
	for child in children:
		child.queue_free()
	
	var projects: Dictionary[String, String]
	if current_folder != "projects":
		projects = FileReader.get_projects(current_folder)
	else:
		projects = FileReader.get_projects()
	
	for project_name in projects:
		var project_button: Control = project_button_scene.instantiate()
		var label: RichTextLabel = project_button.get_node("%RichTextLabel")
		label.text = project_name
		var butt: Button = project_button.get_node("%Button")
		butt.pressed.connect(open_project.bind(projects[project_name]))
		project_vbox.add_child(project_button)

func fill_backup_list() -> void:
	return

func open_project(project_path: String) -> void:
	var save_state: SaveState = load(project_path)
	ProjectManager.load_project(save_state)

func open_folder(folder_name: String) -> void:
	for folder in folder_vbox.get_children():
		if folder.text != folder_name:
			folder.set_pressed_no_signal(false)
		else:
			folder.set_pressed_no_signal(true)
	current_folder = folder_name
	fill_project_list()

func save_clicked() -> void:
	var path: String = "res://user_data/projects/" + ProjectManager.current_project.project_name + ".tres"
	ProjectManager.save_project(path)

func add_folder() -> void:
	return

func change_folder_name(new_name: String) -> void:
	return

func change_project_name(new_name: String) -> void:
	return

func open_project_window() -> void:
	FileReader.open_folder_UI("res://user_data/projects/")

func open_backup_window() -> void:
	return

func enter_thumbnail_mode() -> void:
	return

func close_UI() -> void:
	super()
	get_node("%ProjectButtons").get_node("%ProjectButton").set_pressed_no_signal(false)
