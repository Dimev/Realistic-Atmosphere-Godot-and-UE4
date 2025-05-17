extends Camera3D

var speed = 2.0
@export var outer : float = 50.0
@export var inner : float = 20.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	# get the time of the animation, wrapping every 10 seconds
	var time = wrapf(((Time.get_ticks_msec() * speed) / 100000.0), 0.0, 1.0)
	
	# the rotation of the camera
	var phase = time * 2 * TAU
	
	# the rotation of the camera as a vector
	var angle = Vector3(sin(phase), 0.0, cos(phase))
	
	if time > 0.5:
		var orientation = Basis.looking_at(-angle).rotated(angle, -PI / 2).rotated(Vector3.UP, -PI / 2)
		transform = Transform3D(orientation, angle * inner)
	else:
		var orientation = Basis.looking_at(-angle)
		transform = Transform3D(orientation, angle * outer)
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
