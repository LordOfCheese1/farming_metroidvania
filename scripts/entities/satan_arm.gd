extends "res://scripts/base_classes/entity.gd"

var in_fight_pos : Vector2
var desirable_pos = Vector2(0, 0)
var time = 0.0
var player_spotted = false
var prev_pos = Vector2(0, 0)
var x_location : float = 0
var attack_cd = 80
var is_attacking = 0
var current_attack = -1
@export var magic_particle_scene : PackedScene
@export var magick_proj_scene : PackedScene
@export var other_particle : PackedScene
@export var other_proj : PackedScene
@export var laser_proj : PackedScene
@export var gate : NodePath
var blood_cd = 0


func _ready():
	entity_setup()
	add_to_group("devil")
	add_to_group("evil")
	in_fight_pos = position
	position.y = in_fight_pos.y - 600
	desirable_pos = position


func _physics_process(delta):
	$hitbox.rotation_degrees = $visuals.rotation_degrees
	if player_spotted && hp > 0:
		time += delta
		prev_pos = position
		position = lerp(position, desirable_pos + Vector2(0, sin(time * 2) * 20), 0.1)
		
		
		if is_attacking > 0:
			attack()
			is_attacking -= 1
		else:
			x_location = snapped(sin(time * 0.5), 1)
			desirable_pos.x = in_fight_pos.x + x_location * 500
			$visuals.rotation_degrees = lerp($visuals.rotation_degrees, 0.0, 0.1)
			$visuals/finger2.scale.y = 1.0
			$visuals/finger3.scale.y = 1.0
			$visuals/finger1.rotation_degrees = 0
			$visuals/finger0.rotation_degrees = -45
			if attack_cd > 0:
				attack_cd -= 1
			else:
				current_attack += 1
				if current_attack > 2:
					current_attack = 0
				attack_cd = 75 + hp * 0.9
				is_attacking = 80
	elif hp <= 0:
		if blood_cd > 0:
			blood_cd -= 1
		else:
			$hitbox/CollisionPolygon2D.disabled = true
			blood_cd = 10
			$visuals.modulate.a -= 0.07
			if $visuals.modulate.a <= 0:
				call_deferred("free")
			blood($hitbox.global_position + Vector2(randf_range(-40, 40), randf_range(-250, 250)), 20, Vector2(0, 0))
	
	if !player_spotted:
		if abs(position.x - Globals.player_pos.x) < 200:
			player_spotted = true
			if Globals.gameplay_scene_active:
				get_tree().current_scene.trigger_boss("kill_the_sun", self)
				get_node(gate).close()
			desirable_pos.y = in_fight_pos.y


func attack():
	if current_attack == 0:
		var prev_rot = $visuals.rotation_degrees
		$visuals.look_at(Globals.player_pos + Vector2(0, 1200))
		$visuals.rotation_degrees -= 90
		$visuals.rotation_degrees = lerp(prev_rot, $visuals.rotation_degrees, 0.1)
		$visuals/finger2.scale.y = -0.5
		$visuals/finger3.scale.y = -0.5
		$visuals/finger0.rotation_degrees = 0
		$visuals/finger3.rotation_degrees = 0
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
	elif current_attack == 1:
		var prev_rot = $visuals.rotation_degrees
		desirable_pos.x = lerp(desirable_pos.x, Globals.player_pos.x, 0.05)
		x_location = 0
		$visuals.rotation_degrees = lerp(prev_rot, $visuals.rotation_degrees, 0.1)
		$visuals/finger2.scale.y = -0.5
		$visuals/finger0.rotation_degrees = -60
		if is_attacking == 50:
			spawn_laser(true)
			spawn_laser(false)
	elif current_attack == 2:
		var prev_rot = $visuals.rotation_degrees
		$visuals.look_at(Globals.player_pos + Vector2(0, 1200))
		$visuals.rotation_degrees -= 90
		$visuals.rotation_degrees = lerp(prev_rot, $visuals.rotation_degrees, 0.1)
		$visuals/finger2.scale.y = -0.5
		$visuals/finger3.scale.y = -0.5
		$visuals/finger0.rotation_degrees = 0
		$visuals/finger3.rotation_degrees = 0
		$visuals/finger1.look_at(Globals.player_pos)
		if is_attacking == 45:
			ParticleSystem.new_circle(other_particle, $visuals/finger1.global_position + $visuals/finger1.transform.x * 90, 12, 40)
		
		if is_attacking == 18:
			spawn_projectile(true)
		
		$visuals/finger1.rotation_degrees -= 90


func spawn_projectile(a = false):
	if !a:
		ParticleSystem.new_circle(magic_particle_scene, $visuals/finger1.global_position + $visuals/finger1.transform.x * 90, 12, 20)
		var projectile = magick_proj_scene.instantiate()
		projectile.position = $visuals/finger1.global_position + $visuals/finger1.transform.x * 90
		projectile.look_at(Globals.player_pos)
		get_tree().current_scene.get_node("active_room").get_child(0).get_node("projectiles").call_deferred("add_child", projectile)
	else:
		ParticleSystem.new_circle(other_particle, $visuals/finger1.global_position + $visuals/finger1.transform.x * 90, 12, 20)
		var projectile = other_proj.instantiate()
		projectile.position = $visuals/finger1.global_position + $visuals/finger1.transform.x * 90
		projectile.look_at(Globals.player_pos)
		get_tree().current_scene.get_node("active_room").get_child(0).get_node("projectiles").call_deferred("add_child", projectile)


func spawn_laser(a = false):
	var laser = laser_proj.instantiate()
	if a:
		laser.to_follow = $visuals/finger1/orig
	else:
		laser.to_follow = $visuals/finger3/orig
	laser.target_dir = Vector2(0, 1)
	laser.lifetime = 50.0 / 60.0
	get_tree().current_scene.get_node("active_room").get_child(0).get_node("projectiles").call_deferred("add_child", laser)


func _on_hitbox_hit():
	blood($hitbox.global_position, 20, Vector2(0, 0))
	if hp <= 0:
		get_node(gate).open()
