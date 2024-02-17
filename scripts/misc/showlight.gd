extends Line2D

var time = 0.0
@export var multiplier = 1


func _physics_process(delta):
	time += delta
	rotation_degrees = sin(time) * 20 * multiplier
