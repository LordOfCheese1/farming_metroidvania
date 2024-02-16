extends Area2D

@export var damage : float = 1.0
var direction = Vector2(0, 0)
var speed = 0.0
var time = 0.0
var lifetime = 10.0


func projectile_update(delta : float):
	time += delta
	if time > lifetime:
		call_deferred("free")
