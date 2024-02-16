extends Node2D


func new_explosion(particle_path : String, pos : Vector2, amount : int, spray_start : float, spray_end : float, dir_bias = Vector2(0, 0)): # 2PI is a full rotation, not 360
	var loaded_particle = load(particle_path)
	for i in amount:
		var particle = loaded_particle.instantiate()
		particle.position = pos
		var spray_dir = randf_range(spray_start, spray_end)
		particle.dir = Vector2(sin(spray_dir), -cos(spray_dir)) + dir_bias
		if Globals.gameplay_scene_active:
			get_tree().current_scene.get_node("active_room").get_child(0).get_node("particles").call_deferred("add_child", particle)
		else:
			particle.call_deferred("free")


func new_particle(particle_path : String, pos : Vector2, dir : float):
	var particle = load(particle_path).instantiate()
	particle.position = pos
	particle.dir = Vector2(sin(dir), -cos(dir))
	if Globals.gameplay_scene_active:
		get_tree().current_scene.get_node("active_room").get_child(0).get_node("particles").call_deferred("add_child", particle)
	else:
		particle.call_deferred("free")
