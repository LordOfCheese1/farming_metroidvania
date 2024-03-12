extends Node2D

var t = 0.0


func _ready():
	MusicManager.new_music("menu")


func _physics_process(delta):
	t += delta
	$title.position.y = sin(t) * 20
