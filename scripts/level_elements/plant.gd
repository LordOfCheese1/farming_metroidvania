extends Area2D

var stage = 0
var max_stage = 1
var id = ""
@export var pickup_scene : PackedScene


func _ready():
	add_to_group("plant")


func update_visuals(tex : Texture, needs_texture = true):
	var plant_sprite = $sprite
	if needs_texture:
		plant_sprite.texture = tex
	else:
		plant_sprite.texture = null
	plant_sprite.hframes = max_stage + 1
	plant_sprite.frame = stage


func attempt_harvest():
	if stage >= max_stage && stage > 0:
		var pickup = pickup_scene.instantiate()
		pickup.item_id = id
		pickup.position = Vector2(position.x + 40, position.y)
		get_parent().get_parent().get_node("stuff").call_deferred("add_child", pickup)
		clear_plant()


func clear_plant():
	stage = 0
	id = ""
	var plant_saves = SaveManager.save_data["plants"]
	if plant_saves.keys().has(get_parent().get_parent().name):
		if plant_saves[get_parent().get_parent().name].keys().has(name):
			plant_saves[get_parent().get_parent().name].erase(name)
	update_visuals(Texture.new(), false)


func _on_body_entered(body):
	if body.is_in_group("player"):
		FarmManager.plants_in_proximity.insert(0, self)


func _on_body_exited(body):
	if body.is_in_group("player"):
		if FarmManager.plants_in_proximity.has(self):
			FarmManager.plants_in_proximity.erase(self)


func _on_area_entered(area):
	if area.is_in_group("hurtbox"):
		attempt_harvest()
