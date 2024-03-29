extends Area2D

@export var juice_particle : PackedScene


func _ready():
	$thing.frame = 0
	add_to_group("save_point")


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.hp = body.max_hp
		if $thing.frame == 0:
			ParticleSystem.new_circle(juice_particle, $thing.global_position, 16, 80)
		$anim.play("spin")
		$thing.frame = 1
		SaveManager.session_data["temporary_enemy_deaths"] = []
		SaveManager.save_data["current_room_name"] = get_tree().current_scene.get_node("active_room").get_child(0).scene_file_path
		SaveManager.save_data["save_point_name"] = name
		body.save_weapons()
		SaveManager.save_to_disk()
