shader_type canvas_item;

// Scrolling Gradient //
uniform sampler2D gradient: source_color, filter_linear;             // Gradient to sample (assumes 1D)
uniform float gradient_opacity: hint_range(0.0, 1.0) = 0.75;         // Opacity of the gradient
uniform float gradient_angle : hint_range(0.0, 360.0, 1.0) = 90.0;   // Degrees clockwise from "toward the horizon"
uniform float gradient_speed = 0.25;                                 // Cycles of t per second
uniform float gradient_tiling = 1.0;                                 // Cycles per ground unit
uniform bool gradient_fade = true;                                   // If gradient fades near horizon
uniform bool mirror_loop = true;                                     // Reverse the gradient to form a clean loop

// Background Texture //
uniform sampler2D bg_texture: source_color, filter_linear_mipmap_anisotropic, repeat_enable; // Texture to sample
uniform float bg_opacity: hint_range(0.0, 1.0) = 0.35;          // Opacity of the bg texture
uniform float bg_speed = 0.25;                                  // Texture tile repeats per second
uniform float bg_angle : hint_range(0.0, 360.0, 1.0) = 90.0;    // Degrees clockwise from "toward the horizon"
uniform vec2 bg_tiling = vec2(4.0, 4.0);                        // Scale of the texture's tiling
uniform bool bg_fade = true;                                    // If texture fades near horizon

// Perspective (shared by both layers)
uniform float horizon_depth : hint_range(0.35, 4.0) = 2.0;       // Depth of the horizon. Far/near distance ratio = 1 + depth
uniform float horizon_angle : hint_range(0.0, 360.0, 1.0) = 0.0; // Angle of the horizon in degrees
uniform float horizon_fade : hint_range(0.0, 1.0) = 0.4;         // Distance from the horizon to fade

// Remaps UV so that the horizon's edge always lies at UV'.y = 0.
// Pure rotations, the texture is never mirrored.
vec2 orient(vec2 uv) {
	float a = radians(horizon_angle);  // Get horizon_angle from degrees to radians
	vec2 n = vec2(sin(a), -cos(a));    // Screen direction toward the horizon (y points down)
	vec2 r = vec2(cos(a), sin(a));     // "Right" for a viewer facing the horizon
	vec2 c = uv - 0.5;                 // Get UV's center
	return vec2(0.5 + dot(c, r), 0.5 - dot(c, n)); // 
}

// Takes a UV position and returns the ground-plane point seen at that pixel.
vec2 ground_coords(vec2 uv) {
	vec2 p = orient(uv);                 // p = UV' (UV rotated by the horizon_angle)
	float d = 1.0 + horizon_depth * p.y; // Get depth, decoupled from scale
	return vec2(p.x - 0.5, 1.0) / d;     // Return (X, Z) by diving by depth
}

// Helper function that converts a screen angle (clockwise from screen-up) into the floor frame (right, toward viewer).
vec2 angle_to_dir(float deg) {
	float a = radians(deg - horizon_angle); // Subtract horizon_angle so the calculations are independant of it
    return vec2(sin(a), -cos(a));           // Return direction vector
}

// Takes a UV position and returns the texture coordinate used to sample the background.
vec2 bg_coords(vec2 uv) {
	vec2 dir = angle_to_dir(bg_angle);                   // Get direction from angle
	vec2 offset = vec2(-dir.x, dir.y) * bg_speed * TIME; // Offset taken as direction * speed over time
	return ground_coords(uv) * bg_tiling + offset;       // Apply to ground coords
}

// Takes a UV position and returns the position t from 0 to 1 at which to sample the gradient texture.
float gradient_t(vec2 uv) {
	vec2 g = ground_coords(uv);              // Get ground point
	vec2 dir = angle_to_dir(gradient_angle); // Get direction from angle
	
	// Flip Z so the axes read (right, toward viewer), matching bg_direction.
	float t = dot(vec2(g.x, -g.y), dir) * gradient_tiling - TIME * gradient_speed;
	
	// If mirror_loop, map the gradient to a V shape instead of a / shape to play backward then forward
	if (mirror_loop) {
		return 1.0 - abs(fract(t * 0.5) * 2.0 - 1.0);
	}
	return fract(t); // No mirror_loop, play gradient through forward then repeat
}

// Runs once per pixel.
void fragment() {
	vec4 tint = COLOR; // Node's colour * modulate
	
	vec4 bg = texture(bg_texture, bg_coords(UV)); // Sample bg texture at a perpective-projected scrolling coordinate
	bg.a *= bg_opacity; // Scale bg texture alpha
	if (bg_fade) {
		bg.a *= smoothstep(0.0, horizon_fade, orient(UV).y); // Fade near horizon
	}
	
	vec4 grad = texture(gradient, vec2(gradient_t(UV), 0.5)); // Sample 1D gradient  at x = t (y is arbitrary on a 1D gradient)
	grad.a *= gradient_opacity; // Scale gradient alpha
	if (gradient_fade) {
		grad.a *= smoothstep(0.0, horizon_fade, orient(UV).y); // Fade near horizon
	}
	
	// Compute final rgb and alpha channels with gradient layered on top of the texture
	float out_a = grad.a + bg.a * (1.0 - grad.a); // Combine alpha channels to get final alpha value
	vec3 out_rgb = (grad.rgb * grad.a + bg.rgb * bg.a * (1.0 - grad.a)) / max(out_a, 0.0001); // Combine rgb channels with alpha to get final rgb value (max to avoid division by 0 when both layers are transparent)
	
	COLOR = vec4(out_rgb, out_a) * tint; // Set colour to the combination of the rgb and alpha channels calculated
}