extends Node2D

@export var particle_to_add : PackedScene
@export var time_between_spawns : int
var cooldown = 0


func _physics_process(_delta):
	if cooldown > 0:
		cooldown -= 1
	else:
		cooldown = time_between_spawns
		ParticleSystem.new_particle(particle_to_add, global_position, 0.0)
