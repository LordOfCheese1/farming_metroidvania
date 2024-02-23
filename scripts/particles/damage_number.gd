extends Node2D

var time = 1.0
@export var damage : float


func _ready():
	rotation_degrees = randf_range(-10, 10)
	$label.text = str(snapped(damage, 0.1))


func _physics_process(delta):
	time -= delta
	modulate.a = time
	position.y -= time * 3
	
	if time <= 0:
		call_deferred("free")
