@tool
extends Area2D

@export_enum("left", "right", "up", "down", "none") var direction = "left"
@export var rect_size  = Vector2(80.0, 80.0)
@export var id : int = 0
@export var send_to_id : int = 0
@export var new_room_path : String
var player_is_here = false
var player = null
var spawn_protection = 15
var trans_value = 0
var scene_to_be_changed = false
var delayed_velocity_for_later = 0.0


func _ready():
	if !Engine.is_editor_hint():
		scene_to_be_changed = false
		$CollisionShape2D.shape.size = rect_size
		$arrow.call_deferred("free")
		$index_label.call_deferred("free")
		trans_value = 0


func _process(_delta):
	if Engine.is_editor_hint():
		# have arrow point into door direction, if direction == none, spin continuously
		match direction:
			"left":
				$arrow.rotation_degrees = 180
			"right":
				$arrow.rotation_degrees = 0
			"up":
				$arrow.rotation_degrees = -90
			"down":
				$arrow.rotation_degrees = 90
			"none":
				$arrow.rotation_degrees += 5
		$CollisionShape2D.shape.size = rect_size
		$index_label.text = str(id) + "-" + str(send_to_id)
	else:
		# compare velocities and door direction so a door isn't accidentally entered
		if player_is_here && spawn_protection <= 0 && !scene_to_be_changed:
			if direction == "left" && player.velocity.x < -1:
				start_changing_process()
			if direction == "right" && player.velocity.x > 1:
				start_changing_process()
			if direction == "up" && player.velocity.y < -1:
				if player != null:
					delayed_velocity_for_later = -1000
				start_changing_process()
			if direction == "down" && player.velocity.y > 1:
				start_changing_process()
		if spawn_protection > 0:
			spawn_protection -= 1
		if scene_to_be_changed:
			if trans_value >= 24:
				change_scene()
			else:
				trans_value += 1


func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_is_here = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_is_here = false


func start_changing_process():
	player.delayed_velocity.y = -player.velocity.y
	if Globals.gameplay_scene_active:
		get_tree().current_scene.start_fade_out()
	Globals.freeze_player_movement = true
	scene_to_be_changed = true


func change_scene():
	if Globals.gameplay_scene_active:
		Globals.freeze_player_movement = false
		get_tree().current_scene.switch_room(new_room_path, send_to_id, id)
		player.delayed_velocity.y = delayed_velocity_for_later
		delayed_velocity_for_later = 0
