extends Node2D

var tracklist = {
	# [path in res://, intro ends at, song ends at]
	"menu" : [load("res://audio/music/menu.mp3"), 0.0, 24.0],
	"coolsville" : [load("res://audio/music/coolsville.mp3"), 3.0, 48.01]
}
var current_loop_start : float = 0.0
var current_loop_end : float = 0.0
var is_playing = false


func _process(_delta):
	is_playing = $music_player.playing
	if $music_player.get_playback_position() > current_loop_end:
		$music_player.play(current_loop_start)
	if !$music_player.playing:
		$music_player.play(current_loop_start)


func new_music(code : String):
	if code != "nothing":
		if $music_player.stream != tracklist[code][0]:
			current_loop_start = tracklist[code][1]
			current_loop_end = tracklist[code][2]
			$music_player.stream = tracklist[code][0]
			$music_player.play(0.0)
	else:
		$music_player.stop()
		$music_player.stream = null
