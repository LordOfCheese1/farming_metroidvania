@tool
extends "res://scripts/base_classes/interface_object.gd"

@export var size = Vector2(40, 40)
@export var colour : Color
@export_enum("scene_switch", "quit", "keybind", "taxi_goal") var to_do_on_usage = "scene_switch"
@export var params = []
@export var text_to_put : String
var listening_for_input = false
var illegal_inputs = [
	"Escape",
	"Enter",
	"Alt"
]


func _ready():
	$rect.size = size
	$rect.color = colour


func _input(event):
	if event is InputEventKey or event is InputEventMouseButton && !Engine.is_editor_hint():
		if event.is_pressed():
			if listening_for_input && event.as_text() != "Enter":
				InputMap.action_erase_events(params[0])
				InputMap.action_add_event(params[0], event)
				listening_for_input = false


func _process(_delta):
	$display_text.position = $rect.position
	$display_text.size = $rect.size
	$display_text.text = text_to_put
	$input_bind.position.x = $rect.size.x * 0.5 + 10.0
	$input_bind.position.y = $rect.position.y
	$input_bind.size = $rect.size
	if to_do_on_usage != "keybind":
		$input_bind.text = ""
	if Engine.is_editor_hint():
		$rect.position = -size * 0.5
		$rect.size = size
		$rect.color = colour
	else:
		if to_do_on_usage == "keybind":
			$input_bind.text = DialogueManager.find_key_via_input_action(params[0])
		if !listening_for_input:
			$display_text.text = text_to_put
		$rect.position = -$rect.size * 0.5
		if is_selected:
			$outline.visible = true
			$outline.size = size + Vector2(6, 6)
			$outline.position = -$outline.size * 0.5
			
			if listening_for_input:
				$display_text.text = "Hit a button..."
				get_parent().disabled = true
			elif to_do_on_usage == "keybind":
				get_parent().disabled = false
		else:
			$outline.visible = false
			listening_for_input = false
		
		if mouse_is_here() && !get_parent().disabled:
			get_parent().jump_selection(self)
		
		if to_do_on_usage == "taxi_goal":
			if get_parent().disabled:
				is_selected = false


func mouse_is_here():
	var mouse_pos = get_global_mouse_position()
	var rect_pos = global_position
	return abs(rect_pos.x - mouse_pos.x) < size.x * 0.5 && abs(rect_pos.y - mouse_pos.y) < size.y * 0.5


func _on_use():
	match to_do_on_usage:
		"scene_switch":
			get_tree().change_scene_to_file(params[0])
		"quit":
			get_tree().quit()
		"keybind":
			listening_for_input = !listening_for_input
		"taxi_goal":
			taxi_response()

func taxi_response():
	if is_selected && Globals.gameplay_scene_active && !get_parent().disabled:
		get_tree().current_scene.do_the_taxi(params[0])
