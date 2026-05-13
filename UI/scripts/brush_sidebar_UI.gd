extends Control
class_name BrushSidebarUI

@export var brushes_per_line: int = 6
var single_scene: PackedScene = preload("res://UI/composed_scenes/single_brush.tscn")
var paint_system: PaintSystem

func _ready():
	paint_system = get_parent().get_node("%PaintSystem")

func fill_list(brushes: Array[BaseBrush]):
	var children = get_children()
	for child in children:
		child.queue_free()
	
	var spacing: int = 53
	var current_hbox := HBoxContainer.new()
	current_hbox.add_theme_constant_override("separation", spacing)
	add_child(current_hbox)
	var index_on_line: int = 0
	for brush in brushes:
		var brush_scene: Control = single_scene.instantiate()
		current_hbox.add_child(brush_scene)
		var text: LineEdit = brush_scene.get_node("%Text")
		var texture: TextureRect = brush_scene.get_node("%Texture")
		var button: Button = brush_scene.get_node("%Button")
		
		text.text = brush.named_as
		button.pressed.connect(paint_system.select_brush.bind(brush.named_as))
		BrushManager.get_brush_text(brush)
		
		
		index_on_line += 1
		if index_on_line == brushes_per_line:
			index_on_line = 0
			current_hbox = HBoxContainer.new()
			current_hbox.add_theme_constant_override("separation", spacing)
			add_child(current_hbox)
