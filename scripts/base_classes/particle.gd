extends Node2D

var velocity = Vector2(0, 0)
var time = 0.0
@export var lifetime : float = 30.0
var dir = Vector2(0, 0)
const GRAVITY : float = 1000.0
const delta = 0.017


func update_particle():
	position += velocity * delta
	time += delta
	if time > lifetime:
		call_deferred("free")
