extends "res://scripts/base_classes/particle.gd"


func _physics_process(_delta):
	$sprite.scale.x = float((lifetime - time) / lifetime)
	$sprite.scale.y = $sprite.scale.x
	$sprite.modulate.a = float((lifetime - time) / lifetime)
	update_particle()
