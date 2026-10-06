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

var rd: RenderingDevice
var shader_spirv: RDShaderSPIRV
var shader_RID: RID

var voxel_uniform: RDUniform
var vox_bytes: PackedVector4Array

var radiance_uniform: RDUniform

var text_size: int = 2304
var chunk_size: int = 96
var cascades: int = 4
var initial_rays: int = 6
var initial_ray_length: int = 6

func _ready():
	test_shit_math()
	hierarchy = get_node("%Hierarchy")
	palette_manager = get_node("%ColorPaletteManager")
	
	var chunks: int = 1
	rd = RenderingServer.get_rendering_device()
	match_compute_material_buffers(chunks)
	setup_compute_materials(chunks)
	compute_radiance_texture(chunks)

func test_shit_math():
	var tested_indices: Array[int] = [
	0, 1, 5, 48*24-1, 48*24, 48*24+1, 48*24*2, 48*24*3, 6*96*96*96-1
	]
		
	for cascade in cascades:
		## higher ray count results in proportionally lower sample points to maintain text size
		## 6 * 2^(3*cascade) makes simple cube to sphere mapping impossible
		## 6 * 2^(6*cascade) is too big of a leap per cascade but allows the simple mapping
		## 6 * 2^(2*cascade) is a small leap, allows sphere mapping, 
		## but the sample points are not spaced by a whole number in all 3 directions like the others
		var current_rays: int = initial_rays << (cascade * 2)
		var sample_points: int = int(float(text_size * text_size) / float(current_rays))

		print("cascade: ", cascade, ", rays per probe: ", current_rays, ", total probes: ", sample_points)
		
		var positions: Dictionary[Vector3, Array]
		for index in tested_indices:
			positions[test_position_sampling(index, cascade)] = []		
			
		for index in text_size*text_size:
			var pos := test_position_sampling(index, cascade)
			
			if positions.has(pos):
				positions[pos].append(index)
			
			var invocation := Vector2i(index % text_size, floori(float(index) / float(text_size)))
			var voxel_index: int = (invocation.x + invocation.y * text_size)
				
			var ray_index: int = voxel_index % current_rays
			var face: int = floori(6 * float(ray_index) / float(current_rays))
			var rays_per_face_axis: float = float(current_rays) / 6.0
			var offset: float = 0.5 / rays_per_face_axis
			var ray_axis_1: float = -1.0 + 2.0 * (offset + float(ray_index % int(rays_per_face_axis)) / rays_per_face_axis)
			var ray_axis_2: float = -1.0 + 2.0 * (offset + float(ray_index % int(rays_per_face_axis)) / rays_per_face_axis / rays_per_face_axis)
		
		for position in positions:
			print(positions[position])

func test_position_sampling(index: int, cascade: int) -> Vector3:
	var invocation := Vector2i(index % text_size, floori(float(index) / float(text_size)))
			
	## reconstruct voxel pos from invocation
	var voxel_index: int = invocation.x + invocation.y * text_size
	voxel_index = int(float(voxel_index) / 6.0 / float(1 << 2 * cascade))
		
	var eff_chunk_size := Vector3(
		96 if cascade % 3 == 0 else 48,
		24 if cascade % 3 == 2 else 96,
		96 if cascade % 3 == 0 else 48
	)
	
	eff_chunk_size /= float(1 << 2 * int(floor(float(cascade) / 3.0)))
	var sample_center := Vector3(.5, .5, .5) * 96.0 / eff_chunk_size
	var sample_pos := Vector3(
		voxel_index % int(eff_chunk_size.x),
		floori(voxel_index % int(eff_chunk_size.x * eff_chunk_size.y) / float(eff_chunk_size.x)),
		floori(voxel_index % int(eff_chunk_size.x * eff_chunk_size.y * eff_chunk_size.z) / float(eff_chunk_size.x * eff_chunk_size.y))
	)
					
	sample_pos = sample_pos + sample_center
	
	return sample_pos

func setup_compute_materials(chunks: int) -> void:
	shader_spirv = compute_shader.get_spirv()
	shader_RID = rd.shader_create_from_spirv(shader_spirv)
	
	var format_data := RDTextureFormat.new()
	format_data.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	format_data.width = text_size
	format_data.height = text_size
	format_data.array_layers = chunks * cascades
	format_data.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	format_data.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	
	vox_text_RID = rd.texture_create(format_data, RDTextureView.new())
	voxel_uniform = RDUniform.new()	
	voxel_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	voxel_uniform.add_id(vox_text_RID)
	
	vox_bytes = PackedVector4Array()
	vox_bytes.resize(text_size * text_size * chunks)
	
	var cascade_bytes = PackedFloat32Array()
	cascade_bytes.resize(text_size * text_size * chunks * cascades)
	cascade_bytes.fill(0.0) 
	var bytes_2: PackedByteArray = cascade_bytes.to_byte_array() 
	rd.texture_update(radiance_text_RID, 0, bytes_2)

	#radiance_uniform = RDUniform.new()	
	#radiance_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	#radiance_uniform.add_id(radiance_text_RID)

func compute_radiance_texture(chunks: int) -> void:
	radiance_uniform = RDUniform.new()	
	radiance_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	radiance_uniform.add_id(radiance_text_RID)

	vox_bytes = grid_to_vec4_array(hierarchy.all_objects.values()[0])
	var bytes: PackedByteArray = vox_bytes.to_byte_array() 
	rd.texture_update(vox_text_RID, 0, bytes)

	var uniform_set_0_RID := rd.uniform_set_create([voxel_uniform], shader_RID, 0)
	var uniform_set_1_RID := rd.uniform_set_create([radiance_uniform], shader_RID, 1)

	for n in range(cascades - 1, -1, -1):
		#var time: int = Time.get_ticks_usec()
		var chunk_width: int = roundi(pow(float(text_size*text_size) / 6.0, 1.0/3.0))
		var push_constant := PackedInt32Array()
		push_constant.push_back(initial_rays)
		push_constant.push_back(initial_ray_length)
		push_constant.push_back(chunk_width)
		push_constant.push_back(n)
		
		var compute_list := rd.compute_list_begin()
		var pipeline_RID := rd.compute_pipeline_create(shader_RID)
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline_RID)
		
		rd.compute_list_bind_uniform_set(compute_list, uniform_set_0_RID, 0)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set_1_RID, 1)
		rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), max(16, push_constant.to_byte_array().size()))
	
		rd.compute_list_dispatch(compute_list, 288, 288, 1)
		rd.compute_list_add_barrier(compute_list)
		rd.compute_list_end()
		
		#print(Time.get_ticks_usec() - time)
	
	rd.free_rid(uniform_set_0_RID)
	
	#var col_arr: PackedColorArray = rd.texture_get_data(radiance_text_RID, 0).to_color_array()
	
	#for col in col_arr:
		#if !col.is_equal_approx(Color(0.0, 0.0, 0.0, 1.0)):
			#print(col)

## skip moving data through CPU from compute to material by using buffer
## https://github.com/godotengine/godot-proposals/issues/6989#issuecomment-2770544670
func match_compute_material_buffers(chunks: int) -> void:
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
	
	radiance_text_RID = rd.texture_create(format_data, RDTextureView.new())
	
	var text_arr := Texture2DArrayRD.new()
	text_arr.texture_rd_rid = radiance_text_RID
	RenderingServer.global_shader_parameter_set("cascade_text_array", text_arr)
	#var mat: Texture2DArrayRD = RenderingServer.global_shader_parameter_get("cascade_text_array")
	#material.set_shader_parameter("cascade_text_array", output_text)
	#var mat: Texture2DArrayRD = material.get_shader_parameter("cascade_text_array")
	

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
