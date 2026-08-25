extends Node
class_name RadianceCascadeSolver

var hierarchy: Hierarchy
var palette_manager: ColorPaletteManager

var voxel_input_uniform: RDUniform
var output_text: Texture2DArrayRD = Texture2DArrayRD.new()

var compute_shader = load("res://shaders/compute/compute_testing.glsl")
var material: ShaderMaterial = load("res://materials/cascade_lighting.tres")

var input_vox_text_RID: RID
var output__text_RID: RID


func _ready():
	hierarchy = get_node("%Hierarchy")
	palette_manager = get_node("%ColorPaletteManager")
	compute_radiance_texture()
	#match_compute_material_buffers(2304, 2304, 2)
	#compute_radiance_map([hierarchy.all_objects.values()[3]])
	setup_basics()

func setup_basics() -> void:
	return

func compute_radiance_texture() -> void:
	var text_resolution: Vector3i = Vector3i(2304, 2304, 1)
	
	var rd := RenderingServer.get_rendering_device()
	var shader_file := load("res://shaders/compute/compute_testing.glsl")
	var shader_spirv: RDShaderSPIRV = compute_shader.get_spirv()
	var shader_RID := rd.shader_create_from_spirv(shader_spirv)
	
	var format_data := RDTextureFormat.new()
	format_data.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	format_data.width = text_resolution.x
	format_data.height = text_resolution.y
	format_data.array_layers = text_resolution.z
	format_data.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	format_data.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	
	var voxel_texture_rid = rd.texture_create(format_data,RDTextureView.new())
	var radiance_texture_rid = rd.texture_create(format_data,RDTextureView.new())
	
	var voxel_uniform := RDUniform.new()	
	voxel_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	voxel_uniform.add_id(voxel_texture_rid)
	
	var radiance_uniform := RDUniform.new()	
	radiance_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	radiance_uniform.add_id(radiance_texture_rid)
	
	var arr = PackedFloat32Array()
	arr.resize(text_resolution.x * text_resolution.y * text_resolution.z * 4)
	arr.fill(0.0) 
	var bytes = arr.to_byte_array() 
	
	rd.texture_update(voxel_texture_rid, 0, bytes)
	rd.texture_update(radiance_texture_rid, 0, bytes)
	
	var uniform_set_0_RID := rd.uniform_set_create([voxel_uniform], shader_RID, 0)
	var uniform_set_1_RID := rd.uniform_set_create([radiance_uniform], shader_RID, 1)
	
	var compute_list := rd.compute_list_begin()
	var pipeline_RID := rd.compute_pipeline_create(shader_RID)
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline_RID)
	
	rd.compute_list_bind_uniform_set(compute_list, uniform_set_0_RID, 0)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set_1_RID, 1)
	
	rd.compute_list_dispatch(compute_list, 288, 288, 1)
	rd.compute_list_end()
	var epic = rd.texture_get_data(voxel_texture_rid, 0).to_vector4_array()
	var epic2 = rd.texture_get_data(radiance_texture_rid, 0).to_vector4_array()
	print(epic[2304*2304-1], " ", epic2[2304*2304-1])

## literally just this 1:1
## https://docs.godotengine.org/en/latest/tutorials/shaders/compute_shaders.html
func xdd(objects: Array[VoxelObject]) -> void:
	var rd := RenderingServer.get_rendering_device()
	var shader_file := load("res://shaders/compute/radiance_cascade.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	var shader_RID := rd.shader_create_from_spirv(shader_spirv)
	
	var voxel_grid_input := grid_to_vec4_array(objects[0])
	var voxel_grid_bytes := voxel_grid_input.to_byte_array()
	voxel_grid_bytes.append_array(voxel_grid_bytes)
	var voxel_buffer_RID := rd.storage_buffer_create(voxel_grid_bytes.size(), voxel_grid_bytes)
	var voxel_uniform := RDUniform.new()
	voxel_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	voxel_uniform.binding = 0
	voxel_uniform.add_id(voxel_buffer_RID)
	
	#var uniform_chunks := RDUniform.new()
	#uniform_chunks.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	#uniform_chunks.binding = 0
	#uniform_chunks.add_id()
	
	#var output_bytes := PackedVector4Array()
	#output_bytes.resize(output_text.get_width() * output_text.get_height() * output_text.get_layers())
	#output_bytes.fill(Vector4(0.6, 0.7, 0.6, 1.0))
	#var output_byte_array: PackedByteArray = output_bytes.to_byte_array()
	#print(voxel_grid_bytes.size(), " ", output_byte_array.size())
	#var output_buffer_RID := rd.texture_buffer_create(output_byte_array.size(), RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT, output_byte_array)
	#output_uniform.add_id(output_text.texture_rd_rid)
	#
	#var uniform_set_0_RID := rd.uniform_set_create([voxel_uniform], shader_RID, 0)
	#var uniform_set_1_RID := rd.uniform_set_create([output_uniform], shader_RID, 1)
	#
	#var pipeline_RID := rd.compute_pipeline_create(shader_RID)
	#var compute_list := rd.compute_list_begin()
	#rd.compute_list_bind_compute_pipeline(compute_list, pipeline_RID)
	#rd.compute_list_bind_uniform_set(compute_list, uniform_set_0_RID, 0)
	#rd.compute_list_bind_uniform_set(compute_list, uniform_set_1_RID, 1)
	#rd.compute_list_dispatch(compute_list, 288, 288, 1)
	#rd.compute_list_end()
#
	#var voxel_output_data := rd.buffer_get_data(voxel_buffer_RID)
	#var output_voxel := voxel_output_data.to_vector4_array()
	#var texture_output_data := rd.texture_get_data(output_text, 0)
	#var goida_output_data := rd.buffer_get_data(output_buffer_RID)
	#print("erm ", voxel_output_data.size())
	#print("GUH ", texture_output_data.size(), " ", goida_output_data.size())
#
	#var unpacked = Array(voxel_output_data.to_vector4_array())
	#print("er ", unpacked[0])
	#for i in unpacked.size():
		#if unpacked[i] != Vector4.ZERO:
			#print("hello, ", i)

## skip moving data through CPU from compute to material by using buffer
## https://github.com/godotengine/godot-proposals/issues/6989#issuecomment-2770544670
func match_compute_material_buffers(x: int = 2304, y: int = 2304, layers: int = 2) -> void:
	assert(layers > 1, "texture will not load with less than 2 layers")
	#var rd := RenderingServer.get_rendering_device()
	#var texture_format := RDTextureFormat.new()
	#texture_format.width = x
	#texture_format.height = y
	#texture_format.array_layers = layers
	#texture_format.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	#texture_format.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT + RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT + RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT
	#texture_format.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	#var texture_buffer_RID := rd.texture_create(texture_format, RDTextureView.new(), [])
	#output_uniform = RDUniform.new()
	#output_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	#output_uniform.binding = 0
	#output_uniform.add_id(texture_buffer_RID)
	#
	#var clear_error: int = rd.texture_clear(texture_buffer_RID, Color(0.0, 1.0, 0.0), 0, 1, 0, 1)
	#assert(clear_error == 0, "texture failed clearing with error " + error_string(clear_error))
	#
	#material.set_shader_parameter("cascade_text_array", output_text)
	#var mat: Texture2DArrayRD = material.get_shader_parameter("cascade_text_array")
	#mat.texture_rd_rid = texture_buffer_RID

func grid_to_vec4_array(voxel_object: VoxelObject) -> PackedVector4Array:
	## quicker to simply append empty arrays 
	## than to preset an array size and set() repeatedly
	var empty: PackedVector4Array = PackedVector4Array([Vector4.ZERO, Vector4.ZERO, Vector4.ZERO, Vector4.ZERO, Vector4.ZERO, Vector4.ZERO])
	var color_array: PackedVector4Array
	var grid: Dictionary[Vector3i, VoxelData] = voxel_object.voxel_grid
	
	## doing z-y-x so that x is iterated on first
	for z in voxel_object.dimensions.z:
		for y in voxel_object.dimensions.y:
			for x in voxel_object.dimensions.x:
				var pos: Vector3i = Vector3i(x, y, z)
				if !grid.has(pos):
					color_array.append_array(empty)
				elif grid[pos].face_colors.size() == 1:
					var color: Color = palette_manager.get_color_from_id(grid[pos].face_colors[0]).color
					for i in 6:
						color_array.append(color_to_vec4(color))
				else:
					for i in 6:
						var color: Color = palette_manager.get_color_from_id(grid[pos].face_colors[i]).color
						color_array.append(color_to_vec4(color))					
	return color_array

func color_to_vec4(color: Color) -> Vector4:
	color.a += .5;
	return Vector4(color.r, color.g, color.b, color.a) 
