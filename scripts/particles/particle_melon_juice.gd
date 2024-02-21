extends "res://scripts/base_classes/particle.gd"

var init_speed = 500.0
var scaler = 1.0


func _ready():
	velocity = dir * init_speed * randf_range(0.2, 2.0)
	lifetime = randf_range(0.2, 1.0)
	scaler = randf_range(0.5, 1.0)


func _physics_process(_delta):
	velocity.y += GRAVITY * delta
	velocity.x = lerp(velocity.x, 0.0, 0.05)
	
	scale.x = ((lifetime - time) / lifetime) * scaler
	scale.y = scale.x
	modulate.a = (lifetime - time) / lifetime
	
	update_particle()
