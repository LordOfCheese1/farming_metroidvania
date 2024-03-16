extends Node2D

var tracklist = {
	# [path in res://, intro ends at, song ends at]
	"menu" : [load("res://audio/music/menu.mp3"), 0.0, 27.4],
	"coolsville" : [load("res://audio/music/coolsville.mp3"), 3.0, 48.01],
	"flowerboss" : [load("res://audio/music/flowerboss.mp3"), 10.28, 37.70],
	"hell_on_earth" : [load("res://audio/music/hell_on_earth.mp3"), 3.42, 37.70],
	"kill_the_sun" : [load("res://audio/music/kill_the_sun.mp3"), 6.85, 61.70],
	"credits" : [load("res://audio/music/credits.mp3"), 0.0, 25.64]
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
