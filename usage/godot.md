# Usage with godot
How to get the atmosphere woking in godot.

### getting the assets into godot
- make a new shader resource in godot named atmosphere.shader
- copy all code from [this file](../godot/shader/atmosphere.shader) into the file

### adding it to a scene
- add a new MeshInstance to your scene
- set the mesh of this MeshInstance to a CubeMesh
- make sure to enable Flip Faces (not doing this prevents the atmosphere from woring when the camera is inside the mesh)
- increase the x, y, and z size of the mesh to 60
- under the material of the mesh, make a new ShaderMaterial
- edit this ShaderMaterial, and load the atmosphere.shader file as the shader
- you should now have an atmosphere in your scene

### changing light direction
by rotating the MeshInstance, you can change the light direction.

### editing parameters
you can freely edit the parameters of the ShaderMaterial, here's what they do

| Parameter      | Description                                                                                                     
|:---------------|:---------------------------------------------------------------------------------------------------------------- 
| planet_radius  | how big the planet is, affects how big the atmosphere is too                                                    
| atmo_radius 	 | how big the outer sphere is, if set too low, it can cut off the atmosphere, giving an ugly effect
| beta_ray       | rayleigh scattering paramater, determines the overall color of the atmosphere
| beta_mie       | mie scattering parameter, determines the color (and intensity) of the blob around the sun
| beta_e         | scale of the parameters (10^scale) before usage, all parameters are multpiplied with 10^beta_e. changing this can improve the look in many cases
| g              | mie direction, how big the mie blob around the sun is
| height_ray     | the height scale for rayleigh, how high the rayleigh scattering goes
| height_mie     | height scale for mie, how high the mie scattering goes
| steps_i        | primary ray steps, affects quality the most, 32 is a good default (more is better, but slower)
| steps_l        | light ray steps, affects the sunset quality, 4 is the lowest before the quality becomes visibly worse (more is better, but slower)
| intensity      | the light intensity, makes the atmosphere brighet

