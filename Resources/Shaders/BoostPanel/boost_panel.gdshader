// Boost panel with texture-based arrows, gradient, patterns, and sparkles.
// Works under rotation and non-uniform scale of the node.
// Apply on a plane mesh whose size in meters is given by mesh_size.

shader_type spatial;

// Mesh //
uniform vec2 mesh_size = vec2(1.0, 1.0); // Size of the plane mesh in meters (x = width, y = length)

// Arrows //
uniform sampler2D arrow_texture; // Texture used for arrows
uniform vec3 arrow_color: source_color; // Colour used for arrows
uniform float arrow_scroll_speed = 1.0; // Speed at which arrows scroll
uniform vec2 arrow_uv_scale = vec2(5.0, 1.0); // UV scale of the arrows (x = horizontal arrows, y = vertical arrows)
uniform float main_arrow_depth = 0.03; // Parallax depth of main arrow
uniform float ghost_arrow_depth = 0.06; // Parallax depth of ghost arrow

// Patterns //
uniform sampler2D pattern_texture; // Texture used for layered patterning
uniform vec3 top_color: source_color; // Colour for the top of the gradient
uniform vec3 bottom_color: source_color; // Colour for the bottom of the gradient
uniform vec2 pattern_uv_scale = vec2(2.5, 0.5); // UV scale of the pattern
uniform float brightness = 5.0; // Brightness of the panel

// Sparkles //
uniform sampler2D sparkle_texture: hint_default_black, filter_linear_mipmap, repeat_disable; // Greyscale sparkle sprite, centred, mipmaps enabled
uniform vec3 sparkle_color: source_color = vec3(1.0, 0.97, 0.8); // Colour the sparkle is tinted with
uniform float sparkle_cell: hint_range(0.1, 2.0) = 0.4; // Size of a sparkle grid cell in meters (about the spacing between sparkles)
uniform float sparkle_density: hint_range(0.0, 1.0) = 0.35; // Fraction of cells that hold a sparkle
uniform float sparkle_size: hint_range(0.1, 0.5) = 0.3; // Largest sparkle half-size, as a fraction of a cell
uniform float sparkle_rate: hint_range(0.0, 3.0) = 0.8; // Twinkles per second
uniform float sparkle_scroll_speed = 0.4; // Meters per second the sparkles drift; positive = same direction as the arrows
uniform float sparkle_depth = 0.05; // Parallax depth of the sparkles
uniform float sparkle_brightness = 3.0; // Emission strength of the sparkles

// Varyings //
varying mat3 TBN; // Tangent, Binormal, Normal matrix to transform vectors into tangent space
varying flat vec2 uv_scalar; // UV scalars in a vector
varying flat vec2 pad_scale; // Node scale along its local X and Z axes

// Offsets a layer's UV by the view direction (in tangent space) to fake depth.
vec2 parallax_uv(vec2 uv, vec3 view_dir, float depth_offset) {
	vec2 vec_p = view_dir.xy / view_dir.z * depth_offset;
	return uv + vec_p;
}

// Hash function for randomly generating a coordinate
// Returns two uncorrelated pseudo-random numbers in [0, 1) from a 2D cell id
vec2 hash22(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.xx + p3.yz) * p3.zy); // Only return the fractional part to keep it between 0 and 1
}

// Sparkle intensity in [0, 1] at a position `pos` in meters.
// dpos_dx and dpos_dy are the screen-space derivatives of `pos` (taken in fragment()).
// The surface is divided into square cells of sparkle_cell meters. Each cell may hold one
// star sprite at a random spot, which grows and fades on its own random schedule.
float sparkles(vec2 pos, vec2 dpos_dx, vec2 dpos_dy) {
	vec2 q = pos / sparkle_cell;
	vec2 id = floor(q);
	vec2 cell_uv = fract(q); // Position inside the cell, in [0, 1)

	vec2 r_pos = hash22(id); // Where the sprite sits in the cell
	vec2 r_a = hash22(id + vec2(31.7, 17.3)); // x: time offset, y: size
	vec2 r_b = hash22(id + vec2(71.1, 5.9)); // x: does this cell have a sparkle, y: speed

	float present = step(r_b.x, sparkle_density);

	// Keep the whole sprite inside its own cell so it is never cut off at a cell border
	float half_size = sparkle_size * mix(0.5, 1.0, r_a.y);
	vec2 center = mix(vec2(half_size), vec2(1.0 - half_size), r_pos);

	// Life cycle: 0 -> 1 -> 0 over one twinkle (sin^2 gives a smooth grow-and-fade)
	float life = fract(TIME * sparkle_rate * mix(0.7, 1.3, r_b.y) + r_a.x);
	float s = sin(PI * life);
	s *= s;

	// Where this pixel falls on the sprite. The sprite is a square of side 2 * re (in cell units)
	// centred on `center`, and it grows with s.
	float re = max(half_size * s, 1e-4);
	vec2 st = (cell_uv - center) / (2.0 * re) + 0.5;

	// Outside the sprite's square there is nothing to draw
	vec2 in_box = step(vec2(0.0), st) * step(st, vec2(1.0));

	// Texture gradients come from the continuous coordinate q. cell_uv jumps at cell borders,
	// which would give a wrong mip level (and seams) if the hardware derived them from st.
	vec2 dst_dx = dpos_dx / (sparkle_cell * 2.0 * re);
	vec2 dst_dy = dpos_dy / (sparkle_cell * 2.0 * re);
	float star = textureGrad(sparkle_texture, st, dst_dx, dst_dy).r * in_box.x * in_box.y;

	return star * s * present;
}

// Called for every vertex the material is visible on.
void vertex() {
	// Node scale along its local X and Z axes: the lengths of the matrix's columns (the node's axis vectors in world space)
	float scale_x = length(MODEL_MATRIX[0].xyz);
	float scale_z = length(MODEL_MATRIX[2].xyz);
	uv_scalar = vec2(scale_x, 1.0);
	pad_scale = vec2(scale_x, scale_z);

	// Tangent frame in view space. Normalizing makes the frame orthonormal
	mat3 mv = mat3(MODELVIEW_MATRIX);
	TBN = mat3(
		-normalize(mv * TANGENT),
		normalize(mv * BINORMAL),
		normalize(MODELVIEW_NORMAL_MATRIX * NORMAL)
	);
}

// Called for every pixel the material is visible on.
void fragment() {
	// Set uv (u and v both run backwards)
	vec2 flipped_uv = vec2(1.0) - UV;
	vec2 uv = uv_scalar * flipped_uv;
	
	// Get the direction the panel is being viewed from for 3D depth (tangent space, unit length)
	vec3 view_direction = normalize(normalize(-VERTEX) * TBN);
	
	// The layers below shift their UVs (which are not scaled along the pad's length) by the parallax offset.
	// One unit of UV.y covers pad_scale.y times more distance when the pad is stretched along Z,
	// so divide that axis by pad_scale.y to keep the shift the same size in the world.
	vec3 layer_view = vec3(view_direction.xy * vec2(1.0, 1.0 / pad_scale.y), view_direction.z);
	
	// First pattern layer
	vec2 uv1 = parallax_uv(0.5*(pattern_uv_scale * uv + 0.2 * TIME), layer_view, 0.025);
	float p1 = texture(pattern_texture, uv1).r;
	
	// Second pattern layer
	vec2 uv2 = parallax_uv(pattern_uv_scale * uv + 0.05 * TIME, layer_view, 0.05);
	float p2 = texture(pattern_texture, uv2).r;
	
	// Third pattern layer
	vec2 uv3 = parallax_uv(pattern_uv_scale * 0.5 * uv - 0.02 * TIME, layer_view, 0.075);
	float p3 = texture(pattern_texture, uv3).r;
	
	// Mix all patterns with gradient colours to get the base colour of the pixel
	float pat = mix(mix(p1,p2,0.5), p3, 0.5);
	vec3 base_colour = mix(top_color, bottom_color, uv.y) * pat;
	
	// Set arrow_uv to offset over time & make parralax for main arrow and ghost arrow
	vec2 arrow_uv = uv * arrow_uv_scale + vec2(0.0, arrow_scroll_speed * TIME);
	arrow_uv = parallax_uv(arrow_uv, layer_view, main_arrow_depth);
	vec2 ghost_uv = parallax_uv(arrow_uv, layer_view, -ghost_arrow_depth);
	
	// Get main and ghost arrow masks
	float a_main  = texture(arrow_texture, arrow_uv).r;
	float a_ghost = texture(arrow_texture, ghost_uv).r;
	
	// Blend base_colour with arrow_colour to get final colour value, with the ghost arrow capping at 30% contribution
	vec3 colour = mix(base_colour, arrow_color, min((a_main + 0.1 * a_ghost), 0.3));
	
	// Add sparkles. Position on the pad in meters: flipped UV times the mesh size times the node's scale.
	// The parallax offset is applied directly in meters, so it does not depend on the node's scale.
	vec2 pad_m = flipped_uv * mesh_size * pad_scale;
	vec2 parallax_m = view_direction.xy / view_direction.z * sparkle_depth;
	vec2 sparkle_pos = pad_m + parallax_m + vec2(0.0, sparkle_scroll_speed * TIME);
	float sparkle = clamp(sparkles(sparkle_pos, dFdx(sparkle_pos), dFdy(sparkle_pos)), 0.0, 1.0);
	
	ALBEDO = mix(colour, sparkle_color, sparkle); // Set colour / albedo
	// Sparkles are added separately so they are not multiplied by the panel's brightness
	EMISSION = colour * brightness + sparkle_color * sparkle * sparkle_brightness; // Set emission
}
