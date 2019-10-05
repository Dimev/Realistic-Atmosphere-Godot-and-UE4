extends Camera

var speed = 2.0
export(float) var outer = 50.0
export(float) var inner = 20.5

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var time = wrapf((OS.get_ticks_msec() * speed) / 10000.0, 0.0, 2.0 * PI)
	if time < PI + 0.6:
		var pos = Vector3(sin(time) * outer, 0.0, cos(time) * outer)
		transform = Transform(Basis(Vector3(0.0, 1.0, 0.0), time), pos)
	elif time < 2 * PI:
		var pos = Vector3(sin(time) * inner, 0.0, cos(time) * inner)
		var orientation = Basis(
			Vector3(0.0, 0.0, 1.0), -0.5 * PI).rotated(
				Vector3(0.0, 1.0, 0.0), time - 0.5 * PI)
		transform = Transform(orientation, pos)

