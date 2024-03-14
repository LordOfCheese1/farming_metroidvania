extends "res://scripts/base_classes/entity.gd"

var time = 0.0
var is_attacking = 0
var attack_cd = 0
@export var spit_scene : PackedScene
@export var am_i_allowed_to_do_this = true


func _ready():
	entity_setup()


func _physics_process(delta):
	var player_in_proximity = abs(Globals.player_pos.x - position.x) < 640 && abs(Globals.player_pos.y - position.y) < 160
	
	velocity.y += GRAVITY * delta
	if is_attacking <= 0:
		time += delta
		velocity.x = sin(time) * 200
		$sprite.flip_h = velocity.x < 0
		$anim.play("move")
		if player_in_proximity:
			if attack_cd > 0:
				attack_cd -= 1
			else:
				if am_i_allowed_to_do_this:
					attack_cd = 50
					is_attacking = 60
					$anim.play("spit")
	else:
		velocity.x = 0
		is_attacking -= 1
	
	move_and_slide()


func emit_spit():
	var spit = spit_scene.instantiate()
	var position_offset = Vector2(90, -15)
	if $sprite.flip_h == true:
		position_offset.x = -position_offset.x
	spit.position = global_position + position_offset
	spit.velocity.x = (Globals.player_pos.x - position.x) * 0.8 - position_offset.x
	get_parent().get_parent().get_node("projectiles").call_deferred("add_child", spit)


func _on_hitbox_hit():
	if hp <= 0:
		call_deferred("free")
