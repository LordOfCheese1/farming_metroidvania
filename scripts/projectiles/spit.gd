extends "res://scripts/base_classes/projectile.gd"

@export var particle : PackedScene


func _ready():
	velocity.y = -700
	$sprite.scale = Vector2(0, 0)


func _physics_process(delta):
	$sprite.scale = lerp($sprite.scale, Vector2(1, 1), 0.15)
	velocity.y += 1200 * delta
	projectile_update(delta)


func _on_body_entered(body):
	if body.get_class() == "TileMap":
		perish()


func perish():
	ParticleSystem.new_circle(particle, global_position, 14, 30)
	call_deferred("free")


func _on_hurtbox_has_hit():
	perish()
