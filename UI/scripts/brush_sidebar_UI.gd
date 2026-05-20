extends Control
class_name BrushSidebarUI

var paint_system: PaintSystem
@export var single_brush_scene: PackedScene
@export var add_brush_scene: PackedScene

func _ready():
	paint_system = ProjectManager.current_project.get_node("%PaintSystem")

func fill_list(brushes: Array[BaseBrush]) -> void:
	var grid = get_node("%GridContainer")
	var children = grid.get_children()
	for child in children:
		child.queue_free()
	
	var add_brush_node: Control = add_brush_scene.instantiate()
	var add_butt: Button = add_brush_node.get_node("%Button")
	add_butt.pressed.connect(paint_system.add_new_brush)
	grid.add_child(add_brush_node)
	
	for brush in brushes:
		add_brush(brush, grid)

func add_brush(item: Resource, parent: Control) -> void:
	var brush_scene: Control = single_brush_scene.instantiate()
	parent.add_child(brush_scene)
	var text: LineEdit = brush_scene.get_node("%Text")
	var texture: TextureRect = brush_scene.get_node("%Texture")
	var button: Button = brush_scene.get_node("%Button")
	
	text.text = item.named_as
	button.pressed.connect(paint_system.select_brush.bind(item.named_as))
	## uncomment when dynamic textures are a thing
	#texture.texture = BrushManager.get_brush_text(brush)
