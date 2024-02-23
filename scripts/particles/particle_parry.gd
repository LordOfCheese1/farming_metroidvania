extends "res://scripts/base_classes/particle.gd"

var scaler : float = 1.0


func _ready():
	$sprite.rotation_degrees = randf_range(0, 90)
	scaler = randf_range(0.8, 1.2)


func _physics_process(_delta):
	$sprite.scale.x = ((lifetime - time) / lifetime) * scaler
	$sprite.scale.y = $sprite.scale.x
	$sprite.rotation_degrees += 8 * scaler
	$sprite.modulate.a = (lifetime - time) / lifetime
	update_particle()
