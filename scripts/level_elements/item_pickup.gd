extends Area2D

@export var item_id : String
var time : float = 0.0
var self_destruct = false


func _ready():
	$bubble.scale = Vector2(0, 0)
	$bubble.modulate.a = 0
	$bubble/weapon_icon.texture = load("res://textures/weapons/" + item_id + ".png")


func _physics_process(delta):
	time += delta
	$bubble.rotation_degrees = sin(2 * time) * 15
	$bubble.scale.x = 1 + sin(time) * 0.1
	$bubble.scale.y = $bubble.scale.x
	$bubble.position.y = (sin(time * 2) + 1) * 5
	if !self_destruct:
		$bubble.scale = lerp($bubble.scale, Vector2(1, 1), 0.2)
		$bubble.modulate.a = lerp($bubble.modulate.a, 1.0, 0.2)
	else:
		$bubble.scale = lerp($bubble.scale, Vector2(0, 0), 0.2)
		$bubble.modulate.a = lerp($bubble.modulate.a, 0.0, 0.2)
		if $bubble.modulate.a < 0.05:
			call_deferred("free")


func _on_body_entered(body):
	if body.is_in_group("player"):
		self_destruct = true
		body.weapon.weapons_available[item_id] += 1
		body.weapon.interface_update()
