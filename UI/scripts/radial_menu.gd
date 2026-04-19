extends Node
class_name RadialMenu

## Thank you Inigo for the SDF https://iquilezles.org/articles/distfunctions2d/
static func create_texture(angle: float, distance: float, thickness: float) -> ImageTexture:
	var texture := ImageTexture.new()
	var image := Image.create(100, 100, false, Image.FORMAT_RGB8)
	
	angle = deg_to_rad(angle) / 2.0
	
	var matrix: Transform2D 
	matrix.x.x = cos(angle)
	matrix.y.y = -cos(angle)
	matrix.x.y = sin(angle)
	matrix.y.x = sin(angle)

	
	for x in range(-50, 50):
		for y in range(-50, 50):
			var pos = Vector2(abs(x), y) / 50.0
			
			pos *= matrix
			
			var central_dist = abs(pos.length() - distance) - thickness * 0.5
			var far_dist = Vector2(pos.x, max(0.0, abs(distance - pos.y) - thickness * 0.5)).length() * sign(pos.x)
			var dist: float = max(central_dist, far_dist)
			
			dist = pow(dist, .5)
			var color = Color(dist, dist, dist)
			image.set_pixel(x + 50, y + 50, color)
	
	
	texture = ImageTexture.create_from_image(image)
	
	return texture
