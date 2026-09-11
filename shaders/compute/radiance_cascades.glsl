#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0, rgba32f) uniform restrict image2DArray voxel_data;
layout(set = 1, binding = 0, rgba32f) uniform restrict image2DArray cascade_data;


layout(push_constant, std430) uniform Params {
	int starting_rays;
	int starting_length;
    int vox_chunk_size;
} params;

ivec3 worldPosToVoxelTextCoords(ivec3 world_pos, int layer, int face) {
    ivec3 text_size = imageSize(voxel_data);
    
    int voxel_index = world_pos.x + world_pos.y * params.vox_chunk_size + world_pos.z * params.vox_chunk_size * params.vox_chunk_size;
    // voxel start multiplied by how many faces (pixels) are in a voxel
    voxel_index *= 6;
    int x = voxel_index % text_size.x;
    int y = int(floor(float(voxel_index) / float(text_size.x)));

    return ivec3(x, y, layer);
}

vec3 rayTextToVoxelCoords(ivec3 text_pos) {
    int cascade_index = int(gl_GlobalInvocationID.z);
    int rays = params.starting_rays << (cascade_index * 3);
    float size_ratio = float(1 << cascade_index);
    float rays_f = float(rays);
    int chunk_size = params.vox_chunk_size;

    ivec3 radiance_text_size = imageSize(cascade_data);
    int text_index = text_pos.x + text_pos.y * radiance_text_size.x;
    text_index = int(float(text_index) / 6.0);

    int x = int(float(text_index % chunk_size) / size_ratio);
    int y = int(float(text_index % (chunk_size * chunk_size)) / float(chunk_size) / size_ratio);
    int z = int(float(text_index % (chunk_size * chunk_size * chunk_size)) / float(chunk_size * chunk_size) / size_ratio);
    return vec3(x, y, z);
}

vec4 sampleWorld(vec3 world_pos) {
    world_pos.x = clamp(world_pos.x, 0, params.vox_chunk_size);
    world_pos.y = clamp(world_pos.y, 0, params.vox_chunk_size);
    world_pos.z = clamp(world_pos.z, 0, params.vox_chunk_size);
    ivec3 sample_pos = worldPosToVoxelTextCoords(ivec3(world_pos), 0, 0);
    vec4 col = imageLoad(voxel_data, sample_pos);
    
    return col;
}

vec3 sample_directional_lights(vec3 world_pos) {
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
    int rays = params.starting_rays << (cascade_index * 3);
    ivec3 dir = sign(ivec3(offset));

    vec3 radiance = vec3(0.0);
    float transmittance = 1.0;

    int ray_start_length = 1 + sign(cascade_index) * (params.starting_length << (cascade_index - 1));
    int ray_end_length = 1 + sign(cascade_index + 1) * (params.starting_length << cascade_index);

    for (int i = ray_start_length; i < ray_end_length; i++){
        vec3 sample_pos = ray_start + dir * (i + 1);
        vec4 world_data = sampleWorld(sample_pos);

        float current_transmittance = max(transmittance, 0.0);
        radiance += sample_directional_lights(sample_pos) * current_transmittance;
        radiance += world_data.rgb * current_transmittance;
        // >1 alpha used for emission
        transmittance -= min(world_data.a, 1.0);
    }

    if (radiance != vec3(0.0, 0.0, 0.0)) {
        radiance = normalize(radiance);
    }

    return vec4(radiance, transmittance);
}

void main() {
    ivec3 voxel_text_size = imageSize(voxel_data);
    ivec3 radiance_text_size = imageSize(cascade_data);

    int cascade_index = int(gl_GlobalInvocationID.z);
    int rays = params.starting_rays << (cascade_index * 3);

    int text_index = int(gl_GlobalInvocationID.x) + int(gl_GlobalInvocationID.y) * radiance_text_size.x;
    int ray_index = text_index % 6;

    vec3 sample_pos = rayTextToVoxelCoords(ivec3(gl_GlobalInvocationID));
    vec3 offset = vec3(0.0);

    if (ray_index == 0){
        offset = vec3(1.0, 0.0, 0.0);
    }
    else if (ray_index == 1){
        offset = vec3(-1.0, 0.0, 0.0);
    }
    else if (ray_index == 2){
        offset = vec3(0.0, 1.0, 0.0);
    }
    else if (ray_index == 3){
        offset = vec3(0.0, -1.0, 0.0);
    }
    else if (ray_index == 4){
        offset = vec3(0.0, 0.0, 1.0);
    }
    else {
        offset = vec3(0.0, 0.0, -1.0);
    }
    vec4 col = intersectRay(sample_pos, offset, 0);
    col += sampleWorld(sample_pos);

    imageStore(cascade_data, ivec3(gl_GlobalInvocationID), col);
}