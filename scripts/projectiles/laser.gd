extends "res://scripts/base_classes/projectile.gd"

var to_follow = null
var target_dir = Vector2(1, 0)
var over = false
var wanted_alpha = 1.0
var particle_cd = 0


func _ready():
	setup()
	modulate.a = 0


func _physics_process(delta):
	projectile_update(delta)
	
	if to_follow != null:
		position = to_follow.global_position
	
	$line.width = lerp($line.width, 15 + sin(time * 4) * 4, 0.1)
	modulate.a = lerp(modulate.a, wanted_alpha, 0.1)
	$raycast.target_position = target_dir * 4000
	if $raycast.is_colliding():
		$line.points[1] = to_local($raycast.get_collision_point())
		$hurtbox/CollisionShape2D.shape.size.y = position.distance_to($raycast.get_collision_point())
		$hurtbox/CollisionShape2D.position.y = $hurtbox/CollisionShape2D.shape.size.y * 0.5
		$hurtbox.look_at($raycast.get_collision_point())
		$hurtbox.rotation_degrees -= 90
		if particle_cd > 0:
			particle_cd -= 1
		else:
			ParticleSystem.new_explosion("res://prefabs/particles/particle_melon_juice.tscn", $raycast.get_collision_point(), 12, -PI, PI, -target_dir)
			particle_cd = 4
