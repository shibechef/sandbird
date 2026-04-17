extends Node

var brush_metadata: Dictionary

func _ready():
	cache_brush_metadata()

func refresh_available_brushes():
	var brushes = FileReader.get_brushes()

## No native yaml support. i cry.
func cache_brush_metadata() -> void:
	var path := "res://UI/brush_inspector_data.json"
	var text := FileAccess.get_file_as_string(path)
	var json := JSON.new()
	
	var error = json.parse(text)
	assert(error == 0, str(json.get_error_message()) + " in " + path + " at line " + str(json.get_error_line()))
	
	brush_metadata = json.data
