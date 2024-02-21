extends "res://scripts/base_classes/particle.gd"

var orig_velocity = Vector2()


func _ready():
	var angle = randf_range(0, 2 * PI)
	orig_velocity = Vector2(sin(angle), cos(angle)) * 200


func _physics_process(_delta):
	var scaler = float((lifetime - time) / lifetime)
	$polygon.rotation_degrees += velocity.x * 0.1
	$polygon.modulate.a = scaler
	velocity = orig_velocity * scaler
	$polygon.scale = Vector2(1, 1) * scaler
	update_particle()
