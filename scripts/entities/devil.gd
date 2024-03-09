extends "res://scripts/base_classes/entity.gd"

var orig_pos = Vector2(0, 0)
var t = 0.0
var attacking = 0
var attack_cd = 60
var time = 0.0
@export var magic_particle : PackedScene
@export var magic_proj_scene : PackedScene


func _ready():
	entity_setup()
	add_to_group("devil")
	orig_pos = position


func _physics_process(delta):
	time += delta
	if attacking <= 0:
		t += delta
		$anim.play("idle")
	else:
		attacking -= 1
		$summoning_circle.scale.x = (60.0 - float(attacking)) / 60.0
		$summoning_circle.scale.y = $summoning_circle.scale.x
		$summoning_circle.modulate.a = float(60 - attacking) / 60
		$summoning_circle.rotation_degrees += attacking * 0.2
		if attacking == 0:
			ParticleSystem.new_circle(magic_particle, $summoning_circle.global_position, 12, 70)
			var magic_proj = magic_proj_scene.instantiate()
			magic_proj.position = $summoning_circle.global_position
			magic_proj.look_at(Globals.player_pos)
			get_tree().current_scene.get_node("active_room").get_child(0).get_node("projectiles").call_deferred("add_child", magic_proj)
			$summoning_circle.modulate.a = 0.0
	
	position = orig_pos + Vector2(sin(t), cos(t)) * 200 + Vector2(0, sin(time * 3) * 80)
	
	if position.distance_to(Globals.player_pos) < 600:
		if Globals.player_pos.x < position.x:
			$visuals.scale.x = -1
		else:
			$visuals.scale.x = 1
		if attack_cd > 0:
			attack_cd -= 1
		else:
			$anim.play("summon")
			attack_cd = 120
			attacking = 60
	else:
		if attacking <= 0:
			$summoning_circle.modulate.a = 0.0
