extends Area2D

@export var damage : float
@export var ignore_in_detection = []
@export var is_parriable = true
@export var causes_parries = true
@export var parry_sfx : AudioStream
signal has_hit
signal has_parried


func _ready():
	add_to_group("hurtbox")


func ignore(tag_to_be_ignored : String):
	ignore_in_detection.append(tag_to_be_ignored)


func _on_area_entered(area):
	if area.is_in_group("hurtbox") && causes_parries:
		if area.get_parent().is_in_group("projectile") && area.is_parriable:
			var speed = abs(area.get_parent().velocity.x) + abs(area.get_parent().velocity.y)
			area.get_parent().velocity = (area.global_position - global_position).normalized() * speed * 1.2
			area.ignore_in_detection = []
			area.damage = area.damage + damage
			if Globals.gameplay_scene_active:
				get_tree().current_scene.get_node("camera").zoom = Vector2(1.1, 1.1)
			ParticleSystem.new_circle(load("res://prefabs/particles/particle_parry.tscn"), area.global_position, 12, 80)
			SoundManager.new_sound(parry_sfx, randf_range(0.8, 1.1))
			do_damage_number(area)
			area.emit_signal("has_parried")
			print("parry")


func do_damage_number(proj):
	var damage_number = load("res://prefabs/particles/damage_number.tscn").instantiate()
	damage_number.damage = proj.damage
	damage_number.position = global_position
	get_tree().current_scene.get_node("active_room").get_child(0).get_node("particles").call_deferred("add_child", damage_number)
