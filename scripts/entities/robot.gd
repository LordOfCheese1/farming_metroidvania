extends "res://scripts/base_classes/entity.gd"

var player_spotted = false
var time = 0.0


func _ready():
	entity_setup()


func _physics_process(delta):
	time += delta
	velocity.y += GRAVITY * delta
	if !player_spotted:
		if abs(position.x - Globals.player_pos.x) < 280:
			player_spotted = true
	else:
		var dir = 0
		if position.x - Globals.player_pos.x != 0:
			dir = (Globals.player_pos.x - position.x) / abs(Globals.player_pos.x - position.x)
			$visuals.scale.x = dir
		velocity.x = lerp(velocity.x, dir * ((sin(time * 2) + 1) / 2) * 600, 0.02)
	
	$visuals/wheel.rotation_degrees += abs(velocity.x) * 0.05
	
	move_and_slide()


func _process(_delta):
	if abs(velocity.x) > 100.0:
		$anim.play("move")
	else:
		$anim.play("idle")
