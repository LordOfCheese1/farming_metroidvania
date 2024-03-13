extends "res://scripts/base_classes/entity.gd"

var in_fight_pos : Vector2
var desirable_pos = Vector2(0, 0)
var time = 0.0
var player_spotted = false
var prev_pos = Vector2(0, 0)
var x_location : float = 0
var attack_cd = 80
var is_attacking = 0
@export var magic_particle_scene : PackedScene
@export var magick_proj_scene : PackedScene


func _ready():
	entity_setup()
	add_to_group("devil")
	add_to_group("evil")
	in_fight_pos = position
	position.y = in_fight_pos.y - 600
	desirable_pos = position


func _physics_process(delta):
	if player_spotted:
		time += delta
		prev_pos = position
		position = lerp(position, desirable_pos + Vector2(0, sin(time * 2) * 20), 0.1)
		
		x_location = snapped(sin(time * 0.5), 1)
		desirable_pos.x = in_fight_pos.x + x_location * 500
		
		if is_attacking > 0:
			is_attacking -= 1
			attack()
		else:
			$visuals.rotation_degrees = lerp($visuals.rotation_degrees, 0.0, 0.1)
			$visuals/finger2.scale.y = 1.0
			$visuals/finger3.scale.y = 1.0
			$visuals/finger1.rotation_degrees = 0
			$visuals/finger0.rotation_degrees = -45
			if attack_cd > 0:
				attack_cd -= 1
			else:
				attack_cd = 125
				is_attacking = 80
	
	if !player_spotted:
		if abs(position.x - Globals.player_pos.x) < 200:
			player_spotted = true
			desirable_pos.y = in_fight_pos.y


func attack():
	var prev_rot = $visuals.rotation_degrees
	$visuals.look_at(Globals.player_pos + Vector2(0, 1200))
	$visuals.rotation_degrees -= 90
	$visuals.rotation_degrees = lerp(prev_rot, $visuals.rotation_degrees, 0.1)
	$visuals/finger2.scale.y = -0.5
	$visuals/finger3.scale.y = -0.5
	$visuals/finger0.rotation_degrees = 0
	$visuals/finger1.look_at(Globals.player_pos)
	if is_attacking == 45:
		ParticleSystem.new_circle(magic_particle_scene, $visuals/finger1.global_position + $visuals/finger1.transform.x * 90, 12, 40)
	
	if is_attacking == 18:
		spawn_projectile()
	
	if is_attacking == 10:
		spawn_projectile()
	
	if is_attacking == 2:
		spawn_projectile()
	
	$visuals/finger1.rotation_degrees -= 90


func spawn_projectile():
	ParticleSystem.new_circle(magic_particle_scene, $visuals/finger1.global_position + $visuals/finger1.transform.x * 90, 12, 20)
	var projectile = magick_proj_scene.instantiate()
	projectile.position = $visuals/finger1.global_position + $visuals/finger1.transform.x * 90
	projectile.look_at(Globals.player_pos)
	get_tree().current_scene.get_node("active_room").get_child(0).get_node("projectiles").call_deferred("add_child", projectile)
