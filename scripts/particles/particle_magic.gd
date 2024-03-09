extends "res://scripts/base_classes/particle.gd"

func _physics_process(_delta):
	var value : float = (lifetime - time) / lifetime
	rotation_degrees += value * 5
	scale = Vector2(value, value)
	modulate.a = value
	update_particle()
