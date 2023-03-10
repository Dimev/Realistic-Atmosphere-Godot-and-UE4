shader_type spatial;

uniform float terrain_scale = 0.15;
uniform float min_height = 20.0;
uniform float max_height = 21.0;

// https://www.shadertoy.com/view/4djSRW
// Hash without Sine
// MIT License...
/* Copyright (c)2014 David Hoskins.
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.*/
vec3 hash33(vec3 p3) {
	p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    return fract((p3.xxy + p3.yxx)*p3.zyx);
}

// return gradient noise (in x) and its derivatives (in yz)
float noise( in vec3 x ) {
    // grid
    vec3 p = floor(x);
    vec3 w = fract(x);
    
    // quintic interpolant
    vec3 u = w * w * w * (w * (w * 6.0 - 15.0) + 10.0);
	
    // gradients
    vec3 ga = hash33(p + vec3(0.0,0.0,0.0));
    vec3 gb = hash33(p + vec3(1.0,0.0,0.0));
    vec3 gc = hash33(p + vec3(0.0,1.0,0.0));
    vec3 gd = hash33(p + vec3(1.0,1.0,0.0));
    vec3 ge = hash33(p + vec3(0.0,0.0,1.0));
    vec3 gf = hash33(p + vec3(1.0,0.0,1.0));
    vec3 gg = hash33(p + vec3(0.0,1.0,1.0));
    vec3 gh = hash33(p + vec3(1.0,1.0,1.0));
    
    // projections
    float va = dot(ga, w - vec3(0.0, 0.0, 0.0));
    float vb = dot(gb, w - vec3(1.0, 0.0, 0.0));
    float vc = dot(gc, w - vec3(0.0, 1.0, 0.0));
    float vd = dot(gd, w - vec3(1.0, 1.0, 0.0));
    float ve = dot(ge, w - vec3(0.0, 0.0, 1.0));
    float vf = dot(gf, w - vec3(1.0, 0.0, 1.0));
    float vg = dot(gg, w - vec3(0.0, 1.0, 1.0));
    float vh = dot(gh, w - vec3(1.0, 1.0, 1.0));
	
    // interpolation
    return va + 
           u.x * (vb - va) + 
           u.y * (vc - va) + 
           u.z * (ve - va) + 
           u.x * u.y * (va - vb - vc + vd) + 
           u.y * u.z * (va - vc - ve + vg) + 
           u.z * u.x * (va - vb - ve + vf) + 
           u.x * u.y * u.z * (-va + vb + vc - vd + ve - vf - vg + vh);
}

float terrain(vec3 x) {
	vec3 position = x;
	float amplitude = 1.0;
	float total = 0.0;
	
	for (int i = 0; i < 4; i++) {
		total += amplitude * noise(position);
		amplitude *= 0.5;
		position *= 2.0;
	}
	
	return total;
}

void vertex() {
	vec3 sphere_vertex = normalize(VERTEX) * min_height * terrain_scale;
	float height = terrain(sphere_vertex);
	VERTEX = normalize(VERTEX) * mix(min_height, max_height, height); 
}

void fragment() {
	// low poly normals
	NORMAL = -normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	ALBEDO = vec3(0.0, 0.2, 0.0);
}
