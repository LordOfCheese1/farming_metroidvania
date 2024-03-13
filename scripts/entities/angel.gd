extends "res://scripts/base_classes/entity.gd"

var init_pos = Vector2(0, 0)
var t = 0.0
@export var laser_proj : PackedScene
@export var particle_scene : PackedScene
var laser_active = null
var attack_cd = 160
var aggressive = false


func _ready():
	entity_setup()
	init_pos = position


func _physics_process(delta):
	t += delta
	position = init_pos + Vector2(sin(t * 2) * 20, 0)
	var prev_rot = $sprite.rotation_degrees
	$sprite.look_at(Globals.player_pos)
	$sprite.rotation_degrees = lerp(prev_rot, $sprite.rotation_degrees, 0.05)
	$sprite.scale.x = 1 - (sin(t) + 1) * 0.05
	$sprite.scale.y = $sprite.scale.x
	$line.points[0] = to_local(init_pos - Vector2(0, 300))
	
	if laser_active != null:
		laser_active.target_dir = $sprite.transform.x
	
	if aggressive && position.distance_to(Globals.player_pos) < 1200:
		if attack_cd == 40:
			ParticleSystem.new_circle(particle_scene, $sprite/laser.global_position, 12, 40)
		if attack_cd > 0:
			attack_cd -= 1
		else:
			attack_cd = 160
			do_a_laser()


func do_a_laser():
	var laser = laser_proj.instantiate()
	laser.position = global_position
	laser.to_follow = $sprite/laser
	laser.target_dir = $sprite.transform.x
	laser.lifetime = 1.0
	get_tree().current_scene.get_node("active_room").get_child(0).get_node("projectiles").call_deferred("add_child", laser)
	laser_active = laser


func _on_hitbox_hit():
	aggressive = true
	if hp <= 0:
		call_deferred("free")
