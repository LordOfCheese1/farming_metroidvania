extends "res://scripts/base_classes/entity.gd"

var shoot_cd = 60
var player_spotted = false
var location_time = 0.0
var vine_cd = 180
@export var spit : PackedScene
@export var spore : PackedScene
@export var vine : PackedScene


func _ready():
	add_to_group("evil")
	entity_setup()


func _physics_process(delta):
	$anim.play("idle")
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
		if abs(position.x - Globals.player_pos.x) < 640:
			if Globals.gameplay_scene_active:
				get_tree().current_scene.trigger_boss("flowerboss")
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
