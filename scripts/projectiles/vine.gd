extends Area2D

var is_done = false
var remaining_time = 1.6
var from = 0.4
var to = 0.25
var flip = false


func _ready():
	$hurtbox/CollisionShape2D.disabled = true
	var look_dir = randf_range(-PI * from, PI * to)
	$raycast.target_position = Vector2(sin(look_dir) * 1280, -cos(look_dir) * 1280)
	if flip:
		$raycast.target_position.y *= -1


func _physics_process(delta):
	if !is_done:
		$raycast.force_raycast_update()
		if $raycast.is_colliding():
			if $raycast.get_collider().name == "tilemap":
				is_done = true
				position = $raycast.get_collision_point()
				ParticleSystem.new_circle(load("res://prefabs/particles/particle_generic_trail.tscn"), global_position, 16, 60)
				look_at(Globals.player_pos)
				$anim.play("attack")
				$sprite.visible = true
			else:
				call_deferred("free")
		else:
			call_deferred("free")
	
	remaining_time -= delta
	if remaining_time <= 0:
		call_deferred("free")
