@tool
extends Node2D

@export var top_left = Vector2i(0, 0)
@export var bottom_right = Vector2i(1280, 880)
@export var has_plants = false
@export var music : String
@export var bg_colour = Color("303748")


func _ready():
	if !Engine.is_editor_hint():
		$editor.call_deferred("free")
		if music != "" && scene_file_path != "res://prefabs/rooms/000_beginning.tscn":
			MusicManager.new_music(music)
		elif scene_file_path == "res://prefabs/rooms/000_beginning.tscn":
			if !SaveManager.save_data["coolsville_music_done"]:
				MusicManager.new_music(music)
		RenderingServer.set_default_clear_color(Color(bg_colour))


func _process(_delta):
	if Engine.is_editor_hint():
		$editor/border_left.set_point_position(0, top_left)
		$editor/border_left.set_point_position(1, Vector2(top_left.x, bottom_right.y))
		
		$editor/border_right.set_point_position(0, bottom_right)
		$editor/border_right.set_point_position(1, Vector2(bottom_right.x, top_left.y))
		
		$editor/border_up.set_point_position(0, top_left)
		$editor/border_up.set_point_position(1, Vector2(bottom_right.x, top_left.y))
		
		$editor/border_down.set_point_position(0, bottom_right)
		$editor/border_down.set_point_position(1, Vector2(top_left.x, bottom_right.y))
