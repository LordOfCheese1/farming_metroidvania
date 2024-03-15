extends "res://scripts/base_classes/projectile.gd"

var self_destruct = false
@export var shell_particle : PackedScene
@export var juice_particle : PackedScene
@export var sfx_a : AudioStream
@export var sfx_b : AudioStream


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


func effects_a(mg : int = 1):
	ParticleSystem.new_circle(shell_particle, global_position, 16 * mg, 40 * mg)
	ParticleSystem.new_explosion("res://prefabs/particles/particle_melon_juice.tscn", global_position, 22, 0.0, 2 * PI, Vector2(0, -1))


func effects_b(mg : int = 1):
	ParticleSystem.new_circle(juice_particle, global_position, 16 * mg, 80 * mg)
	ParticleSystem.new_explosion("res://prefabs/particles/particle_melon_juice.tscn", global_position, 22, 0.0, 2 * PI, Vector2(0, -1))
	ParticleSystem.new_circle(juice_particle, global_position, 16, 160)
	call_deferred("free")


func play_sfx():
	SoundManager.new_sound(sfx_a)
	SoundManager.new_sound(sfx_b)


func _on_hurtbox_body_entered(body):
	if body.is_in_group("player"):
		body.is_grappling = true
		body.velocity += (body.position - position) * 10


func _on_hurtbox_has_parried():
	$hurtbox/CollisionShape2D.shape.radius *= 1.6
	$hurtbox.damage *= 4
	if Globals.gameplay_scene_active:
		get_tree().current_scene.flash_mod = 1.0
		get_tree().current_scene.get_node("camera").zoom = Vector2(1.9, 1.9)
	effects_a(2)
	effects_a(3)
	effects_b(2)
	effects_b(3)
	Globals.added_player_velocity = (Globals.player_pos - (position + Vector2(0, 100))).normalized() * 5000
