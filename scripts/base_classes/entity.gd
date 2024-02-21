extends CharacterBody2D

const GRAVITY : float = 1300.0
var input = Vector2(0.0, 0.0)
var hp : float = 1.0
var last_hit_from : Vector2
@export var max_hp : float = 1.0

@export var set_hp_on_setup = true
@export var blood_amt : int = 20
@export var save_death_temporarily = false
@export var min_seed_drops : int = 0
@export var max_seed_drops : int = 0
@export var seed_to_drop_id : String


func entity_setup():
	add_to_group("entity")
	
	if set_hp_on_setup:
		hp = max_hp
	
	if save_death_temporarily:
		var room_name = get_tree().current_scene.get_node("active_room").get_child(0).name
		if SaveManager.save_data["temporary_enemy_deaths"].has(room_name + "-" + name):
			call_deferred("free")


func hit():
	Globals.pause_for(3)
	blood()
	if hp <= 0:
		if max_seed_drops > 0:
			for i in randi_range(min_seed_drops, max_seed_drops):
				var item_pickup = load("res://prefabs/level_elements/item_pickup.tscn").instantiate()
				item_pickup.item_id = seed_to_drop_id
				item_pickup.position = position + Vector2(i * 80, randf_range(-10, -30))
				item_pickup.time = randf_range(0.0, 2 * PI)
				get_parent().get_parent().get_node("stuff").call_deferred("add_child", item_pickup)
		if save_death_temporarily:
			var room_name = get_tree().current_scene.get_node("active_room").get_child(0).name
			SaveManager.save_data["temporary_enemy_deaths"].append(room_name + "-" + name)


func blood():
	var spray_direction = (global_position - last_hit_from).normalized()
	ParticleSystem.new_explosion("res://prefabs/particles/particle_blood.tscn", global_position, blood_amt, -PI / 2, PI / 2, spray_direction)
