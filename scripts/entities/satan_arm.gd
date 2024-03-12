extends "res://scripts/base_classes/entity.gd"

@export var in_fight_y_pos : float = 0.0
var desirable_pos = Vector2(0, 0)


func _ready():
	position.y = in_fight_y_pos - 500
	desirable_pos = position


func _physics_process(delta):
	pass
