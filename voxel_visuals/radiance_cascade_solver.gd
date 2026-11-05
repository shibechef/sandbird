extends Node
class_name RadianceCascadeSolver

var hierarchy: Hierarchy
var palette_manager: ColorPaletteManager

var voxel_input_uniform: RDUniform
var output_text: Texture2DArrayRD = Texture2DArrayRD.new()

var compute_shader = load("res://shaders/compute/radiance_cascades.glsl")
var material: ShaderMaterial = load("res://materials/cascade_simple.tres")

var vox_text_format: RDTextureFormat
var radiance_text_format: RDTextureFormat
var copying_text_format: RDTextureFormat
var ray_dir_text_format: RDTextureFormat
var ray_dot_text_format: RDTextureFormat

var vox_text_RID: RID
var radiance_text_RID: RID
var copying_text_RID: RID
var ray_dir_text_RID: RID
var ray_dot_text_RID: RID

var voxel_uniform: RDUniform
var radiance_uniform: RDUniform
var ray_dir_uniform: RDUniform
var ray_dot_uniform: RDUniform

var rd: RenderingDevice
var radiance_shader_spirv: RDShaderSPIRV
var radiance_shader_RID: RID
var dir_light_shader_spirv: RDShaderSPIRV
var dir_light_shader_RID: RDShaderSPIRV

var text_size: int = 2304
var chunk_size: int = 96
var cascades: int = 4
var initial_rays: int = 6
var initial_ray_length: int = 4

func _ready():
	#test_shit_math()
	hierarchy = get_node("%Hierarchy")
	palette_manager = get_node("%ColorPaletteManager")
	
	var chunks: int = 1
	rd = RenderingServer.get_rendering_device()
	setup_text_formats(chunks)
	create_ray_dir_texture()
	create_ray_dot_texture()
	match_compute_material_buffers(chunks)
	setup_compute_materials(chunks)
	#display_debug_visuals(3)

func display_debug_visuals(cascade: int) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = ArrayMesh.new()
	
	var rays: int = 6 << (cascade * 2)
	var rays_per_face_axis: float = float(1 << cascade)
	
	var vertices: PackedVector3Array
	var colors: PackedColorArray
	
	for i in 6*96*96*96:
		var ray_index: int = i % rays
		var face = int(floor(6.0 * float(ray_index) / float(rays)));
		
		var pos: Vector3 = test_position_sampling(i, cascade)
		var face_offset: float = 0.5 / rays_per_face_axis;
		var ray_axis_1: float = -1.0 + 2.0 * (face_offset + float(ray_index % int(rays_per_face_axis)) / rays_per_face_axis);
		var ray_axis_2: float = -1.0 + 2.0 * (face_offset + float(ray_index % int(rays_per_face_axis * rays_per_face_axis)) / rays_per_face_axis / rays_per_face_axis);
		
		var offset := Vector3.ZERO
		offset = offset if face != 0 else Vector3(1.0, ray_axis_1, ray_axis_2);
		offset = offset if face != 1 else Vector3(-1.0, ray_axis_1, ray_axis_2);
		offset = offset if face != 2 else Vector3(ray_axis_1, 1.0, ray_axis_2);
		offset = offset if face != 3 else Vector3(ray_axis_1, -1.0, ray_axis_2);
		offset = offset if face != 4 else Vector3(ray_axis_1, ray_axis_2, 1.0);
		offset = offset if face != 5 else Vector3(ray_axis_1, ray_axis_2, -1.0);
		
		offset = offset.normalized()
		
		vertices.append(pos)
		vertices.append(pos + offset * .2)
		colors.append(Color.WHITE)
		colors.append(Color.BLACK)
	
	var mesh_arrays: Array = [] 
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	mesh_arrays[Mesh.ARRAY_VERTEX] = vertices
	mesh_arrays[Mesh.ARRAY_COLOR] = colors
	
	mesh_instance.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, mesh_arrays)
	mesh_instance.mesh.surface_set_material(0, load("res://materials/literally_vert_color.tres"))
	get_node("%Hierarchy").add_child(mesh_instance)
	
	var data: PackedColorArray = rd.texture_get_data(radiance_text_RID, 0).to_color_array()

func setup_compute_materials(chunks: int) -> void:
	radiance_shader_spirv = compute_shader.get_spirv()
	radiance_shader_RID = rd.shader_create_from_spirv(radiance_shader_spirv)
	
	vox_text_RID = rd.texture_create(vox_text_format, RDTextureView.new())
	voxel_uniform = RDUniform.new()	
	voxel_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	voxel_uniform.add_id(vox_text_RID)
	
	radiance_uniform = RDUniform.new()	
	radiance_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	radiance_uniform.add_id(radiance_text_RID)

	copying_text_RID = rd.texture_create(copying_text_format, RDTextureView.new())
		
	var cascade_bytes = PackedFloat32Array()
	cascade_bytes.resize(text_size * text_size * chunks * cascades)
	cascade_bytes.fill(0.0) 
	var bytes_2: PackedByteArray = cascade_bytes.to_byte_array() 
	rd.texture_update(radiance_text_RID, 0, bytes_2)

func compute_radiance_texture(chunks: int) -> void:	
	var uniform_set_0_RID := rd.uniform_set_create([voxel_uniform], radiance_shader_RID, 0)
	var uniform_set_1_RID := rd.uniform_set_create([radiance_uniform], radiance_shader_RID, 1)
	var uniform_set_2_RID := rd.uniform_set_create([ray_dir_uniform], radiance_shader_RID, 2)
	var uniform_set_3_RID := rd.uniform_set_create([ray_dot_uniform], radiance_shader_RID, 3)
	
	for n in range(cascades - 1, -1, -1):
		var chunk_width: int = roundi(pow(float(text_size*text_size) / 6.0, 1.0/3.0))
		var push_constant := PackedInt32Array()
		push_constant.push_back(initial_rays)
		push_constant.push_back(initial_ray_length)
		push_constant.push_back(chunk_width)
		push_constant.push_back(n)
		push_constant.push_back(cascades)
		push_constant.push_back(0)
		push_constant.push_back(0)
		push_constant.push_back(0)
		assert(push_constant.to_byte_array().size() % 16 == 0, "fix the damn push constant")
		
		var compute_list := rd.compute_list_begin()
		var pipeline_RID := rd.compute_pipeline_create(radiance_shader_RID)
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline_RID)
		
		rd.compute_list_bind_uniform_set(compute_list, uniform_set_0_RID, 0)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set_1_RID, 1)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set_2_RID, 2)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set_3_RID, 3)
		rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.to_byte_array().size())

		rd.compute_list_dispatch(compute_list, 288, 288, 1)
		rd.compute_list_add_barrier(compute_list)
		rd.compute_list_end()
					
	rd.free_rid(uniform_set_0_RID)
	
	#var col_arr: PackedColorArray = rd.texture_get_data(radiance_text_RID, 0).to_color_array()
	
	#for col in col_arr:
		#if !col.is_equal_approx(Color(0.0, 0.0, 0.0, 1.0)):
			#print(col)

## skip moving data through CPU from compute to material by using buffer
## https://github.com/godotengine/godot-proposals/issues/6989#issuecomment-2770544670
func match_compute_material_buffers(chunks: int) -> void:	
	radiance_text_RID = rd.texture_create(radiance_text_format, RDTextureView.new())
	
	var text_arr := Texture2DArrayRD.new()
	text_arr.texture_rd_rid = radiance_text_RID
	RenderingServer.global_shader_parameter_set("cascade_text_array", text_arr)
	
var empty: PackedVector4Array = PackedVector4Array([Vector4.ZERO, Vector4.ZERO, Vector4.ZERO, Vector4.ZERO, Vector4.ZERO, Vector4.ZERO])

func update_voxel_text(position: Vector3i, voxel: VoxelData) -> void:
	var cols: PackedVector4Array
	
	if voxel == null:
		cols.append_array(empty)
	elif voxel.face_colors.size() == 1:
		var color: Color = palette_manager.get_color_from_id(voxel.face_colors[0]).color
		for i in 6:
			cols.append(color_to_vec4(color))
	else:
		for i in 6:
			var color: Color = palette_manager.get_color_from_id(voxel.face_colors[i]).color
			cols.append(color_to_vec4(color))

	var voxel_index: int = position.x + position.y * chunk_size + position.z * chunk_size * chunk_size
	voxel_index *= 6
	var text_coords := Vector3(voxel_index % text_size, floor(float(voxel_index) / float(text_size)), 0.0)
	rd.texture_update(copying_text_RID, 0, cols.to_byte_array())
	rd.texture_copy(copying_text_RID, vox_text_RID, Vector3.ZERO, text_coords, Vector3(6.0, 1.0, 1.0), 0, 0, 0, 0)

func grid_to_vec4_array(voxel_object: VoxelObject) -> PackedVector4Array:	
	## quicker to simply append empty arrays 
	## than to preset an array size and set() repeatedly
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

func get_ray_direction(ray_index: int, rays: int, rays_per_face_axis: int) -> Vector3:
	var direction: Vector3
	
	var face: int = int(floor(6.0 * float(ray_index) / float(rays)));
	var face_offset: float = 0.5 / rays_per_face_axis;
	var ray_axis_1: float = -1.0 + 2.0 * (face_offset + float(ray_index % int(rays_per_face_axis)) / rays_per_face_axis);
	var ray_axis_2: float = -1.0 + 2.0 * (face_offset + float(ray_index % int(rays_per_face_axis * rays_per_face_axis)) / rays_per_face_axis / rays_per_face_axis);
	
	match face:
		0:
			direction = Vector3(1.0, ray_axis_1, ray_axis_2)
		1:
			direction = Vector3(-1.0, ray_axis_1, ray_axis_2)
		2:
			direction = Vector3(ray_axis_1, 1.0, ray_axis_2)
		3:
			direction = Vector3(ray_axis_1, -1.0, ray_axis_2)
		4:
			direction = Vector3(ray_axis_1, ray_axis_2, 1.0)
		5:
			direction = Vector3(ray_axis_1, ray_axis_2, -1.0)
			
	direction = direction.normalized()
	
	return direction

func create_ray_dir_texture() -> void:
	ray_dir_text_RID = rd.texture_create(ray_dir_text_format, RDTextureView.new())
	ray_dir_uniform = RDUniform.new()	
	ray_dir_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	ray_dir_uniform.add_id(ray_dir_text_RID)
	
	var max_rays: int = initial_rays << 2 * (cascades - 1)
	## skip first cascade as you only look upwards
	for cascade in cascades:
		var angles: PackedVector4Array
		var rays: int = initial_rays << 2 * cascade
		var rays_per_face_axis: int = 1 << cascade;
		for ray in max_rays:
			if ray < rays:
				var angle: Vector3 = get_ray_direction(ray, rays, rays_per_face_axis)
				angles.append(Vector4(angle.x, angle.y, angle.z, 0.0));
			else:
				angles.append(Vector4(0.0, 0.0, 0.0, 0.0))

		var bytes: PackedByteArray = angles.to_byte_array()
		rd.texture_update(ray_dir_text_RID, cascade, bytes)
	
func create_ray_dot_texture() -> void:
	ray_dot_text_RID = rd.texture_create(ray_dot_text_format, RDTextureView.new())
	ray_dot_uniform = RDUniform.new()	
	ray_dot_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	ray_dot_uniform.add_id(ray_dot_text_RID)
	
	var max_rays: int = initial_rays << 2 * (cascades - 1)	
	
	## skip first cascade as you only look upwards
	for cascade in range(1, cascades):
		var pairs: PackedVector2Array
		var rays: int = initial_rays << 2 * cascade
		var rays_per_face_axis: int = 1 << cascade;
		var rays_half: int = int(float(rays) / 2.0)
		for ray in rays:
			var local_pairs: Array = []
			var angle_1: Vector3 = get_ray_direction(ray, rays, rays_per_face_axis)
			
			for ray_2 in rays:
				var angle_2: Vector3 = get_ray_direction(ray_2, rays, rays_per_face_axis)
				var dot: float = max(0.0, angle_1.dot(angle_2))
				local_pairs.append([ray_2, dot]);
			
			local_pairs.sort_custom(func(a, b): return a[1] > b[1])
			
			for n in rays_half:
				pairs.append(Vector2(local_pairs[n][0], local_pairs[n][1]))
		
		pairs.resize(max_rays * int(float(max_rays) / 2.0))
		
		var bytes: PackedByteArray = pairs.to_byte_array()
		rd.texture_update(ray_dot_text_RID, cascade - 1, bytes)

func solve_global_lights() -> void:
	## for every chunk figure out what chunks it will need to calculate into the sun
	## every chunk will just do an AABB line test starting at each corner,
	## against every other chunk's AABB
	## should definitely use the same size as voxel text data to avoid conversion
	## could probably just do "compute shader, find the next linked voxel"
	## this fits well in the compute shader format,
	## as each voxel is just looking for the next chain rather than the whole chain
	## it should start at the highest chain of voxels, set itself to sun color,
	## then go along a slice of the biggest directional axis. 
	## so if the sun is mostly +y, go along a +y slice of invocations for the chunk
	## if transparency is <1, cut it, and the next will use what's left
	return

func setup_text_formats(chunks: int) -> void:
	vox_text_format = RDTextureFormat.new()
	vox_text_format.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	vox_text_format.width = text_size
	vox_text_format.height = text_size
	vox_text_format.array_layers = chunks * cascades
	vox_text_format.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	vox_text_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT
		
	radiance_text_format = RDTextureFormat.new()
	radiance_text_format.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	radiance_text_format.width = text_size
	radiance_text_format.height = text_size
	radiance_text_format.array_layers = chunks * cascades
	radiance_text_format.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	radiance_text_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + \
	RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	
	copying_text_format = RDTextureFormat.new()
	copying_text_format.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	copying_text_format.width = 6
	copying_text_format.height = 1
	copying_text_format.array_layers = 1
	copying_text_format.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	copying_text_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	
	var rays: int = initial_rays << (2 * (cascades - 1))
	
	## alpha is wasted but R11G11B10 seems bad
	ray_dir_text_format = RDTextureFormat.new()
	ray_dir_text_format.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	ray_dir_text_format.width = rays
	ray_dir_text_format.height = 1
	ray_dir_text_format.array_layers = cascades
	ray_dir_text_format.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	ray_dir_text_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + \
	RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	
	## a lot of wasted texture space on smaller cascades,
	## but its still so tiny.
	ray_dot_text_format = RDTextureFormat.new()
	ray_dot_text_format.format = RenderingDevice.DATA_FORMAT_R32G32_SFLOAT
	ray_dot_text_format.width = rays
	ray_dot_text_format.height = int(float(rays) / 2.0)
	ray_dot_text_format.array_layers = cascades - 1
	ray_dot_text_format.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	ray_dot_text_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
	RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + \
	RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT

func test_shit_math() -> void:
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
					
		for index in tested_indices:
			var pos := test_position_sampling(index, cascade)
			
			var invocation := Vector2i(index % text_size, floori(float(index) / float(text_size)))
			var voxel_index: int = (invocation.x + invocation.y * text_size)
				
			var ray_index: int = voxel_index % current_rays
			var face: int = floori(6 * float(ray_index) / float(current_rays))
			var rays_per_face_axis: float = float(1 << cascade)
			var offset: float = 0.5 / rays_per_face_axis
			var ray_axis_1: float = -1.0 + 2.0 * (offset + float(ray_index % int(rays_per_face_axis)) / rays_per_face_axis)
			var ray_axis_2: float = -1.0 + 2.0 * (offset + float(ray_index % int(rays_per_face_axis)) / rays_per_face_axis / rays_per_face_axis)
			print(rays_per_face_axis, " ", offset, " ", ray_axis_1, " ", ray_axis_2)

func test_position_sampling(index: int, cascade: int) -> Vector3:
	var invocation := Vector2i(index % text_size, floori(float(index) / float(text_size)))
			
	## reconstruct voxel pos from invocation
	var voxel_index: int = invocation.x + invocation.y * text_size
	voxel_index = int(float(voxel_index) / 6.0 / float(1 << 2 * cascade))
		
	var chunk_size_f := float(chunk_size)
	## basically it goes 96x96x96, 48x96x48, 48x24x48, 24x24x24...
	## to shrink down 4x every cascade to keep up with the rays going up 4x
	var eff_chunk_size := Vector3(
		chunk_size_f if cascade % 3 == 0 else chunk_size_f / 2.0,
		chunk_size_f / 4.0 if cascade % 3 == 2 else chunk_size_f,
		chunk_size_f if cascade % 3 == 0 else chunk_size_f / 2.0
	)
	eff_chunk_size /= float(1 << 2 * int(floor(float(cascade) / 3.0)))
	
	var sample_center := Vector3(.5, .5, .5) * chunk_size_f / eff_chunk_size
	var sample_pos := Vector3(
		voxel_index % int(eff_chunk_size.x),
		floori(voxel_index % int(eff_chunk_size.x * eff_chunk_size.y) / eff_chunk_size.x),
		floori(voxel_index % int(eff_chunk_size.x * eff_chunk_size.y * eff_chunk_size.z) / eff_chunk_size.x / eff_chunk_size.y)
	)
	sample_pos *= Vector3(chunk_size_f, chunk_size_f, chunk_size_f) / eff_chunk_size
					
	sample_pos = sample_pos + sample_center
	
	return sample_pos

func color_to_vec4(color: Color) -> Vector4:
	return Vector4(color.r, color.g, color.b, color.a) 
