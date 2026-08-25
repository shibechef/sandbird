#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// pass in just the textures
// the emissive materials should have an alpha higher than 1.0, so write and read that for emission amounts
// for the cascades, the first one has many samples of nearby voxels, tight angle, little distance
// refer to castInterval https://www.shadertoy.com/view/wfyyDz
// this will get the ray having a color and a value of how much has been transmitted to the end
// this transmitted to end thing is important for merging, as further rays will use this to decide how much of that goes through the previous ray

// on every voxel in the dimensions sample the basic 6 ways to get the radiance and transmittance of that voxel and save to cascade_data
// with that cascade_data, put it in the material shader and have voxels mix between the nearby 3x3 just as a visual test

//layout(set = 1, binding = 0, std430) restrict buffer Chunks {
//    vec3 position[]; 
//}
//chunks;

layout(set = 0, binding = 0, rgba32f) uniform image2DArray voxel_data;
layout(set = 1, binding = 0, rgba32f) uniform image2DArray cascade_data;

// this need a direction too, might just put that in intersect_ray
vec4 sampleWorld(vec3 position) {
    //int index = position.x + position.y * dimensions.x + position.z * dimensions.x * dimensions.y;
    //vec4 col = voxels.color[gl_GlobalInvocationID.x];
    return vec4(1.0);
}

vec4 intersectRay(vec3 ray_start, vec3 ray_end, int cascade_index) {
    vec3 dir = ray_end - ray_start;
    int steps = 4 << cascade_index;

    vec3 radiance;
    float transmittance;

    for (int i = 0; i < steps; i++){
        continue;
    }

    return vec4(1.0);
}

void main() {
    //vec4 col = voxels.color[gl_GlobalInvocationID.x + gl_GlobalInvocationID.y * gl_NumWorkGroups.x * 48];
    //col = (col + vec4(0.8, 0.55, 0.9, 1.0)) / 2.0;
    vec4 col = vec4(0.5, 1.0, 0.0, 1.0);
    //voxels.color[gl_GlobalInvocationID.x] = vec4(.2, .2, .2, .5);
    //imageStore(voxel_data, ivec3(gl_GlobalInvocationID.xy, 0), col);
    imageStore(cascade_data, ivec3(gl_GlobalInvocationID.xy, 0), col);
}