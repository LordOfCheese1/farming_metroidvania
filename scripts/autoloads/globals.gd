extends Node2D

var gameplay_scene_active = false
var player_pos = Vector2(0, 0)
var player_max_health : float = 15.0
var player_health : float = 15.0
var remaining_pause = 0
var freeze_player_movement = false
var reset_health = false


func _physics_process(_delta):
	gameplay_scene_active = get_tree().current_scene.is_in_group("gameplay")
	if remaining_pause > 0:
		remaining_pause -= 1
		get_tree().paused = true
	else:
		get_tree().paused = false
	
	if player_health <= 0:
		freeze_player_movement = true
		if gameplay_scene_active:
			get_tree().current_scene.get_node("camera").zoom = Vector2(3.0, 3.0)


func pause_for(frame_amt : int):
	if frame_amt > remaining_pause:
		remaining_pause = frame_amt
