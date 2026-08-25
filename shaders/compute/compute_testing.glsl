#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0, rgba32f) uniform restrict image2DArray voxel_data;
layout(set = 1, binding = 0, rgba32f) uniform restrict image2DArray cascade_data;

void main() {
    int x = int(gl_GlobalInvocationID.x) % 2304;
    int z = int(floor(float(gl_GlobalInvocationID.x) / 2304.0));
    imageStore(voxel_data, ivec3(x, gl_GlobalInvocationID.y, z), vec4(0.2, 0.9, 0.1, 0.4));
    imageStore(cascade_data, ivec3(x, gl_GlobalInvocationID.y, z), vec4(0.5, 0.1, 0.1, 0.5));
}