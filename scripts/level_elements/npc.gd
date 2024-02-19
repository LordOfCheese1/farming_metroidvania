extends Area2D

var player_is_here = false
var player = null
@export var dialogue_id : String
@export var texture : Texture


func _ready():
	$sprite.texture = texture
	$sprite.position.y = -$sprite.get_rect().size.y * 0.5


func _physics_process(_delta):
	if player_is_here:
		if Input.is_action_just_pressed("jump"):
			if player != null:
				player.delayed_velocity.y = 700
			if DialogueManager.active_dialogue_name == "":
				DialogueManager.start_dialogue(dialogue_id)
				player_is_here = false
				Globals.freeze_player_movement = true
	else:
		if DialogueManager.active_dialogue_name == "":
			Globals.freeze_player_movement = false
			DialogueManager.discard_dialogue()


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_is_here = true
		player = body
		body.is_near_npc = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_is_here = false
		body.is_near_npc = false
