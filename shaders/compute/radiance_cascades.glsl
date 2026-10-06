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

// all indices with sample coordinates identical to 614160, and the difference from the first appearance of that coordinate to that of the index chain
// cascade: 0, rays per probe: 6, total probes: 884736, shrinkage: (1.0, 1.0, 1.0)
// 0
// [614160, 614161, 614162, 614163, 614164, 614165]
// cascade: 1, rays per probe: 24, total probes: 221184, shrinkage: (2.0, 1.0, 2.0) 
// 0, 55296
// [558864, 558865, 558866, 558867, 558868, 558869, 558870, 558871, 558872, 558873, 558874, 558875, 614160, 614161, 614162, 614163, 614164, 614165, 614166, 614167, 614168, 614169, 614170, 614171]
// cascade: 2, rays per probe: 96, total probes: 55296, shrinkage: (2.0, 4.0, 2.0)
// 0, 576, 1152, 1728, 55296, 55872, 56448, 57024
// [557712, 557713, 557714, 557715, 557716, 557717, 557718, 557719, 557720, 557721, 557722, 557723, 558288, 558289, 558290, 558291, 558292, 558293, 558294, 558295, 558296, 558297, 558298, 558299, 
// 558864, 558865, 558866, 558867, 558868, 558869, 558870, 558871, 558872, 558873, 558874, 558875, 559440, 559441, 559442, 559443, 559444, 559445, 559446, 559447, 559448, 559449, 559450, 559451, 613008, 
// 613009, 613010, 613011, 613012, 613013, 613014, 613015, 613016, 613017, 613018, 613019, 613584, 613585, 613586, 613587, 613588, 613589, 613590, 613591, 613592, 613593, 613594, 613595, 614160, 614161, 614162, 
// 614163, 614164, 614165, 614166, 614167, 614168, 614169, 614170, 614171, 614736, 614737, 614738, 614739, 614740, 614741, 614742, 614743, 614744, 614745, 614746, 614747]
// cascade: 3, rays per probe: 384, total probes: 13824, shrinkage: (4.0, 4.0, 4.0)
// (24 long) 0, 576, 1152, 1728, 55296, 55872, 56448, 57024, 110592, 111168, 111744, 112320, 165888, 166464, 167040, 167616
// [447120, 447121, 447122, 447123, 447124, 447125, 447126, 447127, 447128, 447129, 447130, 447131, 447132, 447133, 447134, 447135, 447136, 447137, 447138, 447139, 447140, 447141, 447142, 447143, 447696, 447697, 447698, 447699, 447700, 447701, 447702, 447703, 447704, 447705, 447706, 447707, 447708, 447709, 447710, 447711, 447712, 447713, 447714, 447715, 447716, 447717, 447718, 447719, 448272, 448273, 448274, 448275, 448276, 448277, 448278, 448279, 448280, 448281, 448282, 448283, 448284, 448285, 448286, 448287, 448288, 448289, 448290, 448291, 448292, 448293, 448294, 448295, 448848, 448849, 448850, 448851, 448852, 448853, 448854, 448855, 448856, 448857, 448858, 448859, 448860, 448861, 448862, 448863, 448864, 448865, 448866, 448867, 448868, 448869, 448870, 448871, 
// 502416, 502417, 502418, 502419, 502420, 502421, 502422, 502423, 502424, 502425, 502426, 502427, 502428, 502429, 502430, 502431, 502432, 502433, 502434, 502435, 502436, 502437, 502438, 502439, 502992, 502993, 502994, 502995, 502996, 502997, 502998, 502999, 503000, 503001, 503002, 503003, 503004, 503005, 503006, 503007, 503008, 503009, 503010, 503011, 503012, 503013, 503014, 503015, 503568, 503569, 503570, 503571, 503572, 503573, 503574, 503575, 503576, 503577, 503578, 503579, 503580, 503581, 503582, 503583, 503584, 503585, 503586, 503587, 503588, 503589, 503590, 503591, 504144, 504145, 504146, 504147, 504148, 504149, 504150, 504151, 504152, 504153, 504154, 504155, 504156, 504157, 504158, 504159, 504160, 504161, 504162, 504163, 504164, 504165, 504166, 504167, 
// 557712, 557713, 557714, 557715, 557716, 557717, 557718, 557719, 557720, 557721, 557722, 557723, 557724, 557725, 557726, 557727, 557728, 557729, 557730, 557731, 557732, 557733, 557734, 557735, 558288, 558289, 558290, 558291, 558292, 558293, 558294, 558295, 558296, 558297, 558298, 558299, 558300, 558301, 558302, 558303, 558304, 558305, 558306, 558307, 558308, 558309, 558310, 558311, 558864, 558865, 558866, 558867, 558868, 558869, 558870, 558871, 558872, 558873, 558874, 558875, 558876, 558877, 558878, 558879, 558880, 558881, 558882, 558883, 558884, 558885, 558886, 558887, 559440, 559441, 559442, 559443, 559444, 559445, 559446, 559447, 559448, 559449, 559450, 559451, 559452, 559453, 559454, 559455, 559456, 559457, 559458, 559459, 559460, 559461, 559462, 559463, 613008, 613009, 
// 613010, 613011, 613012, 613013, 613014, 613015, 613016, 613017, 613018, 613019, 613020, 613021, 613022, 613023, 613024, 613025, 613026, 613027, 613028, 613029, 613030, 613031, 613584, 613585, 613586, 613587, 613588, 613589, 613590, 613591, 613592, 613593, 613594, 613595, 613596, 613597, 613598, 613599, 613600, 613601, 613602, 613603, 613604, 613605, 613606, 613607, 614160, 614161, 614162, 614163, 614164, 614165, 614166, 614167, 614168, 614169, 614170, 614171, 614172, 614173, 614174, 614175, 614176, 614177, 614178, 614179, 614180, 614181, 614182, 614183, 614736, 614737, 614738, 614739, 614740, 614741, 614742, 614743, 614744, 614745, 614746, 614747, 614748, 614749, 614750, 614751, 614752, 614753, 614754, 614755, 614756, 614757, 614758, 614759]

vec3 rayTextToVoxelCoords(ivec3 text_pos) {
    int cascade_index = int(gl_GlobalInvocationID.z);
    int rays = params.starting_rays << (cascade_index * 2);

    ivec3 radiance_text_size = imageSize(cascade_data);
    int voxel_index = text_pos.x + text_pos.y * radiance_text_size.x;
    voxel_index = int(floor(float(voxel_index) / 6.0));
    //voxel_index = int(float(voxel_index / 4.0)) * 4;

    //int probes_per_axis = params.vox_chunk_size << 2 * int(floor(float(cascade_index) / 3.0));

    // as the 3 axes cannot be uniformly shrunk, it goes 96x96x96, 48x96x48, 48x24x48, 24x24x24 etc
    vec3 probe_shrinkage = vec3(
        cascade_index % 3 == 0 ? 1.0 : 2.0,
        cascade_index % 3 == 2 ? 4.0 : 1.0,
        cascade_index % 3 == 0 ? 1.0 : 2.0
    );    
    
    vec3 center = vec3(0.5 / float(params.vox_chunk_size));
    float x = float(voxel_index % params.vox_chunk_size);
    float y = float(voxel_index % (params.vox_chunk_size * params.vox_chunk_size)) / float(params.vox_chunk_size);
    float z = float(voxel_index % (params.vox_chunk_size * params.vox_chunk_size * params.vox_chunk_size)) / float(params.vox_chunk_size * params.vox_chunk_size);

    return vec3(vec3(x, y, z) + center) / probe_shrinkage;
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

    vec4 colero = imageLoad(cascade_data, ivec3(gl_GlobalInvocationID)) + vec4(.2) * float(params.cascade_index);

    imageStore(cascade_data, ivec3(gl_GlobalInvocationID), col);
}