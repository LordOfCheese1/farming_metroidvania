extends "res://scripts/base_classes/projectile.gd"

var circ_cd = 0
var spore_particle = load("res://prefabs/particles/particle_spore.tscn")


func _ready():
	setup()
	velocity = transform.x * 700.0


func _physics_process(delta):
	if circ_cd > 0:
		circ_cd -= 1
	else:
		circ_cd = 18
		ParticleSystem.new_circle(spore_particle, global_position, 12, 40)
	look_at(position + velocity)
	projectile_update(delta)


func its_over():
	ParticleSystem.new_circle(spore_particle, global_position, 12, 40)
	call_deferred("free")


func _on_hurtbox_body_entered(body):
	if body.get_class() == "TileMap":
		its_over()


func _on_hurtbox_has_hit():
	its_over()
