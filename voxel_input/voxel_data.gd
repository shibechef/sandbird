extends Resource
class_name VoxelData

## There is a lot that can be put here, like input angle, input time, or other hidden data for modifications
var face_colors: Array[VoxelColor]

func _init():
	for i in 6:
		face_colors.append(VoxelColor.new())
