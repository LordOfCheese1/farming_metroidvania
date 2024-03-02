extends "res://scripts/base_classes/particle.gd"


func _ready():
	$shape.rotation_degrees = randf_range(0, 360)


func _physics_process(_delta):
	$shape.scale.x = (lifetime - time) / lifetime
	$shape.scale.y = $shape.scale.x
	$shape.modulate.a = (lifetime - time) / lifetime
	$shape.rotation_degrees += ((lifetime - time) / lifetime) * 6
	update_particle()
