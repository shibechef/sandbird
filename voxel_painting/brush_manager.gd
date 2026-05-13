extends Node

var brush_metadata: Dictionary
var brush_paths: Dictionary[String, String]

func _init():
	cache_brush_metadata()
	brush_paths = FileReader.get_brushes()

func get_brush_text(brush: BaseBrush) -> Texture:
	var brush_type: String = brush.get_script().get_global_name()
	var brush_text_path: String = brush_metadata[brush_type]["texture file path"]
	return load(brush_text_path)

## No native yaml support. i cry.
func cache_brush_metadata() -> void:
	var path: String = "res://UI/data/brush_inspector_data.json"
	var text: String = FileAccess.get_file_as_string(path)
	var json := JSON.new()
	
	var error = json.parse(text)
	assert(error == 0, str(json.get_error_message()) + " in " + path + " at line " + str(json.get_error_line()))
	
	brush_metadata = json.data
