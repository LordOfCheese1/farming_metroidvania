extends Node2D

var selection_index = 0
var current_object = null


func _process(_delta):
	if Input.is_action_just_pressed("up"):
		cycle(-1)
	if Input.is_action_just_pressed("down"):
		cycle(1)
	
	if current_object != null:
		if Input.is_action_just_pressed("confirm"):
			current_object.emit_signal("use")


func cycle(dir : int = 1):
	selection_index += dir
	
	if selection_index < 0:
		selection_index = get_child_count() - 1
	if selection_index >= get_child_count():
		selection_index = 0
