extends Node

@export var speed : float = 2.0
var set = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set = 0
	$AtmoMesh/Camera.speed = speed

func _process(_delta):
	# get the time of the animation, wrapping every 10 seconds
	var time = ((Time.get_ticks_msec() * speed) / 100000.0)
	
	# leave the default colors
	if time > 1 and set == 0:
		$AtmoMesh.mesh.get_material().set_shader_parameter("beta_ray", Vector3(4, 1, 1))
		set = 1
	elif time > 1.1 and set == 1:
		$AtmoMesh.mesh.get_material().set_shader_parameter("beta_ray", Vector3(1, 4, 2))
		set = 2
	elif time > 1.2 * PI + 2 and set == 2:
		$AtmoMesh.mesh.get_material().set_shader_parameter("beta_ray", Vector3(4, 1, 2))
		$AtmoMesh.mesh.get_material().set_shader_parameter("intensity", 10.0)
		set = 3
	elif time > 1.3 * PI + 3 and set == 3:
		$AtmoMesh.mesh.get_material().set_shader_parameter("beta_ray", Vector3(4, 2, 1))
		$AtmoMesh.mesh.get_material().set_shader_parameter("beta_mie", Vector3(1, 4, 1))
		$AtmoMesh.mesh.get_material().set_shader_parameter("mie_g", 0.6)
		set = 4
	elif time > 1.4 and set == 4:
		$AtmoMesh.mesh.get_material().set_shader_parameter("beta_ray", Vector3(1, 1, 3))
		$AtmoMesh.mesh.get_material().set_shader_parameter("beta_mie", Vector3(4, 1, 1))
		$AtmoMesh.mesh.get_material().set_shader_parameter("mie_g", 0.8)
		$AtmoMesh.mesh.get_material().set_shader_parameter("intensity", 6.0)
		set = 5
