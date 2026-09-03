extends Node
class_name RadianceCascadeSolver

var hierarchy: Hierarchy
var palette_manager: ColorPaletteManager

var voxel_input_uniform: RDUniform
var output_text: Texture2DArrayRD = Texture2DArrayRD.new()

var compute_shader = load("res://shaders/compute/radiance_cascades.glsl")
var material: ShaderMaterial = load("res://materials/cascade_simple.tres")

var vox_text_RID: RID
var radiance_text_RID: RID

var text_size: int = 2304
var chunk_size: int = 96
var cascades: int = 4
var initial_rays: int = 6
var initial_ray_length: int = 3

func _ready():
	test_shit_math()
	hierarchy = get_node("%Hierarchy")
	palette_manager = get_node("%ColorPaletteManager")
	
	var chunks: int = 1
	match_compute_material_buffers(chunks)
	compute_radiance_texture(chunks)

func test_shit_math():
	var voxels_tested: Array[Vector3i] = [Vector3i.ZERO, Vector3i.ONE, 
	Vector3i.ONE * 2, Vector3i(0, 1, 2), 
	Vector3i.ONE * (chunk_size - 1),
	Vector3i(48, 2, 12), 
	Vector3i(71, 15, 50)]
		
	for n in cascades:
		## in a 3 dimensional space, halving the resolution in each direction 
		## means you need to 8x the rays per voxel to cancel out the 2x2x2 reduction
		## to maintain the same sized texture
		var size_ratio: float = float(1 << 0)
		var current_rays: int = initial_rays << (n * 3)
		
		for voxel in voxels_tested:
			var index: int = voxel.x + voxel.y * chunk_size + voxel.z * chunk_size * chunk_size
			index *= 6
			## output seems weird as it's 2298 2303, for 96^3 with 6 rays instead of 2303 2303
			## but that's the start for the 6 pixel slots of that voxel 
			var invocation := Vector2i(index % text_size, floori(float(index) / float(text_size)))
			
			## reconstruct voxel pos from invocation
			var text_index: int = (invocation.x + invocation.y * text_size)
			text_index = int(float(text_index) / float(initial_rays))
			var reconstructed_pos: Vector3i = Vector3i(
				int(float(text_index % chunk_size) / size_ratio),
				int(float(text_index % (chunk_size * chunk_size)) / float(chunk_size) / size_ratio),
				int(float(text_index % (chunk_size * chunk_size * chunk_size)) / float(chunk_size * chunk_size) / size_ratio)
			)
			
			print(voxel, " ", reconstructed_pos, " ", index, " ", invocation, " ", current_rays)

func compute_radiance_texture(chunks: int) -> void:
	var rd := RenderingServer.get_rendering_device()
	var shader_spirv: RDShaderSPIRV = compute_shader.get_spirv()
	var shader_RID := rd.shader_create_from_spirv(shader_spirv)
	
	var format_data := RDTextureFormat.new()
	format_data.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	format_data.width = text_size
	format_data.height = text_size
	format_data.array_layers = chunks
	format_data.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	format_data.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	
	vox_text_RID = rd.texture_create(format_data,RDTextureView.new())
	
	var voxel_uniform := RDUniform.new()	
	voxel_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	voxel_uniform.add_id(vox_text_RID)
	
	var radiance_uniform := RDUniform.new()	
	radiance_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	radiance_uniform.add_id(radiance_text_RID)
	
	var vox_bytes = PackedVector4Array()
	vox_bytes.resize(text_size * text_size * chunks)
	vox_bytes = grid_to_vec4_array(hierarchy.all_objects.values()[3])
	#vox_bytes.fill(Vector4(.5, .2, .3, .9)) 
	var bytes: PackedByteArray = vox_bytes.to_byte_array() 
	rd.texture_update(vox_text_RID, 0, bytes)
	
	var cascade_bytes = PackedFloat32Array()
	cascade_bytes.resize(text_size * text_size * chunks * cascades)
	cascade_bytes.fill(0.0) 
	var bytes_2: PackedByteArray = cascade_bytes.to_byte_array() 
	rd.texture_update(radiance_text_RID, 0, bytes_2)
	
	var chunk_width: int = roundi(pow(float(text_size*text_size) / 6.0, 1.0/3.0))
	var push_constant := PackedInt32Array()
	push_constant.push_back(initial_rays)
	push_constant.push_back(initial_ray_length)
	push_constant.push_back(chunk_width)
	push_constant.push_back(0)
	
	var uniform_set_0_RID := rd.uniform_set_create([voxel_uniform], shader_RID, 0)
	var uniform_set_1_RID := rd.uniform_set_create([radiance_uniform], shader_RID, 1)
	
	var compute_list := rd.compute_list_begin()
	var pipeline_RID := rd.compute_pipeline_create(shader_RID)
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline_RID)
	
	rd.compute_list_bind_uniform_set(compute_list, uniform_set_0_RID, 0)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set_1_RID, 1)
	rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), max(16, push_constant.to_byte_array().size()))
	
	rd.compute_list_dispatch(compute_list, 288, 288, cascades)
	rd.compute_list_end()

	var epic = rd.texture_get_data(radiance_text_RID, 0).to_vector4_array()
	
	var size_ratio: float = float(1 << 0)
	var n = 0
	for vec4 in epic:
		var voxel: int = roundi(float(n) / 6.0)
		if !vec4.is_equal_approx(Vector4(0.0, 0.0, 0.0, 1.0)) \
		and !vec4.is_equal_approx(Vector4(0.0, 0.0, 0.0, 0.0)):
			var reconstructed_pos: Vector3i = Vector3i(
				int(float(n % chunk_size) / size_ratio),
				int(float(n % (chunk_size * chunk_size)) / float(chunk_size) / size_ratio),
				int(float(n % (chunk_size * chunk_size * chunk_size)) / float(chunk_size * chunk_size) / size_ratio)
			)
	
			print(reconstructed_pos, " ", vec4)
		n += 1
	#for vec4 in epic:
	#	if !is_equal_approx(vec4.x, 0.0):
	#		print(vec4)
	#print()
	#print(epic[0])

## skip moving data through CPU from compute to material by using buffer
## https://github.com/godotengine/godot-proposals/issues/6989#issuecomment-2770544670
func match_compute_material_buffers(chunks: int) -> void:
	var rd := RenderingServer.get_rendering_device()
	var format_data := RDTextureFormat.new()
	format_data.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	format_data.width = text_size
	format_data.height = text_size
	format_data.array_layers = chunks * cascades
	format_data.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	format_data.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT + \
	RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	
	radiance_text_RID = rd.texture_create(format_data,RDTextureView.new())
	
	material.set_shader_parameter("cascade_text_array", output_text)
	var mat: Texture2DArrayRD = material.get_shader_parameter("cascade_text_array")
	mat.texture_rd_rid = radiance_text_RID

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
