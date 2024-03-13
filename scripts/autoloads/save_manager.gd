extends Node2D

var save_data = {
	"finished_triggers" : [],
	"broken_blocks" : [],
	"plants" : {},
	"permanent_enemy_deaths" : [],
	"current_room_name" : "res://prefabs/rooms/000_beginning.tscn",
	"save_point_name" : "",
	"coolsville_music_done" : false,
	"unlocked_taxis" : {
		"res://prefabs/rooms/006_city_greenhouse.tscn" : false,
		"res://prefabs/rooms/016_prevoss.tscn" : false,
		"res://prefabs/rooms/013_hell_greenhouse.tscn" : false
	},
	"weapons" : {
		"shovel" : -1,
		"seeds_carrot" : 5,
		"seeds_melon" : 0,
		"seeds_banana" : 0,
		"carrot" : 0,
		"melon" : 0,
		"banana" : 0
	}
}
var session_data = {
	"temporary_enemy_deaths" : []
}


func save_to_disk():
	var file = FileAccess.open(OS.get_executable_path().get_base_dir() + "/" + "save_file.json", FileAccess.WRITE)
	print("saved to " + OS.get_executable_path().get_base_dir() + "/" + "save_file.json")
	file.store_string(JSON.stringify(save_data))
	file.close()


func load_from_disk():
	if FileAccess.file_exists(OS.get_executable_path().get_base_dir() + "/" + "save_file.json"):
		var file = FileAccess.open(OS.get_executable_path().get_base_dir() + "/" + "save_file.json", FileAccess.READ)
		print("loaded from " + OS.get_executable_path().get_base_dir() + "/" + "save_file.json")
		if file.get_as_text() != "":
			save_data = JSON.parse_string(file.get_as_text())
		file.close()


func tick_plants():
	print("growth tick")
	for room_name in save_data["plants"].keys():
		for plant_name in save_data["plants"][room_name]:
			save_data["plants"][room_name][plant_name][1] += 1
