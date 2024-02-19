@tool
extends AnimatableBody2D

@export var go_to_y : float
var time = -3.4
var init_y_pos = 0.0


func _ready():
	$line.points[1].y = -500 + go_to_y
	if !Engine.is_editor_hint():
		init_y_pos = position.y


func _process(_delta):
	if Engine.is_editor_hint():
		$editor_guideline.set_point_position(1, Vector2(0, go_to_y))


func _physics_process(delta):
	if !Engine.is_editor_hint():
		time += delta
		position.y = init_y_pos + ((sin(time) + 1) * 0.5) * go_to_y
