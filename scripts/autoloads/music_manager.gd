extends Node2D

var tracklist = {
	# [path in res://, intro ends at, song ends at]
	"coolsville" : [load("res://audio/music/coolsville.mp3"), 3.0, 48.0]
}
var current_loop_start : float = 0.0
var current_loop_end : float = 0.0
var is_playing = false


func _process(_delta):
	is_playing = $music_player.playing
	if $music_player.get_playback_position() > current_loop_end:
		$music_player.play(current_loop_start)


func new_music(code : String):
	$music_player.stop()
	if code != "nothing":
		current_loop_start = tracklist[code][1]
		current_loop_end = tracklist[code][2]
		$music_player.stream = tracklist[code][0]
		$music_player.play(0.0)
	else:
		$music_player.stream = null
