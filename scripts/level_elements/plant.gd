extends Area2D

var stage = 0
var max_stage = 1


func _ready():
	add_to_group("plant")


func update_visuals(tex : Texture):
	var plant_sprite = $sprite
	plant_sprite.texture = tex
	plant_sprite.hframes = max_stage
	plant_sprite.frame = stage


func attempt_harvest():
	pass


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
