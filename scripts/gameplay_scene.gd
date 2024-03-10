extends Node2D

@export var starting_scene_path = "res://prefabs/rooms/000_beginning.tscn"
var current_scene_name = ""
var door_to_look_for : int = -1
@export var transition_scale : float = 1.0
var orig_polygon = PackedVector2Array([Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)])
@export var dialogue_visible = false # don't actually change this in the editor, it's only here for anim to access
var taxi_menu_active = false
var current_taxi_goal = ""
var room_to_be_swapped = false
var time = 0.0
var player_has_been_hit = 0
var pl_bar_points = []
var current_boss = null


func _ready():
	add_to_group("gameplay")
	SaveManager.load_from_disk()
	toggle_taxi_interface(false)
	reload()
	transition_scale = 1092
	for i in range(8):
		pl_bar_points.append($user_interface/player_healthbar/fill.polygon[i])


func _process(_delta):
	# check if any room is present at all
	if $active_room.get_child_count() > 0:
		# check if there's a new room, rearrange player and reset camera follow if so
		if room_to_be_swapped:#$active_room.get_child(0).name != current_scene_name:
			room_to_be_swapped = false
			current_scene_name = $active_room.get_child(0).name
			rearrange_player()
			$camera.follow_path = NodePath()
			if SaveManager.save_data["plants"].keys().has(current_scene_name):
				FarmManager.load_plants()
		if $camera.follow_path == NodePath():
			set_camera()
	
	scale_transition()


func _physics_process(delta):
	time += delta
	if player_has_been_hit > 0:
		player_has_been_hit -= 1
	adjust_player_healthbar()
	adjust_boss_bar()


func reload():
	starting_scene_path = SaveManager.save_data["current_room_name"]
	if SaveManager.save_data["save_point_name"] == "":
		switch_room(starting_scene_path, 0)
	else:
		switch_room(starting_scene_path, -2)
	Globals.update_weapons = true


func rearrange_player(door_is_up = false):
	var player = get_node_or_null("player")
	if player != null:
		# add player to new room's entities node
		var player_new_parent = $active_room.get_child(0).get_node("entities")
		player.get_parent().remove_child(player)
		player_new_parent.add_child(player)
		# look for door with fitting ID and put the player there, do nothing if no door is found
		if door_to_look_for > -1:
			find_door(door_is_up, player)
		elif door_to_look_for == -1: # taxi
			find_taxi(player)
		elif door_to_look_for == -2: # save point
			find_save_point(SaveManager.save_data["save_point_name"], player)


func find_taxi(player):
	if current_taxi_goal != "":
		current_taxi_goal = ""
		for thing in $active_room.get_child(0).get_node("fancy_stuff").get_children():
			if thing.is_in_group("taxi"):
				player.position = thing.position - Vector2(thing.dir * 240, 0)


func find_door(door_is_up : bool, player):
	for door in $active_room.get_child(0).get_node("doors").get_children(): 
			if door.id == door_to_look_for:
				if !door_is_up:
					player.position = door.position + Vector2(0, (door.rect_size.y / 2) - 50)
				else:
					player.position = door.position


func find_save_point(save_point_name : String, player):
	for thing in $active_room.get_child(0).get_node("fancy_stuff").get_children():
		if thing.is_in_group("save_point") && thing.name == save_point_name:
			player.position = thing.position - Vector2(120, 60)


func set_camera():
	# look for new player path since they've been rearranged under the new entities node
	var room = $active_room.get_child(0)
	var player = room.get_node_or_null("entities/player")
	if player != null:
		# adjust borders and follow path
		$camera.follow_path = room.get_node("entities/player").get_path()
		$camera.set_boundaries(room.top_left.x, room.bottom_right.x, room.top_left.y, room.bottom_right.y)


func switch_room(new_room_path : String, door_to_send_to : int, door_sent_from = 0, fancy_id = ""):
	# assume that the old room is the init spawn if no previous room is given
	var old_room_name = "spawn"
	# check if a room currently exists
	if $active_room.get_child_count() > 0:
		old_room_name = $active_room.get_child(0).name
		# temporarily put player as child of new room, to prevent them getting deleted
		var player = $active_room.get_child(0).get_node("entities/player")
		var player_new_parent = self
		player.get_parent().remove_child(player)
		player_new_parent.add_child(player)
		# delete old room
		$active_room.get_child(0).call_deferred("free")
	# add new room
	var new_room = load(new_room_path).instantiate()
	if new_room.has_plants:
		if !SaveManager.save_data["plants"].keys().has(new_room.name):
			SaveManager.save_data["plants"][new_room.name] = {}
	$active_room.call_deferred("add_child", new_room)
	if fancy_id == "":
		door_to_look_for = door_to_send_to
	else:
		door_to_look_for = -1
	Globals.freeze_player_movement = false
	room_to_be_swapped = true
	print("room swap: " + old_room_name + "-" + str(door_sent_from) + " to " + new_room.name + "-" + str(door_to_send_to))


func scale_transition():
	for i in len($user_interface/screen_transition/square.polygon):
		$user_interface/screen_transition/square.polygon[i] = orig_polygon[i] * transition_scale


func start_fade_out():
	$user_interface/screen_transition/anim.play("fade_out")


func toggle_taxi_interface(on_off = true): # true to make it show up, false to make it not
	print("taxi interface toggled - " + str(on_off))
	var i = 0
	for key in SaveManager.save_data["unlocked_taxis"].keys():
		if SaveManager.save_data["unlocked_taxis"][key]:
			$user_interface/taxi_menu/interface_handler.get_child(i).show()
		else:
			$user_interface/taxi_menu/interface_handler.get_child(i).hide()
		i += 1
	$user_interface/taxi_menu.visible = on_off
	taxi_menu_active = on_off
	$user_interface/taxi_menu/interface_handler.disabled = !on_off


func do_the_taxi(room : String):
	current_taxi_goal = room
	if $active_room.get_child_count() > 0:
		for i in $active_room.get_child(0).get_node("fancy_stuff").get_children():
			if i.is_in_group("taxi"):
				i.drive()
				toggle_taxi_interface(false)


func adjust_player_healthbar():
	var fill = $user_interface/player_healthbar/fill
	var value = clamp(Globals.player_health / Globals.player_max_health, 0, 1)
	
	if player_has_been_hit <= 0:
		if value >= 0.9:
			$user_interface/player_healthbar/smiley.frame = 0
		elif value >= 0.55:
			$user_interface/player_healthbar/smiley.frame = 1
		elif value >= 0.3:
			$user_interface/player_healthbar/smiley.frame = 2
		else:
			$user_interface/player_healthbar/smiley.frame = 3
	else:
		$user_interface/player_healthbar/smiley.frame = 4
	
	if value <= 0:
		$user_interface/player_healthbar.hide()
	else:
		$user_interface/player_healthbar.show()
	for i in range(8):
		var wave = (sin(time * 3) + 1) * -1.5
		fill.polygon[i] = lerp(fill.polygon[i], pl_bar_points[i] + Vector2(0, (1 - value) * 144 + wave), 0.1)


func adjust_boss_bar():
	var fill = $user_interface/boss_bar/fill
	var value = 0
	var wave = (sin(time * 2) + 1) * 2
	if current_boss != null:
		$user_interface/boss_bar.modulate.a = lerp($user_interface/boss_bar.modulate.a, 1.0, 0.2)
		value = clamp(current_boss.hp / current_boss.max_hp, 0, 1)
	else:
		$user_interface/boss_bar.modulate.a = lerp($user_interface/boss_bar.modulate.a, 0.0, 0.2)
	fill.points[1].x = lerp(fill.points[1].x, 324.0 + value * 632.0 + wave, 0.1)


func player_death():
	start_fade_out()


func player_hit():
	player_has_been_hit = 10


func finish_fade_out():
	if Globals.player_health <= 0:
		Globals.reset_health = true
		Globals.player_health = Globals.player_max_health
		get_node("camera").zoom = Vector2(1, 1)
		reload()


func trigger_boss(music : String, boss_node = null):
	MusicManager.new_music(music)
	if boss_node != null:
		current_boss = boss_node


func boss_done():
	current_boss = null
