extends Area2D

@export var entity : NodePath
@export var ignore_tag = ""
var current_damager : Area2D
var immunity = 0
@export var max_immunity = 12
signal hit
@export var the_sound : AudioStream


func _ready():
	add_to_group("hitbox")


func _physics_process(_delta):
	if immunity > 0:
		immunity -= 1
	elif current_damager != null && get_node_or_null(entity) != null:
		if ignore_tag != "":
			if !current_damager.ignore_in_detection.has(ignore_tag):
				trigger_internal_hit()
		else:
			trigger_internal_hit()


func trigger_internal_hit():
	if Globals.gameplay_scene_active:
		get_tree().current_scene.get_node("camera").zoom = Vector2(1.1, 1.1)
	immunity = max_immunity
	var entity_node = get_node(entity)
	entity_node.hp -= current_damager.damage
	entity_node.last_hit_from = current_damager.global_position
	emit_signal("hit")
	current_damager.emit_signal("has_hit")
	entity_node.hit()
	var damage_number = load("res://prefabs/particles/damage_number.tscn").instantiate()
	damage_number.damage = current_damager.damage
	damage_number.position = current_damager.global_position
	SoundManager.new_sound(the_sound, randf_range(0.8, 1.0))
	get_tree().current_scene.get_node("active_room").get_child(0).get_node("particles").call_deferred("add_child", damage_number)
	print("hit from " + current_damager.get_parent().name + " to " + get_node(entity).name + " - " + str(current_damager.damage) + " dmg")


func trigger_external_hit(damage : float):
	immunity = max_immunity
	var entity_node = get_node(entity)
	entity_node.hit()
	entity_node.hp -= damage
	emit_signal("hit")


func _on_area_entered(area):
	if area.is_in_group("hurtbox"):
		current_damager = area


func _on_area_exited(area):
	if area == current_damager:
		current_damager = null
