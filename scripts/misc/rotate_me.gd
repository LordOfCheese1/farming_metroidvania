extends Node2D

var init_pos = Vector2(0, 0)
@export var time = 0.0
@export var sin_x : float = 1.0
@export var cos_y : float = 1.0
@export var speed : float = 1.0


func _ready():
	init_pos = position


func _physics_process(delta):
	time += delta
	
	position = init_pos + Vector2(sin(time * speed) * sin_x, cos(time * speed) * cos_y)
