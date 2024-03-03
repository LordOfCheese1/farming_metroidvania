extends "res://scripts/base_classes/entity.gd"

var shoot_cd = 60
var player_spotted = false
var location_time = 0.0
var vine_cd = 180
var explosion_cd = 30
var new_scale = Vector2(1.0, 1.0)

@export var spit : PackedScene
@export var spore : PackedScene
@export var vine : PackedScene
@export var juice_particle : PackedScene

@export var gate_left : NodePath
@export var gate_right : NodePath


func _ready():
	add_to_group("evil")
	entity_setup()


func _physics_process(delta):
	if hp > 0:
		$anim.play("idle")
	else:
		scale = lerp(scale, new_scale, 0.1)
		$visuals/stem.position.y = lerp($visuals/stem.position.y, 0.0, 0.1)
		if explosion_cd > 0:
			explosion_cd -= 1
		else:
			if new_scale.x <= 0.2:
				blood($visuals/stem/head.global_position, 24, Vector2(0, -0.5))
				ParticleSystem.new_explosion("res://prefabs/particles/particle_melon_juice.tscn", $visuals/stem/head.global_position, 22, 0.0, 2 * PI, Vector2(0, -1))
				call_deferred("free")
			new_scale -= Vector2(0.2, 0.2)
			$visuals.rotation_degrees = randf_range(-14, 14)
			blood($visuals/stem/head.global_position, 20, Vector2(0, -1))
			ParticleSystem.new_explosion("res://prefabs/particles/particle_melon_juice.tscn", $visuals/stem/head.global_position, 22, 0.0, 2 * PI, Vector2(0, -0.3))
			explosion_cd = 40
	if player_spotted && hp > 0:
		if hp < max_hp * 0.5:
			if vine_cd > 0:
				vine_cd -= 1
			else:
				vine_cd = 180
				do_vine()
		location_time += delta
		if sin(location_time) > 0:
			$visuals/stem.position.y = lerp($visuals/stem.position.y, 0.0, 0.1)
		else:
			$visuals/stem.position.y = lerp($visuals/stem.position.y, 165.0, 0.1)
		if shoot_cd > 0:
			shoot_cd -= 1
		else:
			if sin(location_time) > 0:
				do_spit()
			else:
				do_spore()
			shoot_cd = 60
			$visuals/stem/head.scale.x = 1.2
	else:
		if abs(position.x - Globals.player_pos.x) < 640 && hp > 0:
			get_node(gate_left).close()
			get_node(gate_right).close()
			if Globals.gameplay_scene_active:
				get_tree().current_scene.trigger_boss("flowerboss", self)
			player_spotted = true
			$hitbox/CollisionShape2D.disabled = false
	
	
	$hitbox.position = to_local($visuals/stem/head.global_position)
	$visuals/stem/head.scale.y = $visuals/stem/head.scale.x
	$visuals/stem/head.scale = lerp($visuals/stem/head.scale, Vector2(1.0, 1.0), 0.1)


func do_vine():
	var vine_proj = vine.instantiate()
	vine_proj.position = $visuals/stem/head.global_position
	get_tree().current_scene.get_node("active_room").get_child(0).get_node("projectiles").call_deferred("add_child", vine_proj)


func do_spit():
	var spit_proj = spit.instantiate()
	spit_proj.position = $visuals/stem/head.global_position
	spit_proj.velocity.x = (Globals.player_pos.x - position.x) * 0.8
	get_tree().current_scene.get_node("active_room").get_child(0).get_node("projectiles").call_deferred("add_child", spit_proj)


func do_spore():
	var spore_proj = spore.instantiate()
	spore_proj.position = $visuals/stem/head.global_position
	spore_proj.look_at(Globals.player_pos)
	get_tree().current_scene.get_node("active_room").get_child(0).get_node("projectiles").call_deferred("add_child", spore_proj)


func _on_hitbox_hit():
	if hp <= 0:
		MusicManager.new_music("coolsville")
		$hitbox/CollisionShape2D.disabled = true
		$anim.stop()
		get_node(gate_left).open()
		get_node(gate_right).open()
		if Globals.gameplay_scene_active:
			get_tree().current_scene.boss_done()
