extends StaticBody2D

@export var remember_me = true
@export var unique_id = "banana"


func _ready():
	if remember_me:
		if SaveManager.save_data["broken_blocks"].has(unique_id):
			call_deferred("free")


func _on_detect_area_entered(area):
	if area.is_in_group("explosive"):
		if remember_me:
			SaveManager.save_data["broken_blocks"].append(unique_id)
		call_deferred("free")
