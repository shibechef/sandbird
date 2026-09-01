#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0, rgba32f) uniform restrict image2DArray voxel_data;
layout(set = 1, binding = 0, rgba32f) uniform restrict image2DArray cascade_data;

layout(push_constant, std430) uniform Params {
	int starting_rays;
	int starting_length;
    int voxel_chunk_size;
} params;

ivec3 worldPosToVoxelTextCoords(ivec3 world_pos, int layer, int face) {
    ivec3 text_size = imageSize(voxel_data);
    
    int voxel_index = world_pos.x + world_pos.y * params.voxel_chunk_size + world_pos.z * params.voxel_chunk_size * params.voxel_chunk_size;
    voxel_index *= 6;
    int x = voxel_index % text_size.x;
    int y = int(floor(float(voxel_index) / float(text_size.x)));

    return ivec3(x, y, layer);
}

vec3 rayTextToVoxelCoords(ivec3 text_pos) {
    int cascade_index = int(gl_GlobalInvocationID.z);
    int rays = params.starting_rays << cascade_index;
    float rays_f = float(rays);

    ivec3 radiance_text_size = imageSize(cascade_data);
    int text_index = text_pos.x + text_pos.y * radiance_text_size.x;

    int x = text_index % rays;
    int y = int(float(text_index) / rays_f);
    int z = int(float(text_index) / rays_f / rays_f);
    return vec3(x, y, z);
}

vec4 sampleWorld(vec3 world_pos) {
    ivec3 sample_pos = worldPosToVoxelTextCoords(ivec3(world_pos), 0, 0);
    vec4 col = imageLoad(voxel_data, sample_pos);
    return col;
}

vec4 intersectRay(vec3 ray_start, vec3 ray_end, int cascade_index) {
    int current_rays = params.starting_rays << cascade_index;
    ivec3 dir = sign(ivec3(ray_end - ray_start));

    vec3 radiance = vec3(0.0);
    float transmittance = 1.0;

    for (int i = 0; i < params.starting_length; i++){
        vec4 world_data = sampleWorld(ray_start + dir * i);
        radiance += world_data.rgb;
        transmittance -= world_data.a;
    }

    if (radiance != vec3(0.0, 0.0, 0.0)) {
        radiance = normalize(radiance);
    }

    return vec4(radiance, transmittance);
}

// the emissive materials should have an alpha higher than 1.0, so write and read that for emission amounts
// for the cascades, the first one has many samples of nearby voxels, tight angle, little distance
// refer to castInterval https://www.shadertoy.com/view/wfyyDz
// this will get the ray having a color and a value of how much has been transmitted to the end
// this transmitted to end thing is important for merging, as further rays will use this to decide how much of that goes through the previous ray

// on every voxel in the dimensions sample the basic 6 ways to get the radiance and transmittance of that voxel and save to cascade_data
// with that cascade_data, put it in the material shader and have voxels mix between the nearby 3x3 just as a visual test

void main() {
    ivec3 voxel_text_size = imageSize(voxel_data);
    ivec3 radiance_text_size = imageSize(cascade_data);

    int cascade_index = int(gl_GlobalInvocationID.z);
    int current_rays = params.starting_rays << cascade_index;

    int text_index = int(gl_GlobalInvocationID.x) + int(gl_GlobalInvocationID.y) * radiance_text_size.x;
    int ray_index = text_index % current_rays;

    vec3 sample_pos = rayTextToVoxelCoords(ivec3(gl_GlobalInvocationID));
    vec3 end_pos = vec3(0.0);

    if (ray_index == 0){
        end_pos = vec3(1.0, 0.0, 0.0);
    }
    if (ray_index == 1){
        end_pos = vec3(-1.0, 0.0, 0.0);
    }
    if (ray_index == 2){
        end_pos = vec3(0.0, 1.0, 0.0);
    }
    if (ray_index == 3){
        end_pos = vec3(0.0, -1.0, 0.0);
    }
    if (ray_index == 4){
        end_pos = vec3(0.0, 0.0, 1.0);
    }
    if (ray_index == 5){
        end_pos = vec3(0.0, 0.0, -1.0);
    }
    vec4 col = intersectRay(sample_pos, vec3(0.0), 0);

    imageStore(cascade_data, ivec3(gl_GlobalInvocationID), col);
}