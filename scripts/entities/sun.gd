extends "res://scripts/base_classes/entity.gd"

var power = false
var attack_cd = 60
var current_attack = 0
var max_attack = 2
@export var basic_particle : PackedScene


func _ready():
	entity_setup()


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
	
	var prev_hand_rot = $hand.rotation_degrees
	$hand.look_at(Globals.player_pos)
	$hand.rotation_degrees = lerp(prev_hand_rot, $hand.rotation_degrees, 0.02)
	$hand.position = lerp($hand.position, $hand.transform.x * 740, 0.05)


func choose_attack():
	if current_attack == 0:
		attack_a()
	elif current_attack == 1:
		attack_b()
	elif current_attack == 2:
		attack_c()
	
	current_attack += 1
	if current_attack > max_attack:
		current_attack = 0


func attack_a():
	pass


func attack_b():
	pass


func attack_c():
	pass


func telegraph(particle_scene : PackedScene):
	pass


func _on_hitbox_hit():
	power = true
