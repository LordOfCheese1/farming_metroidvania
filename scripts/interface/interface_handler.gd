extends Node2D

var selection_index = 0
var current_object = null
var disabled = false


func _process(_delta):
	if !disabled:
		if Input.is_action_just_pressed("up"):
			cycle(-1)
		if Input.is_action_just_pressed("down"):
			cycle(1)
	
	if get_child_count() > 0:
		current_object = get_children()[selection_index]
	
	if current_object != null:
		if !disabled:
			current_object.is_selected = true
		if Input.is_action_just_pressed("confirm"):
			current_object.emit_signal("use")


func cycle(dir : int = 1):
	if current_object != null:
		current_object.is_selected = false
	selection_index += dir
	
	if selection_index < 0:
		selection_index = get_child_count() - 1
	if selection_index >= get_child_count():
		selection_index = 0


func jump_selection(object : Node2D):
	var children = get_children()
	for i in get_child_count():
		if children[i] == object:
			selection_index = i
			object.is_selected = true
			current_object = object
		else:
			children[i].is_selected = false
