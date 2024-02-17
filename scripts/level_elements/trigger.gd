@tool
extends Area2D

@export_enum("dialogue", "music") var type = "dialogue"
@export var params = []
@export var size = Vector2(80.0, 80.0)
@export var delete_on_trigger : bool = true
@export var id = "" # unique for every single trigger
signal triggered


func _ready():
	if !Engine.is_editor_hint():
		$collider.shape.size = size
		$label.call_deferred("free")


func _physics_process(_delta):
	if Engine.is_editor_hint():
		$collider.shape.size = size
		$label.text = id


func find_respective_function():
	match type:
		"dialogue":
			DialogueManager.start_dialogue(params[0])
		"music":
			MusicManager.new_music(params[0])


func _on_body_entered(body):
	if body.is_in_group("player") && !SaveManager.save_data["finished_triggers"].has(id):
		emit_signal("triggered")
		find_respective_function()
		if delete_on_trigger == true:
			SaveManager.save_data["finished_triggers"].append(id)
			call_deferred("free")
