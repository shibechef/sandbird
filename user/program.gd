extends Node
class_name Program

func _ready():
	if UserPreferences.open_last_project:
		var all_projects: Dictionary[String, String] = FileReader.get_projects("", true)
		
		var max_unix_time: int = 0
		var recent_project: SaveState

		for project_name in all_projects:
			var save_state: SaveState = load(all_projects[project_name])
			
			var unix_time: int
			if save_state.save_time.is_empty():
				unix_time = 1
			else:
				unix_time = Time.get_unix_time_from_datetime_dict(save_state.save_time)
			
			if unix_time > max_unix_time:
				max_unix_time = unix_time
				recent_project = save_state
		
		ProjectManager.load_project(recent_project)
