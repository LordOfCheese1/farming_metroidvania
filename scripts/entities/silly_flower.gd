extends "res://scripts/base_classes/entity.gd"

var neck_length : float = 120.0
var shoot_cd : int = 80
var attacking : int = 0
var gun_is_ready = false
@export var spore_particle_scene : PackedScene
@export var spore_projectile_scene : PackedScene


func _ready():
	entity_setup()


func _physics_process(_delta):
	$visuals/neck.points[1] = lerp($visuals/neck.points[1], (Globals.player_pos - position).normalized() * neck_length, 0.1)
	$visuals/head.position = $visuals/neck.points[1]
	$hitbox.position = $visuals/neck.points[1]
	seed_drop_offset = $visuals/neck.points[1]
	
	if position.distance_to(Globals.player_pos) < 700:
		if shoot_cd > 0:
			shoot_cd -= 1
			gun_is_ready = false
		else:
			if attacking <= 0:
				if !gun_is_ready:
					attacking = 35
					neck_length = 40
					gun_is_ready = true
					ParticleSystem.new_circle(spore_particle_scene, $visuals/head.global_position, 12, 50)
				else:
					shoot()
					neck_length = 120
					shoot_cd = 80
				gun_is_ready = true
			else:
				attacking -= 1
	if hp <= 0:
		call_deferred("free")


func shoot():
	var projectile = spore_projectile_scene.instantiate()
	projectile.position = $visuals/head.global_position
	projectile.look_at(Globals.player_pos)
	get_tree().current_scene.get_node("active_room").get_child(0).get_node("projectiles").call_deferred("add_child", projectile)


func _on_hitbox_hit():
	blood($visuals/head.global_position, 20)
