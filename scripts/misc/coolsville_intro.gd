extends Node2D

@export var the_noise : NodePath
@export var light_1 : NodePath
@export var light_2 : NodePath
@export var the_buildings : NodePath
var the_noise_real = null

func _ready():
	the_noise_real = get_node(the_noise)


func _physics_process(_delta):
	if MusicManager.is_playing:
		get_node(light_1).show()
		get_node(light_2).show()
		get_node(the_buildings).show()
		the_noise_real.call_deferred("free")
		call_deferred("free")
	the_noise_real.volume_db = -((3000 - Globals.player_pos.x) / 3000.0) * 50
	if !the_noise_real.playing:
		the_noise_real.play()


func _on_trigger_triggered():
	get_node(light_1).show()
	get_node(light_2).show()
	get_node(the_buildings).show()
	SaveManager.save_data["coolsville_music_done"] = true
	the_noise_real.call_deferred("free")
	call_deferred("free")
