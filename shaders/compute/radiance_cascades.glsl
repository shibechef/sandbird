#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0, rgba32f) uniform restrict image2DArray voxel_data;
layout(set = 1, binding = 0, rgba32f) uniform restrict image2DArray cascade_data;

layout(push_constant, std430) uniform Params {
	int starting_rays;
	int starting_length;
    int vox_chunk_size;
    int cascade_index;
    int cascades;
} params;

vec3 getEffectiveChunkSize(int cascade_index) {
    float chunk_size_f = float(params.vox_chunk_size);
	// basically it goes 96x96x96, 48x96x48, 48x24x48, 24x24x24...
	// to shrink down 4x every cascade to keep up with the rays going up 4x
    vec3 effective_chunk_size = vec3(
        cascade_index % 3 == 0 ? chunk_size_f : chunk_size_f / 2.0,
        cascade_index % 3 == 2 ? chunk_size_f / 4.0 : chunk_size_f,
        cascade_index % 3 == 0 ? chunk_size_f : chunk_size_f / 2.0
    );    
    effective_chunk_size /= float(1 << 2 * int(floor(float(cascade_index) / 3.0)));
    return effective_chunk_size;
}

ivec3 worldPosToVoxelTextCoords(ivec3 world_pos, int layer, int face) {
    ivec3 text_size = imageSize(voxel_data);
    
    int voxel_index = world_pos.x + world_pos.y * params.vox_chunk_size + world_pos.z * params.vox_chunk_size * params.vox_chunk_size;
    // voxel start multiplied by how many faces (pixels) are in a voxel
    voxel_index *= 6;
    int x = voxel_index % text_size.x;
    int y = int(floor(float(voxel_index) / float(text_size.x)));

    return ivec3(x, y, layer);
}

ivec2 indexToTextPos(int index) {
    ivec3 text_size = imageSize(voxel_data);

    int x = index % text_size.x;
    int y = int(floor(float(index) / float(text_size.x)));
    return ivec2(x, y);
}

vec3 rayTextToVoxelCoords(ivec2 text_pos, int cascade_index) {
    ivec3 radiance_text_size = imageSize(cascade_data);
    int voxel_index = text_pos.x + text_pos.y * radiance_text_size.x;
    voxel_index = int(float(voxel_index) / 6.0 / float(1 << 2 * cascade_index));

    vec3 effective_chunk_size = getEffectiveChunkSize(cascade_index);
    
    vec3 center = vec3(0.5) * float(params.vox_chunk_size) / effective_chunk_size;
    float x = float(voxel_index % int(effective_chunk_size.x));
    float y = float(voxel_index % int(effective_chunk_size.x * effective_chunk_size.y)) / effective_chunk_size.x;
    float z = float(voxel_index % int(effective_chunk_size.x * effective_chunk_size.y * effective_chunk_size.z)) / effective_chunk_size.x / effective_chunk_size.y;

    vec3 pos = vec3(x, y, z) * float(params.vox_chunk_size) / effective_chunk_size;

    return pos + center;
}

ivec3 isCorner(int voxel_index, int cascade_index) {    
    vec3 effective_chunk_size = getEffectiveChunkSize(cascade_index);
    voxel_index = int(float(voxel_index) / 6.0 / float(1 << 2 * cascade_index));
    
    return ivec3(
        voxel_index % int(effective_chunk_size.x) == int(effective_chunk_size.x) - 1 ? 0 : 1,
        int(float(voxel_index % int(effective_chunk_size.x * effective_chunk_size.y)) / effective_chunk_size.x) == int(effective_chunk_size.y) - 1 ? 0 : 1,
        int(float(voxel_index % int(effective_chunk_size.x * effective_chunk_size.y * effective_chunk_size.z)) / effective_chunk_size.x / effective_chunk_size.y) == int(effective_chunk_size.z) - 1 ? 0 : 1
    );
}

int[8] getNearbyPoints(int starting_point, int cascade_index, ivec3 corner) {
    int rays = params.starting_rays << (cascade_index * 2);
    vec3 effective_chunk_size = getEffectiveChunkSize(cascade_index);

    int x_spacing = rays * corner.x;
    int y_spacing = rays * int(effective_chunk_size.x) * corner.y;
    int z_spacing = rays * int(effective_chunk_size.x) * int(effective_chunk_size.y) * corner.z;

    return int[8](
        starting_point, 
        starting_point + x_spacing,
        starting_point + y_spacing,
        starting_point + y_spacing + x_spacing,
        starting_point + z_spacing,
        starting_point + x_spacing + z_spacing,
        starting_point + y_spacing + z_spacing,
        starting_point + x_spacing + y_spacing + z_spacing
    );
}

int voxelCoordsToIndex(vec3 coords, int cascade_index) {
    int rays = params.starting_rays << (cascade_index * 2);
    vec3 effective_chunk_size = getEffectiveChunkSize(cascade_index);

    vec3 center = vec3(0.5) * float(params.vox_chunk_size) / effective_chunk_size;
    coords -= center;

    coords *= effective_chunk_size / vec3(float(params.vox_chunk_size));

    int index = int(coords.x) + int(coords.y) * int(effective_chunk_size) + int(coords.z) * int(effective_chunk_size.x) * int(effective_chunk_size.y);
    index *= rays;

    return index;
}

vec4 sampleWorld(vec3 world_pos) {
    world_pos.x = clamp(world_pos.x, 0, params.vox_chunk_size);
    world_pos.y = clamp(world_pos.y, 0, params.vox_chunk_size);
    world_pos.z = clamp(world_pos.z, 0, params.vox_chunk_size);
    
    ivec3 sample_pos = worldPosToVoxelTextCoords(ivec3(floor(world_pos)), 0, 0);
    vec4 col = imageLoad(voxel_data, sample_pos);
    
    return col;
}

vec3 sampleDirectionalLights(vec3 world_pos) {
    vec3 light_rotation = normalize(vec3(1.0, 1.0, 1.0));
    vec3 centralized_pos = world_pos - vec3(params.vox_chunk_size) / 2.0;

    if (dot(light_rotation, normalize(centralized_pos)) < 0.0)
        return vec3(0.0);
    if (world_pos.x > params.vox_chunk_size || world_pos.x < 0.0 ||
    world_pos.y > params.vox_chunk_size || world_pos.y < 0.0 ||
    world_pos.z > params.vox_chunk_size || world_pos.z < 0.0) {
        return vec3(1.0);
    }
    return vec3(0.0);
}

vec4 intersectRay(vec3 ray_start, vec3 offset, int cascade_index) {
    int rays = params.starting_rays << (cascade_index * 2);

    vec3 radiance = vec3(0.0);
    float transmittance = 1.0;

    int ray_start_length = 1 + int(sign(cascade_index)) * (params.starting_length << (cascade_index - 1));
    int ray_end_length = 1 + (params.starting_length << cascade_index);
    
    for (int i = ray_start_length; i < ray_end_length; i++) {
        vec3 sample_pos = ray_start + offset * float(i);
        vec4 world_data = sampleWorld(sample_pos);

        float current_transmittance = max(transmittance, 0.0);
        //radiance += sampleDirectionalLights(sample_pos) * current_transmittance;
        radiance += world_data.rgb * current_transmittance;
        // >1 alpha used for emission
        transmittance -= min(world_data.a, 1.0);

        if (transmittance < 0.0)
            break;
    }

    if (radiance != vec3(0.0, 0.0, 0.0)) {
        radiance = normalize(radiance);
    }

    return vec4(radiance, transmittance);
}

vec4 faceToFaceTranslation(int starting_index, int starting_face, int ray_axis_1, int ray_axis_2) {
    int rays = params.starting_rays << (params.cascade_index * 2);
    int rays_per_face_axis = 1 << starting_index;
    ivec3 cube_pos = ivec3(0);

    // traveling any direction past the initial face of a cube can just be solved by moving further from the axis that the face lies on,
    // while increasing the axis you're moving in but clamped to the min/max to align with the next face
    int surplus = max(ray_axis_1, rays_per_face_axis - 1) - min(ray_axis_1, 1) + max(ray_axis_2, rays_per_face_axis - 1) - min(ray_axis_2, 1);

    cube_pos = starting_face != 0 ? cube_pos : ivec3(rays_per_face_axis - surplus, ray_axis_1, ray_axis_2);
    cube_pos = starting_face != 1 ? cube_pos : ivec3(surplus, ray_axis_1, ray_axis_2);
    cube_pos = starting_face != 2 ? cube_pos : ivec3(ray_axis_1, rays_per_face_axis - surplus, ray_axis_2);
    cube_pos = starting_face != 3 ? cube_pos : ivec3(ray_axis_1, surplus, ray_axis_2);
    cube_pos = starting_face != 4 ? cube_pos : ivec3(ray_axis_1, ray_axis_2, rays_per_face_axis - surplus);
    cube_pos = starting_face != 5 ? cube_pos : ivec3(ray_axis_1, ray_axis_2, surplus);

    cube_pos = clamp(cube_pos, 0, rays_per_face_axis);

    int text_index = 0;

    int rays_per_face = rays_per_face_axis * rays_per_face_axis;
    text_index = cube_pos.x != rays_per_face_axis ? text_index : cube_pos.y + cube_pos.z * rays_per_face_axis;
    text_index = cube_pos.x != 0 ? text_index : cube_pos.y + cube_pos.z * rays_per_face_axis + rays_per_face;
    text_index = cube_pos.y != rays_per_face_axis ? text_index : cube_pos.x + cube_pos.z * rays_per_face_axis + rays_per_face * 2;
    text_index = cube_pos.y != 0 ? text_index : cube_pos.x + cube_pos.z * rays_per_face_axis + rays_per_face * 3;
    text_index = cube_pos.z != rays_per_face_axis ? text_index : cube_pos.x + cube_pos.y * rays_per_face_axis + rays_per_face * 4;
    text_index = cube_pos.z != 0 ? text_index : cube_pos.x + cube_pos.y * rays_per_face_axis + rays_per_face * 5;

    return imageLoad(cascade_data, ivec3(indexToTextPos(text_index), starting_index));
}

void main() {
    ivec3 voxel_text_size = imageSize(voxel_data);
    ivec3 radiance_text_size = imageSize(cascade_data);

    int rays = params.starting_rays << (params.cascade_index * 2);

    int text_index = int(gl_GlobalInvocationID.x) + int(gl_GlobalInvocationID.y) * radiance_text_size.x;
    int ray_index = text_index % rays;

    vec3 sample_pos = rayTextToVoxelCoords(ivec2(gl_GlobalInvocationID.xy), params.cascade_index);
    vec3 offset = vec3(0.0);
    
    // mapping ray direction to points on a subdivided cube
    int face = int(floor(6.0 * float(ray_index) / float(rays)));
    float rays_per_face_axis = float(1 << params.cascade_index);

    ivec2 face_2d_pos = ivec2(ray_index % int(rays_per_face_axis), int(float(ray_index % int(rays_per_face_axis)) / rays_per_face_axis));

    float face_offset = 0.5 / rays_per_face_axis;
    float ray_axis_1 = -1.0 + 2.0 * (face_offset + float(ray_index % int(rays_per_face_axis)) / rays_per_face_axis);
    float ray_axis_2 = -1.0 + 2.0 * (face_offset + float(ray_index % int(rays_per_face_axis)) / rays_per_face_axis / rays_per_face_axis);
        
    offset = face != 0 ? offset : vec3(1.0, ray_axis_1, ray_axis_2);
    offset = face != 1 ? offset : vec3(-1.0, ray_axis_1, ray_axis_2);
    offset = face != 2 ? offset : vec3(ray_axis_1, 1.0, ray_axis_2);
    offset = face != 3 ? offset : vec3(ray_axis_1, -1.0, ray_axis_2);
    offset = face != 4 ? offset : vec3(ray_axis_1, ray_axis_2, 1.0);
    offset = face != 5 ? offset : vec3(ray_axis_1, ray_axis_2, -1.0);

    // spherically mapping the cube
    offset = normalize(offset);

    vec4 col = intersectRay(sample_pos, offset, params.cascade_index);

    int upper_cascade = params.cascade_index + 1;
    int starting_upper_index = voxelCoordsToIndex(sample_pos, upper_cascade);
    vec3 starting_upper_pos = rayTextToVoxelCoords(indexToTextPos(starting_upper_index), upper_cascade);
    float x_bias = (sample_pos.x - starting_upper_pos.x);
    float y_bias = (sample_pos.y - starting_upper_pos.y);
    float z_bias = (sample_pos.z - starting_upper_pos.z);

    ivec3 corner = isCorner(starting_upper_index, upper_cascade);
    int[8] points = getNearbyPoints(starting_upper_index, upper_cascade, corner);
    int point = 0;

    vec4 upper_cascade_color = vec4(0.0);

    int ray_angular_samples = 1 << (params.cascade_index * 2) - 1;

    for (int z = 0; z < 2; z++) {
        for (int y = 0; y < 2; y++) {
            for (int x = 0; x < 2; x++) {
                float bias = (x == 0 ? 1.0 - x_bias : x_bias) + (y == 0 ? 1.0 - y_bias : y_bias) + (z == 0 ? 1.0 - z_bias : z_bias);
                ivec2 text_pos = indexToTextPos(points[point]);
                if (upper_cascade != params.cascades) {
                    for (int x_text = -ray_angular_samples; x_text < ray_angular_samples; x_text++) {
                        for (int y_text = -ray_angular_samples; y_text < ray_angular_samples; y_text++) {
                            ivec2 offset_pos = face_2d_pos + ivec2(x_text, y_text);
                            // just make sure it doesn't go into the corners?
                            if ((offset_pos.x > rays_per_face_axis || offset_pos.x < 0) && (offset_pos.y > rays_per_face_axis || offset_pos.y < 0)) {
                                continue;
                            }
                            upper_cascade_color += bias * faceToFaceTranslation(points[point], face, x_text, y_text);
                        }
                    }
                    upper_cascade_color += imageLoad(cascade_data, ivec3(text_pos, upper_cascade)) * bias;
                }
                point += 1;
            }
        }
    }

    if (params.cascade_index != 0) {
        col.rgb = sample_pos / 96.0;
    }
    else {
        col.rgb = vec3(0.0);
    }

    if (upper_cascade != params.cascades) {
        col.rgb += col.rgb / 2.0 + upper_cascade_color.rgb / 16.0;
    }

    imageStore(cascade_data, ivec3(gl_GlobalInvocationID.xy, params.cascade_index), col);
}