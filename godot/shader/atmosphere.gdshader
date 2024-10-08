shader_type spatial;
render_mode blend_premul_alpha, depth_test_disabled, unshaded;

// depth texture, needed for proper blending
uniform sampler2D depth_texture: hint_depth_texture, filter_linear_mipmap;

// Parameters
uniform vec3 light_intensity = vec3(20.0); // how bright the light is, affects the brightness of the atmosphere
uniform float planet_radius = 26.0; // the radius of the planet
uniform float atmo_radius = 32.0; // the radius of the atmosphere
uniform vec3 beta_ray =vec3(1.0, 2.0, 3.0); // the amount rayleigh scattering scatters the colors (for earth: causes the blue atmosphere)
uniform vec3 beta_mie = vec3(1.0); // the amount mie scattering scatters colors
uniform vec3 beta_ambient = vec3(0.0); // the amount of scattering that always occurs, can help make the back side of the atmosphere a bit brighter
uniform float beta_e = 0.0; // exponent, helps setting really small values of beta_ray, mie and ambient, as in beta_x * pow(10.0, beta_e)
uniform float g = 0.8; // the direction mie scatters the light in (like a cone). closer to -1 means more towards a single direction
uniform float height_ray = 0.5; // how high do you have to go before there is no rayleigh scattering?
uniform float height_mie = 0.25; // the same, but for mie
uniform float density_multiplier = 1.0; // how much extra the atmosphere blocks light
uniform int steps_i = 32; // the amount of steps along the 'primary' ray, more looks better but slower
uniform int steps_l = 4; // the amount of steps along the light ray, more looks better but slower

varying vec3 cam_position;
varying vec3 light_direction;

vec4 calculate_scattering(
	vec3 start, 			// the start of the ray (the camera position)
	vec3 dir, 				// the direction of the ray (the camera vector)
	float max_dist, 		// the maximum distance the ray can travel (because something is in the way, like an object)
	vec3 light_dir, 		// the direction of the light
) {
	// calculate the start and end position of the ray, as a distance along the ray
	// we do this with a ray sphere intersect
	float a = dot(dir, dir);
	float b = 2.0 * dot(dir, start);
	float c = dot(start, start) - (atmo_radius * atmo_radius);
	float d = (b * b) - 4.0 * a * c;

	// stop early if there is no intersect
	if (d < 0.0) return vec4(0.0);

	// calculate the ray length
	vec2 ray_length = vec2(
		max((-b - sqrt(d)) / (2.0 * a), 0.0),
		min((-b + sqrt(d)) / (2.0 * a), max_dist)
	);

	// if the ray did not hit the atmosphere, return a black color
	if (ray_length.x > ray_length.y) return vec4(0.0);
	// prevent the mie glow from appearing if there's an object in front of the camera
	bool allow_mie = max_dist > ray_length.y;
	// make sure the ray is no longer than allowed
	ray_length.y = min(ray_length.y, max_dist);
	ray_length.x = max(ray_length.x, 0.0);
	// get the step size of the ray
	float step_size_i = (ray_length.y - ray_length.x) / float(steps_i);

	// helper for beta_e and mie
	float e = pow(10.0, beta_e);

	// next, set how far we are along the ray, so we can calculate the position of the sample
	// if the camera is outside the atmosphere, the ray should start at the edge of the atmosphere
	// if it's inside, it should start at the position of the camera
	// the min statement makes sure of that
	float ray_pos_i = ray_length.x;

	// these are the values we use to gather all the scattered light
	vec3 total_ray = vec3(0.0); // for rayleigh
	vec3 total_mie = vec3(0.0); // for mie

	// initialize the optical depth. This is used to calculate how much air was in the ray
	vec2 opt_i = vec2(0.0);

	// also init the scale height, avoids some vec2's later on
	vec2 scale_height = vec2(height_ray, height_mie);

	// Calculate the Rayleigh and Mie phases.
	// This is the color that will be scattered for this ray
	// mu, mumu and gg are used quite a lot in the calculation, so to speed it up, precalculate them
	float mu = dot(dir, light_dir);
	float mumu = mu * mu;
	float gg = g * g;
	float phase_ray = 3.0 / (50.2654824574 /* (16 * pi) */) * (1.0 + mumu);
	float phase_mie = allow_mie ? 3.0 / (25.1327412287 /* (8 * pi) */) * ((1.0 - gg) * (mumu + 1.0)) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg)) : 0.0;

	// now we need to sample the 'primary' ray. this ray gathers the light that gets scattered onto it
	for (int i = 0; i < steps_i; ++i) {

		// calculate where we are along this ray
		vec3 pos_i = start + dir * (ray_pos_i + step_size_i * 0.5);

		// and how high we are above the surface
		float height_i = length(pos_i) - planet_radius;

		// now calculate the density of the particles (both for rayleigh and mie)
		vec2 density = exp(-height_i / scale_height) * step_size_i;

		// Add these densities to the optical depth, so that we know how many particles are on this ray.
		opt_i += density;

		// Calculate the step size of the light ray.
		// again with a ray sphere intersect
		// a, b, c and d are already defined
		a = dot(light_dir, light_dir);
		b = 2.0 * dot(light_dir, pos_i);
		c = dot(pos_i, pos_i) - (atmo_radius * atmo_radius);
		d = (b * b) - 4.0 * a * c;

		// no early stopping, this one should always be inside the atmosphere
		// calculate the ray length
		float step_size_l = (-b + sqrt(d)) / (2.0 * a * float(steps_l));

		// and the position along this ray
		// this time we are sure the ray is in the atmosphere, so set it to 0
		float ray_pos_l = 0.0;

		// and the optical depth of this ray
		vec2 opt_l = vec2(0.0);

		// now sample the light ray
		// this is similar to what we did before
		for (int l = 0; l < steps_l; ++l) {

			// calculate where we are along this ray
			vec3 pos_l = pos_i + light_dir * (ray_pos_l + step_size_l * 0.5);

			// the heigth of the position
			float height_l = length(pos_l) - planet_radius;

			// calculate the particle density, and add it
			opt_l += exp(-height_l / scale_height) * step_size_l;

			// and increment where we are along the light ray.
			ray_pos_l += step_size_l;

		}

		// Now we need to calculate the attenuation
		// this is essentially how much light reaches the current sample point due to scattering
		vec3 attn = exp(-((beta_mie * e * (opt_i.y + opt_l.y)) + (beta_ray * e * (opt_i.x + opt_l.x))));

		// accumulate the scattered light (how much will be scattered towards the camera)
		total_ray += density.x * attn;
		total_mie += density.y * attn;

		// and increment the position on this ray
		ray_pos_i += step_size_i;
	}

	// calculate how much light can pass through the atmosphere
	float opacity = length(exp(-((beta_mie * e * opt_i.y) + (beta_ray * e * opt_i.x)) * density_multiplier));

	// calculate and return the final color
	return vec4((
			phase_ray * beta_ray * e * total_ray // rayleigh color
			+ phase_mie * beta_mie * e * total_mie // mie
			+ opt_i.x * e * beta_ambient // and ambient
	) * light_intensity, 1.0 - opacity); // now make sure the background is rendered correctly
}

void vertex() {
	// grab the camera position and the light direction from the transform matrices
	cam_position = MODELVIEW_MATRIX[3].xyz;
	light_direction = -normalize(MODELVIEW_MATRIX[2].xyz);
}

void fragment() {

	// get the scene depth (what is the maximum ray length)
	// https://docs.godotengine.org/en/stable/tutorials/shaders/advanced_postprocessing.html#depth-texture
	float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
	vec3 ppos = upos.xyz / upos.w;
	float max_distance = length(ppos);

	// calculate the scattering towards the camera
	vec4 atm = calculate_scattering(cam_position, VIEW, max_distance, light_direction);

	// 4.3 got alpha blending!
	ALBEDO = atm.xyz;
	ALPHA = atm.w;
}
