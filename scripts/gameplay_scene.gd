extends Node2D

@export var starting_scene_path : String
var current_scene_name = ""
var door_to_look_for : int = -1
@export var dialogue_visible = false # don't actually change this in the editor, it's only here for anim to access


func _ready():
	add_to_group("gameplay")
	switch_room(starting_scene_path, 0)


func _process(_delta):
	# check if any room is present at all
	if $active_room.get_child_count() > 0:
		# check if there's a new room, rearrange player and reset camera follow if so
		if $active_room.get_child(0).name != current_scene_name:
			current_scene_name = $active_room.get_child(0).name
			rearrange_player()
			$camera.follow_path = NodePath()
		if $camera.follow_path == NodePath():
			set_camera()


func rearrange_player(door_is_up = false):
	var player = get_node_or_null("player")
	if player != null:
		# add player to new room's entities node
		var player_new_parent = $active_room.get_child(0).get_node("entities")
		player.get_parent().remove_child(player)
		player_new_parent.add_child(player)
		# look for door with fitting ID and put the player there, do nothing if no door is found
		for door in $active_room.get_child(0).get_node("doors").get_children(): 
			if door.id == door_to_look_for:
				if !door_is_up:
					player.position = door.position + Vector2(0, (door.rect_size.y / 2) - 50)
				else:
					player.position = door.position


func set_camera():
	# look for new player path since they've been rearranged under the new entities node
	var room = $active_room.get_child(0)
	var player = room.get_node_or_null("entities/player")
	if player != null:
		# adjust borders and follow path
		$camera.follow_path = room.get_node("entities/player").get_path()
		$camera.set_boundaries(room.top_left.x, room.bottom_right.x, room.top_left.y, room.bottom_right.y)


func switch_room(new_room_path : String, door_to_send_to : int, door_sent_from = 0):
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
	$active_room.call_deferred("add_child", new_room)
	door_to_look_for = door_to_send_to
	print("room swap: " + old_room_name + "-" + str(door_sent_from) + " to " + new_room.name + "-" + str(door_to_send_to))
