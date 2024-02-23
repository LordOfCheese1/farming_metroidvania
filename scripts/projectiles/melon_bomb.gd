extends "res://scripts/base_classes/projectile.gd"

var self_destruct = false
@export var shell_particle : PackedScene
@export var juice_particle : PackedScene


func _ready():
	setup()
	velocity = velocity * 800


func _physics_process(delta):
	if !$hurtbox.is_in_group("explosive"):
		$hurtbox.add_to_group("explosive")
	$sprite.rotation_degrees += velocity.x * 0.01
	projectile_update(delta)
	if !self_destruct:
		velocity.y += 1200 * delta
	else:
		velocity = Vector2(0, 0)


func _on_body_entered(body):
	if body.get_class() == "TileMap" or body.get_class() == "StaticBody2D":
		velocity = Vector2(0, 0)
		self_destruct = true
		$anim.play("explode")


func effects_a():
	ParticleSystem.new_circle(shell_particle, global_position, 16, 40)
	ParticleSystem.new_explosion("res://prefabs/particles/particle_melon_juice.tscn", global_position, 22, 0.0, 2 * PI, Vector2(0, -1))


func effects_b():
	ParticleSystem.new_circle(juice_particle, global_position, 16, 80)
	ParticleSystem.new_explosion("res://prefabs/particles/particle_melon_juice.tscn", global_position, 22, 0.0, 2 * PI, Vector2(0, -1))
	ParticleSystem.new_circle(juice_particle, global_position, 16, 160)
	call_deferred("free")


func _on_hurtbox_body_entered(body):
	if body.is_in_group("player"):
		body.velocity += (body.position - position) * 10
