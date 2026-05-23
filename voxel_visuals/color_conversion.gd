extends Node

func get_color_value(color: Color, type: int = 0) -> float:
	match type:
		0:
			return color.r * .2126 + color.g * .7152 + color.b * .0722
		1:
			return color.r * .299 + color.g * .587 + color.b * .114
		2:
			return (color.r + color.g + color.b) / 3.0
	return 0.0

func get_grayscale_color(color: Color, type: int = 0) -> Color:
	var luminance: float = get_color_value(color, type)
	return Color(luminance, luminance, luminance)
