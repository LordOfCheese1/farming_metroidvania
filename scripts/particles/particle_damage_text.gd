extends "res://scripts/base_classes/particle.gd"


func _physics_process(_delta):
	velocity = dir * 500
	scale.x = (lifetime - time) / lifetime
	scale.y = scale.x
	modulate.a = (lifetime - time) / lifetime
	update_particle()
