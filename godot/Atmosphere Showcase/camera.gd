extends Camera3D

var speed = 2.0
@export var outer : float = 50.0
@export var inner : float = 20.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var time = wrapf(((Time.get_ticks_msec() * speed) / 10000.0) - 10.0, 0.0, 2.0 * PI)
	if time < PI + 0.6:
		var pos = Vector3(sin(time) * outer, 0.0, cos(time) * outer)
		transform = Transform3D(Basis(Vector3(0.0, 1.0, 0.0), time), pos)
	elif time < 2 * PI:
		var pos = Vector3(sin(time) * inner, 0.0, cos(time) * inner)
		var orientation = Basis(
			Vector3(0.0, 0.0, 1.0), -0.5 * PI).rotated(
				Vector3(0.0, 1.0, 0.0), time - 0.5 * PI)
		transform = Transform3D(orientation, pos)
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		

