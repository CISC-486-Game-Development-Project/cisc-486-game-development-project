shader_type spatial;
render_mode cull_disabled;

// Colour
uniform vec4 color_top : source_color = vec4(0.478, 0.973, 0.592, 1.0); // Default colour for top of grass gradient
uniform vec4 color_bottom : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Default colour for bottom of grass gradient

// Static Bend
uniform float blade_bend = 0.5; // Bend of each grass blade

// Wind
uniform vec3 color_variation : source_color = vec3(0.9, 0.9, 0.2);
uniform float patch_scale = 5.0;
uniform sampler2D wind_noise;
uniform vec2 wind_direction = vec2(1.0, 1.0);
uniform float wind_texture_scale = 20.0;
uniform float wind_speed = 0.05;
uniform float still_sway_speed = 0.1;
uniform float still_sway_strength = 0.1;
uniform float gust_strength = 0.1;
uniform float gust_frequency = 0.08;
uniform float flutter_intensity = 1;

// Displacement
const int MAX_DISPLACERS = 16; // The maximum number of displacers that can be active
uniform vec4 displacers[MAX_DISPLACERS]; // xyz = world position, w = radius
uniform int displacer_count = 0; // The number of active displacers, updated by GrassManager
uniform float displacement_strength = 0.6; // The maximum horizontal distance in world units the blade tip is pushed away from a displacer
uniform float displacement_flatten = 0.5; // The maximum vertical distance in mesh units the blade tip is pushed downward
uniform float displacement_vertical_range = 1.0; // The vertical gap, in world units, at which a displacer’s influence has fully faded

// Varyings
varying float v_wind_intensity;
varying float v_patch;
varying float v_height;

varying vec3 world_pos;

void vertex() {
	v_height = UV.y;
	
	world_pos = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	float patch_factor = texture(wind_noise, world_pos.xz / patch_scale).r;
	v_patch = patch_factor;
	
	vec2 global_uv = world_pos.xz / wind_texture_scale;
	vec2 move_uv = global_uv + (normalize(wind_direction) * TIME * wind_speed);
	float noise_val = texture(wind_noise, move_uv).r;
	
	float gust_mask = smoothstep(gust_frequency, 1.0, noise_val);
	
	float idle_sway = sin(TIME * still_sway_speed + world_pos.x + world_pos.z) * still_sway_strength;
	float flutter = sin(TIME * flutter_intensity + world_pos.x) * 0.1;
	float gust_push = (gust_mask * gust_strength) + (gust_mask * flutter);
	
	v_wind_intensity = gust_mask;
	
	vec3 vertex_pos = VERTEX;
	vec3 object_right_vector = vec3(1.0, 0.0, 0.0);
	vec3 object_forward_vector = vec3(0.0, 0.0, 1.0);
	float height_factor = 1.0 - UV.y;
	float bend_strength = pow(height_factor, 2.0);
	
	// Static blade bend
	vertex_pos += object_forward_vector * blade_bend * bend_strength;
	
	// Initialize total_offset
	vec3 total_offset = object_right_vector * (idle_sway + gust_push) * bend_strength;
	
	// Displacement from all displacer entities
	vec3 world_push = vec3(0.0);
	float max_influence = 0.0;
	
	for (int i = 0; i < MAX_DISPLACERS; i++) {
		if (i >= displacer_count) { break; }
		
		vec3 d_pos = displacers[i].xyz;
		float d_radius = max(displacers[i].w, 0.0001); // guards smoothstep against a zero radius
		
		vec2 away = world_pos.xz - d_pos.xz;
		float dist = length(away);
		vec2 away_dir = away / max(dist, 0.0001);
		
		float radial_mask = 1.0 - smoothstep(0.0, d_radius, dist);
		float vertical_mask = 1.0 - smoothstep(0.0, displacement_vertical_range, abs(world_pos.y - d_pos.y));
		float influence = radial_mask * vertical_mask;
		
		world_push += vec3(away_dir.x, 0.0, away_dir.y) * influence;
		max_influence = max(max_influence, influence);
	}
	
	// Overlapping displacers add, so clamp the combined push to the single-entity maximum
	float push_len = length(world_push);
	if (push_len > 1.0) { world_push /= push_len; }
	world_push *= displacement_strength;
	
	// World space -> model space, so rotated/scaled MultiMesh instances move correctly
	vec3 local_push = inverse(mat3(MODEL_MATRIX)) * world_push;
	total_offset += local_push * bend_strength;
	
	// Preserve volume / prevent stretching (includes the displacement push)
	float dist_moved = length(total_offset.xz);
	float y_drop = dist_moved * 0.2 * bend_strength;
	y_drop += max_influence * displacement_flatten * bend_strength; // trample flattening
	
	// Set vertex
	VERTEX = vertex_pos + total_offset;
	VERTEX.y -= y_drop;
}

void fragment() {
	if (!FRONT_FACING) { NORMAL = -NORMAL; }
	
	vec3 gradient = mix(color_top.rgb, color_bottom.rgb, UV.y);
    vec3 wind_highlight = color_top.rgb * 1.5;
    vec3 varied_color = mix(gradient, color_variation, v_patch * 0.3);
    vec3 final_color = mix(varied_color, wind_highlight, v_wind_intensity * 0.4);
    ALBEDO = final_color;

    float bottom_to_top = v_height; // 0 = tip, 1 = base
    AO = bottom_to_top + v_wind_intensity * 0.3;
    AO = clamp(AO, 0.0, 1.0);
    AO_LIGHT_AFFECT = 1.0;

    vec3 world_up_view = normalize(mat3(VIEW_MATRIX) * vec3(0.0, 1.0, 0.0));
    NORMAL = mix(NORMAL, world_up_view, bottom_to_top * 0.5);

    ROUGHNESS = 0.8;
    SPECULAR = 0.2;
    BACKLIGHT = ALBEDO * 0.3;
}