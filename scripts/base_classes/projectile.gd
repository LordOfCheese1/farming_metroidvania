extends Area2D

var time = 0.0
@export var lifetime = 10.0
var velocity = Vector2(0, 0)


func setup():
	add_to_group("projectile")


func projectile_update(delta : float):
	position += velocity * delta
	time += delta
	if time > lifetime:
		call_deferred("free")
