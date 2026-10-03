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
    int rays = params.starting_rays << (cascade_index * 2);

    ivec3 radiance_text_size = imageSize(cascade_data);
    int voxel_index = text_pos.x + text_pos.y * radiance_text_size.x;
    voxel_index = int(floor(float(voxel_index) / 6.0));
    voxel_index = int(float(voxel_index / 4.0)) * 4;

    int probes_per_axis = 96;//params.vox_chunk_size << 2 * int(floor(float(cascade_index) / 3.0));

    // as the 3 axes cannot be uniformly shrunk, it goes 96x96x96, 48x96x48, 48x24x48, 24x24x24 etc
    vec3 probe_shrinkage = vec3(
        cascade_index % 3 == 0 ? 1.0 : 2.0,
        cascade_index % 3 == 2 ? 4.0 : 1.0,
        cascade_index % 3 == 0 ? 1.0 : 2.0
    );    

    int ya = cascade_index % 3 == 2 ? 2 : 1;
    
    vec3 center = vec3(0.5 / float(params.vox_chunk_size));
    float x = float(voxel_index % params.vox_chunk_size);
    float y = float(voxel_index % (params.vox_chunk_size * params.vox_chunk_size)) / float(params.vox_chunk_size);
    float z = float(voxel_index % (params.vox_chunk_size * params.vox_chunk_size * params.vox_chunk_size)) / float(params.vox_chunk_size * params.vox_chunk_size);

    return vec3(x, y, z) / probe_shrinkage;
}

vec4 sampleWorld(vec3 world_pos) {
    world_pos.x = clamp(world_pos.x, 0, params.vox_chunk_size);
    world_pos.y = clamp(world_pos.y, 0, params.vox_chunk_size);
    world_pos.z = clamp(world_pos.z, 0, params.vox_chunk_size);
    
    ivec3 sample_pos = worldPosToVoxelTextCoords(ivec3(floor(world_pos)), 0, 0);
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
    int rays = params.starting_rays << (cascade_index * 2);

    vec3 radiance = vec3(0.0);
    float transmittance = 1.0;

    int ray_start_length = 1 + int(sign(cascade_index)) * (params.starting_length << (cascade_index - 1));
    int ray_end_length = 1 + (params.starting_length << cascade_index);
    
    for (int i = ray_start_length; i < ray_end_length; i++){
        vec3 sample_pos = ray_start + offset * float(i);
        vec4 world_data = sampleWorld(sample_pos);

        float current_transmittance = max(transmittance, 0.0);
        //radiance += sample_directional_lights(sample_pos) * current_transmittance;
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

void main() {
    ivec3 voxel_text_size = imageSize(voxel_data);
    ivec3 radiance_text_size = imageSize(cascade_data);

    int cascade_index = int(gl_GlobalInvocationID.z);
    int rays = params.starting_rays << (cascade_index * 2);

    int text_index = int(gl_GlobalInvocationID.x) + int(gl_GlobalInvocationID.y) * radiance_text_size.x;
    int ray_index = text_index % rays;

    vec3 sample_pos = rayTextToVoxelCoords(ivec3(gl_GlobalInvocationID));
    vec3 offset = vec3(0.0);
    
    // mapping ray direction to points on a subdivided cube
    int face = int(floor(6.0 * float(ray_index) / float(rays)));
    float rays_per_face_axis = float(rays) / 6.0;

    float face_offset = 0.5 / rays_per_face_axis;
    float ray_axis_1 = -1.0 + 2.0 * (face_offset + float(ray_index % int(rays_per_face_axis)) / rays_per_face_axis);
    float ray_axis_2 = -1.0 + 2.0 * (face_offset + float(ray_index % int(rays_per_face_axis)) / rays_per_face_axis / rays_per_face_axis);
        
    offset = face == 0 ? vec3(1.0, ray_axis_1, ray_axis_2) : offset;
    offset = face == 1 ? vec3(-1.0, ray_axis_1, ray_axis_2) : offset;
    offset = face == 2 ? vec3(ray_axis_1, 1.0, ray_axis_2) : offset;
    offset = face == 3 ? vec3(ray_axis_1, -1.0, ray_axis_2) : offset;
    offset = face == 4 ? vec3(ray_axis_1, ray_axis_2, 1.0) : offset;
    offset = face == 5 ? vec3(ray_axis_1, ray_axis_2, -1.0) : offset;

    // spherically mapping the cube
    offset = normalize(offset);

    vec4 col = intersectRay(sample_pos, offset, cascade_index);
    col.rgb = sample_pos / 96.0;

    imageStore(cascade_data, ivec3(gl_GlobalInvocationID), col);
}