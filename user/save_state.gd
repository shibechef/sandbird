extends Resource
class_name SaveState

@export var save_time: Dictionary
@export var objects: Array[VoxelObjectData]
@export var palettes: Dictionary[int, VoxelColorPalette]
@export var palette_order: Array[int]
@export var brushes: Dictionary[String, BaseBrush] 
@export var backups: Array[SaveState]
