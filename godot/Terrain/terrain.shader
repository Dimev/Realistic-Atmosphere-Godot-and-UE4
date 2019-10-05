shader_type spatial;

uniform float terrain_scale = 0.8;

varying float height;

// shamelessly stolen from https://www.shadertoy.com/view/XdXBRH
vec2 hash(vec2 x) {
    vec2 k = vec2( 0.3183099, 0.3678794 );
    x = x*k + k.yx;
    return -1.0 + 2.0*fract( 16.0 * k*fract( x.x*x.y*(x.x+x.y)) );
}


// return gradient noise (in x) and its derivatives (in yz)
vec3 noise(vec2 p) {
    vec2 i = floor( p );
    vec2 f = fract( p );

    // quintic interpolation
    vec2 u = f*f*f*(f*(f*6.0-15.0)+10.0);
    vec2 du = 30.0*f*f*(f*(f-2.0)+1.0);    
    
    vec2 ga = hash( i + vec2(0.0,0.0) );
    vec2 gb = hash( i + vec2(1.0,0.0) );
    vec2 gc = hash( i + vec2(0.0,1.0) );
    vec2 gd = hash( i + vec2(1.0,1.0) );
    
    float va = dot( ga, f - vec2(0.0,0.0) );
    float vb = dot( gb, f - vec2(1.0,0.0) );
    float vc = dot( gc, f - vec2(0.0,1.0) );
    float vd = dot( gd, f - vec2(1.0,1.0) );

    return vec3( va + u.x*(vb-va) + u.y*(vc-va) + u.x*u.y*(va-vb-vc+vd),   // value
                 ga + u.x*(gb-ga) + u.y*(gc-ga) + u.x*u.y*(ga-gb-gc+gd) +  // derivatives
                 du * (u.yx*(va-vb-vc+vd) + vec2(vb,vc) - va));
}

// time for more shameless stealing (no dignity): https://www.shadertoy.com/view/MdX3Rr
float terrain(vec2 x) {
	vec2  p = x*0.3;
    float a = 0.0;
    float b = 1.0;
	vec2  d = vec2(0.0);
    for( int i=0; i<6; i++ )
    {
        vec3 n = noise(p);
        d += n.yz;
        a += b*n.x/(1.0+dot(d,d));
		b *= 0.5;
        p = mat2(vec2(0.8,-0.6), vec2(0.6, 0.8))*p*2.0;
    }

	return a;
}

void vertex() {
	vec3 blending = abs(NORMAL);
	blending = normalize(max(blending, vec3(0.00001))); // Force weights to sum to 1.0
	float b = blending.x + blending.y + blending.z;
	vec3 blend = blending / vec3(b, b, b);
	//height = terrain(UV*terrain_scale); 
	VERTEX += NORMAL * terrain((VERTEX.xy * blend.z + VERTEX.yz * blend.x + VERTEX.zx + blend.y) * terrain_scale);
	 
}

void fragment() {
	ALBEDO = vec3(0.0, 0.2, 0.0);
}
