extends Node2D

var plant_table = { # [texture file, amt of growth stages]
	"carrot" : [load("res://textures/plants/carrot.png"), 3]
}
var plants_in_proximity = []


func _physics_process(_delta):
	pass


func plant_a_plant(plant_id : String):
	if len(plants_in_proximity) > 0:
		var the_plant_in_question = plants_in_proximity[0]
		the_plant_in_question.stage = 0
		the_plant_in_question.max_stage = plant_table[plant_id][1]
		the_plant_in_question.update_visuals(plant_table[plant_id][0])
