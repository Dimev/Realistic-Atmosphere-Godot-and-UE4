extends Node

@export var speed : float = 2.0
var cam = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	cam = 0
	$AtmoMesh/Camera.speed = speed

func _process(_delta):
	# get the time of the animation, wrapping every 10 seconds
	var time = ((Time.get_ticks_msec() * speed) / 100000.0)
	
	# leave the default colors
	if time > 1 and cam == 0:
		$AtmoMesh.mesh.get_material().set_shader_parameter("beta_ray", Vector3(4, 1, 1))
		cam = 1
	elif time > 1.1 and cam == 1:
		$AtmoMesh.mesh.get_material().set_shader_parameter("beta_ray", Vector3(1, 4, 2))
		cam = 2
	elif time > 1.2 * PI + 2 and cam == 2:
		$AtmoMesh.mesh.get_material().set_shader_parameter("beta_ray", Vector3(4, 1, 2))
		$AtmoMesh.mesh.get_material().set_shader_parameter("intensity", 10.0)
		cam = 3
	elif time > 1.3 * PI + 3 and cam == 3:
		$AtmoMesh.mesh.get_material().set_shader_parameter("beta_ray", Vector3(4, 2, 1))
		$AtmoMesh.mesh.get_material().set_shader_parameter("beta_mie", Vector3(1, 4, 1))
		$AtmoMesh.mesh.get_material().set_shader_parameter("mie_g", 0.6)
		cam = 4
	elif time > 1.4 and cam == 4:
		$AtmoMesh.mesh.get_material().set_shader_parameter("beta_ray", Vector3(1, 1, 3))
		$AtmoMesh.mesh.get_material().set_shader_parameter("beta_mie", Vector3(4, 1, 1))
		$AtmoMesh.mesh.get_material().set_shader_parameter("mie_g", 0.8)
		$AtmoMesh.mesh.get_material().set_shader_parameter("intensity", 6.0)
		cam = 5
