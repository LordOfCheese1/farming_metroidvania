@tool
extends Area2D

@export_enum("left", "right", "up", "down", "none") var direction = "left"
@export var rect_size  = Vector2(100.0, 100.0)
@export var id : int = 0
@export var send_to_id : int = 0
@export var new_room_path : String
var player_is_here = false
var player = null
var spawn_protection = 15


func _ready():
	if !Engine.is_editor_hint():
		$CollisionShape2D.shape.size = rect_size
		$arrow.call_deferred("free")
		$index_label.call_deferred("free")


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
		if player_is_here && spawn_protection <= 0:
			if direction == "left" && player.velocity.x < -1:
				change_scene()
			if direction == "right" && player.velocity.x > 1:
				change_scene()
			if direction == "up" && player.velocity.y < -1:
				change_scene()
			if direction == "down" && player.velocity.y > 1:
				change_scene()
		if spawn_protection > 0:
			spawn_protection -= 1


func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_is_here = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_is_here = false


func change_scene():
	if Globals.gameplay_scene_active:
		get_tree().current_scene.switch_room(new_room_path, send_to_id, id)
