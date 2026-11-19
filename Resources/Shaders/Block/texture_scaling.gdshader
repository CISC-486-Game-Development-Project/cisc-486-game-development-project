shader_type spatial;

// Texture Parameters
uniform sampler2D albedo_texture: source_color, filter_linear_mipmap, repeat_enable; // Texture to repeat & scale
uniform float tiles_per_meter = 1.0; // How many times the texture tiles per meter
uniform float blend_sharpness = 4.0; // The blend sharpness of the texture

// Varyings
varying vec3 scaled_position;
varying vec3 object_normal;

void vertex() {
	vec3 scale = vec3( // Get lengths equal to scale for each axis
		length(MODEL_MATRIX[0].xyz),
		length(MODEL_MATRIX[1].xyz),
		length(MODEL_MATRIX[2].xyz)
	);
	scaled_position = VERTEX * scale; // Vertex position * scale = object space position for vertex
	object_normal = NORMAL; // Get object space normal
}

void fragment() {
	// Get blend weights (blending used so this shader works on more than just box meshes)
	vec3 weights = pow(abs(normalize(object_normal)), vec3(blend_sharpness));
	weights /= (weights.x + weights.y + weights.z);

	vec3 position = scaled_position * tiles_per_meter; // Convert metres to tile units
	vec3 colour = // Get colour from texture based on position and weights
		texture(albedo_texture, position.zy).rgb * weights.x +
		texture(albedo_texture, position.xz).rgb * weights.y +
		texture(albedo_texture, position.xy).rgb * weights.z;

	ALBEDO = colour; // Set albedo to colour
}