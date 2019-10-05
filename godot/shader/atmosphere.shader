shader_type spatial;
render_mode depth_test_disable, blend_add, unshaded;

// the parameters
uniform float planet_radius = 20.0;			// how big the planet is
uniform float atmo_radius = 30.0; 			// how big the atmosphere is
uniform vec3 beta_ray = vec3(1.0, 2.0, 4.0); 		// rayleigh scattering paramater
uniform vec3 beta_mie = vec3(1.0);			// mie scattering parameter
uniform float beta_e = -1.0;				// scale of the parameters (10^scale)
uniform float g = 0.8;					// mie direction
uniform float height_ray = 1.0;				// the height scale for rayleigh
uniform float height_mie = 0.5;				// height scale for mie
uniform int steps_i = 32;				// primary ray steps, affects quality the most (more is better, but slower)
uniform int steps_l = 4;				// light ray steps, affects the sunset quality
uniform float intensity = 20.0;				// the light intensity

varying vec3 light_direction;
varying vec3 camera_position;

vec2 ray_sphere_intersect(
    vec3 start, // starting position of the ray
    vec3 dir, // the direction of the ray
    float radius // and the sphere radius
) {
    // ray-sphere intersection that assumes
    // the sphere is centered at the origin.
    // No intersection when result.x > result.y
    float a = dot(dir, dir);
    float b = 2.0 * dot(dir, start);
    float c = dot(start, start) - (radius * radius);
    float d = (b*b) - 4.0*a*c;
    if (d < 0.0) return vec2(1e5,-1e5);
    return vec2(
        (-b - sqrt(d))/(2.0*a),
        (-b + sqrt(d))/(2.0*a)
    );
}

/*
Next we'll define the main scattering function.
This traces a ray from start to end and takes a certain amount of samples along this ray, in order to calculate the color.
For every sample, we'll also trace a ray in the direction of the light, 
because the color that reaches the sample also changes due to scattering
*/
vec3 calculate_scattering(
	vec3 start, 			// the start of the ray (the camera position)
    vec3 dir, 				// the direction of the ray (the camera vector)
    float max_dist, 		// the maximum distance the ray can travel (because something is in the way, like an object)
	vec3 light_dir
) {
    // calculate the start and end position of the ray, as a distance along the ray
    vec2 ray_length = ray_sphere_intersect(start, dir, atmo_radius);
    // if the ray did not hit the atmosphere, return a black color
    if (0.0 > ray_length.y || max_dist*1.2 < ray_length.x) return vec3(0.0);
	bool allow_mie = max_dist > ray_length.y;
    // make sure the ray is no longer than allowed
	// also, blend the max dist and a ray dist to avoid issues with max_depth 
    ray_length.y = min(ray_length.y, max_dist);
    ray_length.x = max(ray_length.x, 0.0);
	// multiplier for the parameters
	float power = pow(10.0, beta_e);
    // get the step size of the ray
    float step_size_i = (ray_length.y - ray_length.x) / float(steps_i);
    
    // next, set how far we are along the ray, so we can calculate the position of the sample
    // if the camera is outside the atmosphere, the ray should start at the edge of the atmosphere
    // if it's inside, it should start at the position of the camera
    // the min statement makes sure of that
    float ray_pos_i = ray_length.x;
    
    // these are the values we use to gather all the scattered light
    vec3 total_ray = vec3(0.0); // for rayleigh
    vec3 total_mie = vec3(0.0); // for mi
    
    // initialize the optical depth. This is used to calculate how much air was in the ray
    float opt_ray_i = 0.0; // for rayleigh
    float opt_mie_i = 0.0; // and mie
    
    // Calculate the Rayleigh and Mie phases.
    // This is the color that will be scattered for this ray
    // mu, mumu and gg are used quite a lot in the calculation, so to speed it up, precalculate them
    float mu = dot(dir, light_dir);
    float mumu = mu * mu;
    float gg = g * g;
    float phase_ray = 3.0 / (50.2654824574 /* (16 * pi) */) * (1.0 + mumu);
    float phase_mie = allow_mie ? 3.0 / (25.1327412287 /* (8 * pi) */) * ((1.0 - gg) * (mumu + 1.0)) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg)) : 0.0;
    
    // now we need to sample the 'primary' ray. this ray gathers the light that gets scattered onto it
    for (int i = 0; i < steps_i; i++) {
        
        // calculate where we are along this ray
        vec3 pos_i = start + dir * (ray_pos_i + step_size_i * 0.5);
        
        // and how high we are above the surface
        float height_i = length(pos_i) - planet_radius;
        
        // now calculate the density of the particles (both for rayleigh and mie)
        float density_ray = exp(-height_i / height_ray) * step_size_i;
        float density_mie = exp(-height_i / height_mie) * step_size_i;
        
        // Add these densities to the optical depth, so that we know how many particles are on this ray.
        opt_ray_i += density_ray;
        opt_mie_i += density_mie;

        // Calculate the step size of the light ray.
        float step_size_l = ray_sphere_intersect(pos_i, light_dir, atmo_radius).y / float(steps_l);

        // and the position along this ray
        // this time we are sure the ray is in the atmosphere, so set it to 0
        float ray_pos_l = 0.0;

        // and the optical depth of this ray
        float opt_ray_l = 0.0;
        float opt_mie_l = 0.0;
        
        // now sample the light ray
        // this is similar to what we did before
        for (int l = 0; l < steps_l; l++) {

            // calculate where we are along this ray
            vec3 pos_l = pos_i + light_dir * (ray_pos_l + step_size_l * 0.5);

            // the heigth of the position
            float height_l = length(pos_l) - planet_radius;

            // calculate the particle density, and add it
            opt_ray_l += exp(-height_l / height_ray) * step_size_l;
            opt_mie_l += exp(-height_l / height_mie) * step_size_l;

            // and increment where we are along the light ray.
            ray_pos_l += step_size_l;
            
        }
        
        // Now we need to calculate the attenuation
        // this is essentially how much light reaches the current sample point due to scattering
        vec3 attn = exp(-((beta_mie * power * (opt_mie_i + opt_mie_l)) + (beta_ray * power * (opt_ray_i + opt_ray_l))));

        // accumulate the scattered light (how much will be scattered towards the camera)
        total_ray += density_ray * attn;
        total_mie += density_mie * attn;

        // and increment the position on this ray
        ray_pos_i += step_size_i;
    	
    }
    
	// calculate and return the final color
    return (phase_ray * power * beta_ray * total_ray + phase_mie * power * beta_mie * total_mie);
}

void vertex() {
	// I don't know why this works
	camera_position = MODELVIEW_MATRIX[3].xyz;
	light_direction = -normalize(MODELVIEW_MATRIX[2].xyz);
}

// done in fragment, because light misses some matrices that are needed
// it would also be inefficient to do this multiple times
void fragment() {
	// get the scene depth (what is the maximum ray length)
	float depth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
    vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec3 pixel_position = upos.xyz / upos.w;
	float max_distance = length(pixel_position);
	// get the camera vector (the ray direction)
	vec3 camera_vector = VIEW;
	// eliminate some depth buffer issues
	//highp float planet_dist = ray_sphere_intersect(camera_position, camera_vector, planet_radius).x;
	//max_distance = planet_dist > max_distance && length(camera_position) > max_depth_buffer_dist ? planet_dist : max_distance;
	// calculate the atmosphere
	ALBEDO = calculate_scattering(
		camera_position, 
		camera_vector, max_distance, 
		light_direction) * intensity;
	// exposure
	ALBEDO = 1.0 - exp(-1.0 * ALBEDO);
}
