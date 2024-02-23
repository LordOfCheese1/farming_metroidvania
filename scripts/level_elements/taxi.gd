extends Area2D

var player = null
var player_is_here = false


func _ready():
	add_to_group("taxi")


func _process(_delta):
	if player_is_here:
		if Input.is_action_just_pressed("jump"):
			if player != null:
				player.delayed_velocity.y = 700
			if !get_tree().current_scene.taxi_menu_active:
				get_tree().current_scene.toggle_taxi_interface(true)
				player.hide()
				$visuals/head.show()
				player_is_here = false
				Globals.freeze_player_movement = true


func drive():
	$anim.play("drive")


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.is_near_npc = true
		player = body
		player_is_here = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		body.is_near_npc = false
		player_is_here = false
		player = body
