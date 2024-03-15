extends Node2D

var t = 0.0


func _ready():
	MusicManager.new_music("menu")
	RenderingServer.set_default_clear_color(Color("303748"))


func _physics_process(delta):
	t += delta
	$title.position.y = sin(t) * 20
