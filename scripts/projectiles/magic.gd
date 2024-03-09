extends "res://scripts/base_classes/projectile.gd"

@export var that_particle : PackedScene
var chaotic = false
var chaos_cd = 5
var devil_to_chase = null
var prev_rot = 0.0


func _ready():
	velocity = transform.x * 800
	setup()


func _physics_process(delta):
	prev_rot = rotation_degrees
	projectile_update(delta)
	
	if chaotic:
		if chaos_cd > 0:
			chaos_cd -= 1
		else:
			chaos_cd = 5
			$hurtbox.damage = $hurtbox.damage + 0.5
			$hurtbox.do_damage_number($hurtbox)
			ParticleSystem.new_circle(that_particle, global_position, 12, 40)
		if devil_to_chase != null:
			look_at(devil_to_chase.global_position)
			rotation_degrees = lerp(prev_rot, rotation_degrees, 0.4)
			velocity = transform.x * 1900
		if $hurtbox.damage >= 1000:
			ParticleSystem.new_circle(that_particle, global_position, 12, 40)
			call_deferred("free")
	else:
		look_at(position + velocity)


func _on_hurtbox_has_parried():
	chaotic = true
	ParticleSystem.new_circle(that_particle, global_position, 12, 80)
	$hurtbox.damage = $hurtbox.damage * 2
	$hurtbox.do_damage_number($hurtbox)
	$check_for_devil/CollisionShape2D.set_deferred("disabled", false)


func _on_hurtbox_body_entered(body):
	if body.get_class() == "TileMap":
		ParticleSystem.new_circle(that_particle, global_position, 12, 40)
		call_deferred("free")
	elif body.is_in_group("devil"):
		if body == devil_to_chase:
			ParticleSystem.new_circle(that_particle, global_position, 12, 40)
			call_deferred("free")


func _on_check_for_devil_body_entered(body):
	if body.is_in_group("devil"):
		devil_to_chase = body
