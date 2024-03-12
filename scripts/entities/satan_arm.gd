extends "res://scripts/base_classes/entity.gd"

var in_fight_y_pos : float = 0.0
var desirable_pos = Vector2(0, 0)
var time = 0.0
var player_spotted = false
var prev_pos = Vector2(0, 0)


func _ready():
	in_fight_y_pos = position.y
	position.y = in_fight_y_pos - 600
	desirable_pos = position


func _physics_process(delta):
	time += delta
	prev_pos = position
	position = lerp(position, desirable_pos + Vector2(0, sin(time * 2) * 20), 0.1)
	
	
	if !player_spotted:
		if abs(position.x - Globals.player_pos.x) < 200:
			player_spotted = true
			desirable_pos.y = in_fight_y_pos
