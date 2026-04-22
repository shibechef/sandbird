extends Container
class_name RadialMenu

@export var max_ring_size: int = 16
@export var incomplete_rings: bool = true

## None of these options really work as they all change other properties!
@export var wheel_size: float = 2.0
@export var text_size: int = 300
@export var hole_size: float = 1.0
@export var thickness: float = 0.4
@export var gap_percent: float = 8.0
## Outlines kinda look like shit with low res...
@export var outline_thickness = .000

func _ready():
	make_children(44)
	scale *= 50.0 / text_size * wheel_size

func _process(delta):
	for child in get_children():
		continue
		child.rotation += delta

func make_children(amount: int) -> void:	
	var children: Array[TextureButton]
	for i in amount: 
		var butt = TextureButton.new()
		var random_col = Color(randf(), randf(), randf())
		butt.modulate = random_col
		children.append(butt)
		add_child(butt)

	var ring_count: int = ceili(float(amount) / float(max_ring_size))

	var angle: float
	var texture: ImageTexture
	var adjusted_scale: float
	var current_ring: int = 0
	var current_index: int = 0
	var adjusted_text_size
	
	for i in amount:
		if current_index == 0:
			var in_current_ring: float = min(amount - max_ring_size * current_ring, max_ring_size)
			angle = 360.0 / in_current_ring
			var adjusted_outline_thickness: float = outline_thickness / (1 + current_ring)
			var adjusted_hole_size = hole_size + (gap_percent / 100.0 + thickness) * (1 + current_ring)
			adjusted_scale = (adjusted_outline_thickness + adjusted_hole_size + thickness) * 2
			var adjusted_angle = angle - gap_percent / 2.0 / (1 + current_ring)
			texture = create_texture(text_size, adjusted_angle, adjusted_hole_size, thickness, Color.WHITE, Color.BLACK, adjusted_outline_thickness)
		
		var child: TextureButton = children[i]
		child.texture_normal = texture
		
		var current_angle = current_index * deg_to_rad(angle)
		child.pivot_offset = child.texture_normal.get_size() / 2.0
		print(child.texture_normal.get_size())
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

static func create_texture(text_size: int, angle: float, distance: float, thickness: float, 
	inside_color: Color, outline_color: Color, outline_thickness: float = .01) -> ImageTexture:
	var texture := ImageTexture.new()
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
				color = Color(Color.ORANGE, 0.0)				
				#continue
			image.set_pixel(x + text_size / 2, y + text_size / 2 + adjusted_y, color)
	
	texture = ImageTexture.create_from_image(image)
	
	return texture
