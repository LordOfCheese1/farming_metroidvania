extends Node2D

@export var weapon_resource : WeaponResource
@export var grapple_hook : PackedScene
var melee_attack_cd = 0
var current_weapon_index = 0
var active_grapple_hook = null
var weapons_available = { # filename : quantity, -1 is infite
	"shovel" : -1,
	"seeds_carrot" : 5,
	"seeds_melon" : 0,
	"seeds_banana" : 0,
	"carrot" : 0,
	"melon" : 0,
	"banana" : 0
}
signal melee_used
signal throw_used
@export var throw_sfx : AudioStream
@export var melee_sfx : AudioStream
@export var weapon_cycle_sfx : AudioStream
@export var grapple_out : AudioStream


func _process(_delta):
	if Globals.update_weapons:
		Globals.update_weapons = false
		for i in weapons_available.keys():
			weapons_available[i] = SaveManager.save_data["weapons"][i]
	
	if weapon_resource != null:
		$sprite.texture = weapon_resource.texture
		$sprite.rotation_degrees = weapon_resource.default_rot
		$sprite.offset = weapon_resource.sprite_offset
	else:
		$sprite.texture = null
		$sprite.rotation_degrees = 0.0
		$sprite.offset = Vector2(0, 0)
	
	if Input.is_action_just_pressed("scroll_up"):
		cycle_weapons(-1)
		SoundManager.new_sound(weapon_cycle_sfx)
	if Input.is_action_just_pressed("scroll_down"):
		cycle_weapons(1)
		SoundManager.new_sound(weapon_cycle_sfx)


func _physics_process(_delta):
	if melee_attack_cd > 0:
		melee_attack_cd -= 1
		$hurtbox/CollisionShape2D.disabled = false
	else:
		$hurtbox/CollisionShape2D.disabled = true
		if Input.is_action_just_pressed("action") && !Globals.freeze_player_movement:
			use()
	$trail.modulate.a = melee_attack_cd / 12.0


func use():
	if weapon_resource != null:
		match weapon_resource.weapon_type:
			"melee":
				melee_attack()
				emit_signal("melee_used")
			"throwable":
				throw_attack()
				emit_signal("throw_used")
			"seeds":
				use_seeds()
			"grappling_hook":
				grapple()
		if weapons_available[weapons_available.keys()[current_weapon_index]] == 0:
			
			print(weapons_available.keys()[current_weapon_index])
			cycle_weapons(1)
		interface_update()


func melee_attack():
	$hurtbox.damage = weapon_resource.melee_damage
	melee_attack_cd = 12
	SoundManager.new_sound(melee_sfx, randf_range(0.8, 1.0))


func throw_attack():
	if Globals.gameplay_scene_active:
		SoundManager.new_sound(throw_sfx)
		var projectile = load(weapon_resource.projectile_path).instantiate()
		projectile.velocity = Vector2(get_global_mouse_position() - global_position).normalized()
		projectile.position = global_position
		get_tree().current_scene.get_node("active_room").get_child(0).get_node("projectiles").call_deferred("add_child", projectile)
		weapons_available[weapons_available.keys()[current_weapon_index]] -= 1


func use_seeds():
	if len(FarmManager.plants_in_proximity) > 0:
		if FarmManager.plants_in_proximity[0].id == "":
			FarmManager.plant_a_plant(weapon_resource.seed_id)
			weapons_available[weapons_available.keys()[current_weapon_index]] -= 1


func grapple():
	if active_grapple_hook == null:
		SoundManager.new_sound(grapple_out)
		var grapple_hook_inst = grapple_hook.instantiate()
		grapple_hook_inst.position = global_position
		grapple_hook_inst.orig_node = self
		grapple_hook_inst.look_at(get_global_mouse_position())
		active_grapple_hook = grapple_hook_inst
		get_tree().current_scene.get_node("active_room").get_child(0).get_node("projectiles").call_deferred("add_child", grapple_hook_inst)
	else:
		active_grapple_hook.perish()
		weapons_available[weapons_available.keys()[current_weapon_index]] -= 1


func cycle_weapons(dir : int):
	current_weapon_index += dir
	if current_weapon_index > len(weapons_available) - 1:
		current_weapon_index = 0
	if current_weapon_index < 0:
		current_weapon_index = len(weapons_available) - 1
	if weapons_available[weapons_available.keys()[current_weapon_index]] != 0:
		weapon_resource = load("res://resources/weapons/" + weapons_available.keys()[current_weapon_index] + ".tres")
		interface_update()
	else:
		cycle_weapons(dir)
	if active_grapple_hook != null:
		active_grapple_hook.perish()


func interface_update():
	if Globals.gameplay_scene_active:
		var display_sprite = get_tree().current_scene.get_node("user_interface/weapon/sprite")
		display_sprite.texture = weapon_resource.texture
		if weapons_available[weapons_available.keys()[current_weapon_index]] > 0:
			get_tree().current_scene.get_node("user_interface/weapon/amount_display").text = str(weapons_available[weapons_available.keys()[current_weapon_index]])
		else:
			get_tree().current_scene.get_node("user_interface/weapon/amount_display").text = "Infinite"
