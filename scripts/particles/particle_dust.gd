extends "res://scripts/base_classes/particle.gd"

var scaler = 1.0


func _ready():
	velocity = dir * randf_range(20, 60)
	scaler = randf_range(0.7, 1.2)


func _physics_process(_delta):
	$sprite.scale.x = (time / lifetime) * scaler
	$sprite.scale.y = $sprite.scale.x
	$sprite.modulate.a = ((lifetime - time) / lifetime)
	update_particle()
