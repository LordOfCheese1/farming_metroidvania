extends "res://scripts/base_classes/interface_object.gd"

var size = Vector2(412, 80)
var volume_options = {
	"silence" : -80,
	"lowest" : -60,
	"lower" : -40,
	"low" : -20,
	"medium" : 0,
	"loud" : 20,
	"louder" : 40,
	"loudest" : 60
}


func _process(delta):
	if mouse_is_here() && !get_parent().disabled && visible:
		get_parent().jump_selection(self)


func mouse_is_here():
	var mouse_pos = get_global_mouse_position()
	var rect_pos = global_position
	return abs(rect_pos.x - mouse_pos.x) < size.x * 0.5 && abs(rect_pos.y - mouse_pos.y) < size.y * 0.5
