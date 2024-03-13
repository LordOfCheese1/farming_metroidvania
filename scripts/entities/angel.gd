extends "res://scripts/base_classes/entity.gd"

var init_pos = Vector2(0, 0)
var t = 0.0
@export var laser_proj : PackedScene


func _ready():
	entity_setup()
	init_pos = position


func _physics_process(delta):
	t += delta
	position = init_pos + Vector2(sin(t * 2) * 20, 0)
	var prev_rot = $sprite.rotation_degrees
	$sprite.look_at(Globals.player_pos)
	$sprite.rotation_degrees = lerp(prev_rot, $sprite.rotation_degrees, 0.1)
	$sprite.scale.x = 1 - (sin(t) + 1) * 0.05
	$sprite.scale.y = $sprite.scale.x
	$line.points[0] = to_local(init_pos - Vector2(0, 300))
