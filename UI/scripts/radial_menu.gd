extends Container
class_name RadialMenu

@export var max_ring_size: int = 8
@export var incomplete_rings: bool = true

## None of these options really work as they all change other properties!
@export var wheel_size: float = 2.0
@export var text_size: int = 500
@export var hole_size: float = 1.0
@export var thickness: float = 0.6
@export var gap_percent: float = 8.0
@export var selected_outline_thickness = .015

signal on_press
signal on_hover

func _ready():
	scale *= 50.0 / text_size * wheel_size

func button_pressed(index: int):
	on_press.emit(index)

func button_hovered(index: int):
	on_hover.emit(index)

func make_children(colors: Array[Color]) -> void:	
	var amount = colors.size()
	var children: Array[TextureButton]
	
	for i in amount: 
		var butt = TextureButton.new()
		children.append(butt)
		add_child(butt)

	var angle: float
	var texture: ImageTexture
	var selected_texture: ImageTexture
	var selection_bitmap: BitMap
	var adjusted_scale: float
	var current_ring: float = 0.0
	var current_index: int = 0
	
	for i in amount:
		if current_index == 0:
			var in_current_ring: float = min(amount - max_ring_size * current_ring, max_ring_size)
			angle = 360.0 / in_current_ring
			var adjusted_outline_thickness: float = selected_outline_thickness / (2 + current_ring)
			var adjusted_hole_size: float = hole_size + (gap_percent / 100.0 + thickness) * (1 + current_ring)
			adjusted_scale = (adjusted_hole_size + thickness) * 2
			var adjusted_angle: float = angle - gap_percent / 2.0 / (1 + current_ring)
			
			var normal_image = create_image(text_size, adjusted_angle, adjusted_hole_size, thickness, Color.WHITE, Color.BLACK, 0.0)
			var selected_image = create_image(text_size, adjusted_angle, adjusted_hole_size, thickness, Color.WHITE, Color.BLACK, adjusted_outline_thickness)
			texture = ImageTexture.create_from_image(normal_image)
			selected_texture = ImageTexture.create_from_image(selected_image)
			selection_bitmap = BitMap.new()
			selection_bitmap.create_from_image_alpha(normal_image)
		
		var child: TextureButton = children[i]
		child.texture_normal = texture
		child.texture_hover = selected_texture
		child.texture_click_mask = selection_bitmap
		
		var color = colors[i]
		
		child.material = load("res://materials/replace_UI_color.tres")
		child.set_instance_shader_parameter("white_replacement", color)
		child.set_instance_shader_parameter("black_replacement", UserPreferences.unselected_outline_color)
		child.pressed.connect(button_pressed.bind(i))
		child.mouse_entered.connect(button_hovered.bind(i))
		
		var current_angle = current_index * deg_to_rad(angle)
		child.pivot_offset = child.texture_normal.get_size() / 2.0
		child.rotation = current_angle + PI / 2.0
		
		var distance: float = .25 * text_size
		if angle != 360.0:
			child.position = distance * Vector2(cos(current_angle), sin(current_angle)) * adjusted_scale
		child.scale *= adjusted_scale
		
		current_index += 1
		if current_index == max_ring_size:
			current_index = 0
			current_ring += 1		

## Thank you Inigo for the SDF https://iquilezles.org/articles/distfunctions2d/

static func create_image(text_size: int, angle: float, distance: float, thickness: float, 
	inside_color: Color, outline_color: Color, outline_thickness: float = .01) -> Image:
	var image := Image.create(text_size, text_size, false, Image.FORMAT_RGBA8)
	
	var adjusted_scale = (outline_thickness + distance + thickness) * 2
	angle = deg_to_rad(angle) / 2.0
	
	var matrix: Transform2D 
	matrix.x.x = cos(angle)
	matrix.y.y = -cos(angle)
	matrix.x.y = sin(angle)
	matrix.y.x = sin(angle)
	
	## Make sure it's centered on the y axis or it will get clipped
	var adjusted_y = .25 * text_size if angle < 2.5 else 0.0
	for x in range(-text_size / 2, text_size / 2):
		for y in range(-text_size / 2 - adjusted_y, text_size / 2 - adjusted_y):
			var pos = Vector2(abs(x), y) / text_size * adjusted_scale
			
			pos *= matrix
			
			var central_dist = abs(pos.length() - distance) - thickness * 0.5
			var far_dist = Vector2(pos.x, max(0.0, abs(distance - pos.y) - thickness * 0.5)).length() * sign(pos.x)
			var dist: float = max(central_dist, far_dist)
			
			var color
			if dist > -outline_thickness * adjusted_scale and dist < outline_thickness * adjusted_scale:
				color = Color(outline_color, .8)
			elif dist < 0:
				color = Color(inside_color, 1.0)				
			else:
				continue
			image.set_pixel(x + text_size / 2, y + text_size / 2 + adjusted_y, color)
		
	return image
