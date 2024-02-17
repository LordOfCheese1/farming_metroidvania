extends "res://scripts/base_classes/entity.gd"

var player_detected = false


func _ready():
	entity_setup()


func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if !player_detected:
		velocity.x = 0
		if abs(Globals.player_pos.x - position.x) < 280:
			player_detected = true
	else:
		var dir_to_player = 1
		if (Globals.player_pos.x - position.x) != 0:
			dir_to_player = (Globals.player_pos.x - position.x) / abs(Globals.player_pos.x - position.x)
		$sprite.flip_h = dir_to_player == -1
		velocity.x = lerp(velocity.x, dir_to_player * 200, 0.05)
	
	move_and_slide()


func _process(_delta):
	if abs(velocity.x) > 10:
		$anim.play("move")
	else:
		$anim.play("idle")


func _on_hitbox_hit():
	if (Globals.player_pos.x - position.x) != 0:
			velocity.x = -(Globals.player_pos.x - position.x) / abs(Globals.player_pos.x - position.x) * 200
