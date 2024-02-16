extends Node


func new_sound(stream : AudioStream, pitch = 1.0, volume = 0.0):
	var streamplayer = AudioStreamPlayer.new()
	streamplayer.volume_db = -20 + volume
	streamplayer.stream = stream
	add_child(streamplayer)
	streamplayer.pitch_scale = pitch
	streamplayer.play(0.0)
	await get_tree().create_timer(stream.get_length()).timeout
	streamplayer.call_deferred("free")
