extends Node2D

var save_data = {
	"finished_triggers" : [],
	"broken_blocks" : [],
	"plants" : {}
}
var session_data = {
	"temporary_enemy_deaths" : []
}


func save_to_disk():
	pass


func tick_plants():
	print("growth tick")
	for room_name in save_data["plants"].keys():
		for plant_name in save_data["plants"][room_name]:
			save_data["plants"][room_name][plant_name][1] += 1
