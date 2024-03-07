extends "res://scripts/base_classes/projectile.gd"

var orig_node = null
var grapple_node = null
var grapple_pos_adder = Vector2(0, 0)
var over = false
var remaining_hit_count = 3
var has_done_hit = false


func _ready():
	setup()


func _physics_process(delta):
	if orig_node != null:
		$line.points[0] = to_local(orig_node.global_position)
	
	if grapple_node == null:
		if over:
			call_deferred("free")
		velocity = transform.x * 1200.0
	else:
		velocity = Vector2(0, 0)
		position = grapple_node.global_position + grapple_pos_adder
		var player = orig_node.get_parent().get_parent().get_parent()
		if player.is_in_group("player"):
			continuous_grapple_movement(player)
	
	if !$hurtbox.ignore_in_detection.has("player"):
		$hurtbox.ignore_in_detection.append("player")
	projectile_update(delta)


func continuous_grapple_movement(player_node):
	player_node.velocity = (global_position - player_node.position).normalized() * 1200
	player_node.is_grappling = true
	if player_node.position.distance_to(position) < 50:
		perish()
	if !has_done_hit:
		has_done_hit = false
		player_node.has_done_grapple_hit = false


func perish():
	call_deferred("free")


func _on_body_entered(body):
	if grapple_node == null && !body.is_in_group("player"):
		grapple_node = body
		grapple_pos_adder = position - body.global_position
		over = true


func _on_area_entered(area):
	if grapple_node == null:
		if area.is_in_group("hitbox"):
			if !area.ignore_tag == "player":
				grapple_node = area
				grapple_pos_adder = position - area.global_position
				over = true
		elif area.is_in_group("hurtbox"):
			if !area.ignore_in_detection.has("melee") && !area.ignore_in_detection.has("grapple"):
				grapple_node = area
				grapple_pos_adder = position - area.global_position
				over = true


func _on_hurtbox_has_hit():
	remaining_hit_count -= 1
	if remaining_hit_count <= 0:
		call_deferred("free")
