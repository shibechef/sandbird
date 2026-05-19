extends SidebarUI
class_name BrushSidebarUI

var paint_system: PaintSystem

func _ready():
	paint_system = ProjectManager.current_project.get_node("%PaintSystem")

func add_item(item: Resource, parent: Control) -> void:
	var brush_scene: Control = item_scene.instantiate()
	parent.add_child(brush_scene)
	var text: LineEdit = brush_scene.get_node("%Text")
	var texture: TextureRect = brush_scene.get_node("%Texture")
	var button: Button = brush_scene.get_node("%Button")
	
	text.text = item.named_as
	button.pressed.connect(paint_system.select_brush.bind(item.named_as))
	## uncomment when dynamic textures are a thing
	#texture.texture = BrushManager.get_brush_text(brush)
