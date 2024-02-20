extends Node2D

var plant_table = { # id : max growth stage
	"carrot" : 2
}
var plants_in_proximity = []
var plant_tick_timer = 120
# name of the plant object, id for texture, growth stage

func _physics_process(_delta):
	# lots of indents for what boils down to "if you're not in a farming zone, increment growth tick timer by -1"
	if Globals.gameplay_scene_active:
		var active_room_parent = get_tree().current_scene.get_node("active_room")
		if active_room_parent.get_child_count() > 0:
			if !active_room_parent.get_child(0).has_plants:
				plant_tick_timer -= 1
	if plant_tick_timer <= 0:
		plant_tick_timer = 120
		SaveManager.tick_plants()


func plant_a_plant(plant_id : String):
	var the_plant_in_question = plants_in_proximity[0]
	the_plant_in_question.id = plant_id
	the_plant_in_question.stage = 0
	the_plant_in_question.max_stage = plant_table[plant_id]
	the_plant_in_question.update_visuals(load("res://textures/plants/" + plant_id + ".png"))
	# plants : {
	#   room name : {
	#      plant name : [plant_id, growth stage]
	#    }
	#}
	SaveManager.save_data["plants"][get_tree().current_scene.get_node("active_room").get_child(0).name][the_plant_in_question.name] = [plant_id, 0]
	print("planted " + plant_id + " at " + str(the_plant_in_question.position))


func load_plants():
	for plant in get_tree().current_scene.get_node("active_room").get_child(0).get_node("plants").get_children():
		var saved_values = SaveManager.save_data["plants"][get_tree().current_scene.get_node("active_room").get_child(0).name]
		if saved_values.keys().has(plant.name):
			plant.id = saved_values[plant.name][0]
			plant.max_stage = plant_table[saved_values[plant.name][0]]
			plant.stage = clamp(saved_values[plant.name][1], 0, plant.max_stage) # some error here, worry about it tomorrow
			plant.update_visuals(load("res://textures/plants/" + saved_values[plant.name][0] + ".png"))
