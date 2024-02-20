extends "res://scripts/base_classes/projectile.gd"

var rot = 0.0


func _ready():
	$sprite.look_at(get_global_mouse_position())
	$sprite.rotation_degrees += 45


func _physics_process(delta):
	velocity.y += 900 * delta
	$sprite.rotation_degrees += velocity.x * 0.05
	projectile_update(delta)


func _on_body_entered(body):
	if body.get_class() == "TileMap":
		call_deferred("free")


func _on_hurtbox_has_hit():
	call_deferred("free")
