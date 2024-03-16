extends "res://scripts/base_classes/entity.gd"

var power = false
var attack_cd = 60
var current_attack = 0
var max_attack = 2
@export var basic_particle : PackedScene
@export var laser_scene : PackedScene
@export var melon_scene : PackedScene
@export var shell_particle : PackedScene
@export var magic_particle : PackedScene
@export var magic_scene : PackedScene
@export var vine_scene : PackedScene
var t = 0.0
var flash_cd = 0
var max_flash_cd = 40


func _ready():
	entity_setup()
	add_to_group("devil")


func _physics_process(delta):
	for beam in $beams.get_children():
		beam.rotation_degrees += 0.5
		if beam.rotation_degrees >= 70:
			beam.rotation_degrees = -70
		beam.offset.y = 790 - (sin(beam.rotation_degrees * 0.2) + 1) * 15
	
	if power && hp > 0:
		if attack_cd > 0:
			attack_cd -= 1
		else:
			choose_attack()
			attack_cd = 120
		if attack_cd == 26:
			choose_telegraph()
	elif hp <= 0:
		t += delta
		scale.x = 0.8 + (sin(t * 6) + 1) * 0.2
		scale.y = scale.x
		modulate.g = 0.8 + (sin(t * 6) + 1) * 0.1
		modulate.b = 0.8 + (sin(t * 6) + 1) * 0.1
		if flash_cd > 0:
			flash_cd -= 1
		else:
			get_tree().current_scene.get_node("camera").zoom = Vector2(1.5, 1.5)
			flash_cd = max_flash_cd
			max_flash_cd -= 3
			if max_flash_cd < 6:
				get_tree().current_scene.flash_mod = 1.0
			else:
				get_tree().current_scene.flash_mod = 0.8
			
			if max_flash_cd < -2:
				get_tree().change_scene_to_file("res://scenes/ending.tscn")
	
	var prev_hand_rot = $hand.rotation_degrees
	$hand.look_at(Globals.player_pos)
	$hand.rotation_degrees = lerp(prev_hand_rot, $hand.rotation_degrees, 0.02)
	$hand.position = lerp($hand.position, $hand.transform.x * 740, 0.05)


func choose_attack():
	if hp <= max_hp * 0.6:
		max_attack = 3
	
	if current_attack == 0:
		attack_a()
	elif current_attack == 1:
		attack_b()
	elif current_attack == 2:
		attack_c()
	elif current_attack == 3:
		attack_d()
	
	current_attack += 1
	if current_attack > max_attack:
		current_attack = 0


func choose_telegraph():
	if current_attack == 0:
		telegraph(basic_particle)
	elif current_attack == 1:
		telegraph(shell_particle)
	elif current_attack == 2:
		telegraph(magic_particle)


func attack_a():
	var laser = laser_scene.instantiate()
	laser.to_follow = $hand/laser
	laser.target_dir = Vector2(0, 1)
	laser.lifetime = 1.0
	get_parent().get_parent().get_node("projectiles").call_deferred("add_child", laser)


func attack_b():
	telegraph(shell_particle)
	var instances = 1
	if hp < max_hp * 0.5:
		instances = 3
	for i in instances:
		var melon = melon_scene.instantiate()
		melon.position = $hand.global_position + $hand.transform.x * 120
		if instances == 1:
			melon.velocity = Vector2(0, 0)
		else:
			melon.velocity = Vector2(i - 1, 0)
		get_parent().get_parent().get_node("projectiles").call_deferred("add_child", melon)
	attack_cd = 35


func attack_c():
	telegraph(magic_particle)
	var instances = 1
	if hp < max_hp * 0.3:
		instances = 3
	for i in instances:
		var magic = magic_scene.instantiate()
		if instances == 1:
			magic.rotation_degrees = $hand.rotation_degrees
		else:
			magic.rotation_degrees = $hand.rotation_degrees + (i - 1) * 30
		magic.position = $hand.global_position + magic.transform.x * 100
		get_parent().get_parent().get_node("projectiles").call_deferred("add_child", magic)


func attack_d():
	var vine = vine_scene.instantiate()
	vine.position = global_position + Vector2(0, 770)
	vine.from = 0.4
	vine.to = 0.4
	vine.flip = true
	get_parent().get_parent().get_node("projectiles").call_deferred("add_child", vine)


func telegraph(particle_scene : PackedScene):
	ParticleSystem.new_circle(particle_scene, $hand.global_position + $hand.transform.x * 120, 12, 40)


func _on_hitbox_hit():
	if hp <= 0:
		get_tree().current_scene.current_boss = null
		MusicManager.new_music("credits")
	if !power:
		power = true
		get_tree().current_scene.trigger_boss("kill_the_sun", self)
