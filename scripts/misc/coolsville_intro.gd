extends Node2D

@export var the_noise : NodePath
var the_noise_real = null

func _ready():
	the_noise_real = get_node(the_noise)


func _physics_process(_delta):
	if MusicManager.is_playing:
		the_noise_real.call_deferred("free")
		call_deferred("free")
	the_noise_real.volume_db = -((3000 - Globals.player_pos.x) / 3000.0) * 50 - 10
	if !the_noise_real.playing:
		the_noise_real.play()


func _on_trigger_triggered():
	the_noise_real.call_deferred("free")
	call_deferred("free")
