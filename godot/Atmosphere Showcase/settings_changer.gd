extends Node

export(float) var speed = 2.0
var set = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set = 0
	$AtmoMesh/Camera.speed = speed

func _process(_delta):
	var time = ((OS.get_ticks_msec() * speed) / 10000.0) - 10.0
	# leave the default colors
	if time > 2.0 * PI and set == 0:
		$AtmoMesh.mesh.get_material().set_shader_param("beta_ray", Vector3(4, 1, 1))
		set = 1
	elif time > 2.0 * PI + 1 and set == 1:
		$AtmoMesh.mesh.get_material().set_shader_param("beta_ray", Vector3(1, 4, 2))
		set = 2
	elif time > 2.0 * PI + 2 and set == 2:
		$AtmoMesh.mesh.get_material().set_shader_param("beta_ray", Vector3(4, 1, 2))
		$AtmoMesh.mesh.get_material().set_shader_param("intensity", 10.0)
		set = 3
	elif time > 2.0 * PI + 3 and set == 3:
		$AtmoMesh.mesh.get_material().set_shader_param("beta_ray", Vector3(4, 2, 1))
		$AtmoMesh.mesh.get_material().set_shader_param("beta_mie", Vector3(1, 4, 1))
		$AtmoMesh.mesh.get_material().set_shader_param("mie_g", 0.6)
		set = 4
	elif time > 2.0 * PI + 5 and set == 4:
		$AtmoMesh.mesh.get_material().set_shader_param("beta_ray", Vector3(1, 1, 3))
		$AtmoMesh.mesh.get_material().set_shader_param("beta_mie", Vector3(4, 1, 1))
		$AtmoMesh.mesh.get_material().set_shader_param("mie_g", 0.8)
		$AtmoMesh.mesh.get_material().set_shader_param("intensity", 6.0)
		set = 5
