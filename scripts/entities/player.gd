extends "res://scripts/base_classes/entity.gd"

var accel : float= 0.35
var speed : float = 320.0
var jump_strength : float = 650.0
var x_dir = 1
var is_jumping : float = 0.0
var hand_attack_rot : float = 0.0
var has_released_jump = false
var delayed_velocity = Vector2(0, 0)
var is_near_npc = false
var user_input = Vector2(0, 0)
var weapon = null
var dust_particle_cd = 0
var prev_pos = Vector2(0, 0)
var is_grappling = false
var has_done_grapple_hit = false
var footstep_cd = 0

var jump_sfx = preload("res://audio/sfx/player_jump.mp3")
var footstep_sfx = preload("res://audio/sfx/player_footstep.mp3")
@export var dust_particle : PackedScene


func _ready():
	add_to_group("player")
	entity_setup()
	$interact_text.text = DialogueManager.modify_text($interact_text.text)
	$interact_text.parse_bbcode(DialogueManager.modify_text($interact_text.text))
	weapon = $visuals/arm_right/weapon


func _physics_process(delta):
	prev_pos = global_position
	if Globals.freeze_player_movement:
		user_input = Vector2(0.0, 0.0)
	
	if user_input.x != 0:
		x_dir = user_input.x / abs(user_input.x)
	
	if velocity.y < GRAVITY && !Globals.freeze_player_movement:
		velocity.y += GRAVITY * delta
	
	velocity.x = lerp(velocity.x, user_input.x * speed, accel)
	
	if is_on_floor():
		is_grappling = false
		has_released_jump = true
		speed = 320.0
		accel = 0.35
		if Input.is_action_just_pressed("jump") && !Globals.freeze_player_movement:
			jump()
	else:
		speed = 360.0
		if is_grappling && abs(velocity.x) > speed:
			accel = 0.0
		else:
			accel = 0.1
		if velocity.y < 0 && !has_released_jump:
			if Input.is_action_just_released("jump") && !Globals.freeze_player_movement:
				has_released_jump = true
				velocity.y = velocity.y / 2
	
	move_and_slide()
	
	if hp > 0:
		$visuals/arm_right.look_at(get_global_mouse_position())
		$visuals/arm_right.rotation_degrees = $visuals/arm_right.rotation_degrees - 45 + hand_attack_rot
	
	if is_jumping > 0:
		is_jumping -= delta
	
	hand_attack_rot = lerp(hand_attack_rot, 0.0, 0.1)
	Globals.player_pos = position
	Globals.player_max_health = max_hp
	Globals.player_health = hp
	
	if Globals.added_player_velocity != Vector2(0, 0):
		delayed_velocity += Globals.added_player_velocity
		Globals.added_player_velocity = Vector2(0, 0)
	velocity += delayed_velocity
	delayed_velocity = Vector2(0, 0)
	
	
	if is_on_floor():
		if abs(velocity.x) > speed * 0.5:
			if dust_particle_cd > 0:
				dust_particle_cd -= 1
			else:
				if abs(global_position.y - prev_pos.y) < 3:
					ParticleSystem.new_particle(dust_particle, global_position + Vector2(0, 63), -x_dir * 0.1)
					dust_particle_cd = 4
			if footstep_cd > 0:
				footstep_cd -= 1
			else:
				footstep_cd = 15
				SoundManager.new_sound(footstep_sfx, randf_range(0.9, 1.1))
	
	if abs(velocity.x) > speed * 2:
		if !has_done_grapple_hit:
			$grapple_hurtbox/CollisionShape2D.disabled = false
			$grapple_hurtbox.damage = snapped(abs(velocity.x) / (speed * 1.5), 0.2)
			has_done_grapple_hit = true
		else:
			$grapple_hurtbox/CollisionShape2D.disabled = true
		$hitbox.immunity = $hitbox.max_immunity
	else:
		$grapple_hurtbox/CollisionShape2D.disabled = true
	
	if Globals.reset_health:
		Globals.reset_health = false
		hp = max_hp
		Globals.player_health = hp
		Globals.freeze_player_movement = false


func _process(_delta):
	user_input = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump") && !Globals.freeze_player_movement:
			jump()
	else:
		if velocity.y < 0 && !has_released_jump:
			if Input.is_action_just_released("jump") && !Globals.freeze_player_movement:
				has_released_jump = true
				velocity.y *= 0.5
	
	$interact_text.visible = is_near_npc 
	$debug_velocity.set_point_position(1, velocity * 0.5)
	$debug_velocity/label.text = str(Vector2i(snapped(velocity.x, 1.0), snapped(velocity.y, 1.0)))
	
	if hp > 0:
		$hitbox/CollisionShape2D.disabled = false
		$visuals/arm_right/weapon.show()
		if is_on_floor():
			if abs(velocity.x) > speed * 0.25:
				$anim.play("walk")
			else:
				$anim.play("idle")
		else:
			if is_jumping <= 0:
				$anim.play("fall")
	else:
		$hitbox/CollisionShape2D.disabled = true
		$visuals/arm_right/weapon.hide()
		velocity.y = 1
		if $visuals.modulate.a > 0.5:
			$anim.play("death")
	
	if get_global_mouse_position().x - position.x != 0 && hp > 0:
		$visuals.scale.x = (get_global_mouse_position().x - position.x) / abs((get_global_mouse_position().x - position.x))


func start_death():
	get_tree().current_scene.player_death()


func jump():
	SoundManager.new_sound(jump_sfx, randf_range(0.9, 1.1))
	$anim.play("jump")
	has_released_jump = false
	is_jumping = 0.5
	velocity.y = -jump_strength
	if abs(velocity.x) / speed > 0.3:
		velocity.x = x_dir * 350.0


func save_weapons():
	SaveManager.save_data["weapons"] = $visuals/arm_right/weapon.weapons_available


func _on_weapon_melee_used():
	hand_attack_rot = 110.0


func _on_weapon_throw_used():
	hand_attack_rot = -40


func _on_hitbox_hit():
	if Globals.gameplay_scene_active:
		get_tree().current_scene.player_hit()
