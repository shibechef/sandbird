extends Node

var brush_metadata: Dictionary

func refresh_available_brushes():
	var brushes = FileReader.get_brushes()
