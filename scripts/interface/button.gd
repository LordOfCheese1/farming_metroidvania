@tool
extends "res://scripts/base_classes/interface_object.gd"

@export var size = Vector2(40, 40)
@export var colour : Color
@export_enum("scene_switch", "quit") var to_do_on_usage = "scene_switch"
@export var params = []
@export var text_to_put : String


func _ready():
	$rect.size = size
	$rect.color = colour


func _process(_delta):
	$display_text.text = text_to_put
	$display_text.position = $rect.position
	$display_text.size = $rect.size
	if Engine.is_editor_hint():
		$rect.position = -size * 0.5
		$rect.size = size
		$rect.color = colour
	else:
		
		$rect.position = -$rect.size * 0.5
		if is_selected:
			$outline.visible = true
			$outline.size = size + Vector2(6, 6)
			$outline.position = -$outline.size * 0.5
		else:
			$outline.visible = false


func _on_use():
	match to_do_on_usage:
		"scene_switch":
			get_tree().change_scene_to_file(params[0])
		"quit":
			get_tree().quit()
