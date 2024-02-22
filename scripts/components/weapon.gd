extends Node2D

@export var weapon_resource : WeaponResource
var melee_attack_cd = 0
var current_weapon_index = 0
var weapons_available = { # filename : quantity, -1 is infite
	"shovel" : -1,
	"seeds_carrot" : 5,
	"seeds_melon" : 10,
	"carrot" : 10,
	"melon" : 10
}
signal melee_used
signal throw_used


func _process(_delta):
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
	if Input.is_action_just_pressed("scroll_down"):
		cycle_weapons(1)


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
		if weapons_available[weapons_available.keys()[current_weapon_index]] == 0:
			cycle_weapons(1)
		interface_update()


func melee_attack():
	$hurtbox.damage = weapon_resource.melee_damage
	melee_attack_cd = 12


func throw_attack():
	if Globals.gameplay_scene_active:
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


func interface_update():
	if Globals.gameplay_scene_active:
		var display_sprite = get_tree().current_scene.get_node("user_interface/weapon/sprite")
		display_sprite.texture = weapon_resource.texture
		if weapons_available[weapons_available.keys()[current_weapon_index]] > 0:
			get_tree().current_scene.get_node("user_interface/weapon/amount_display").text = str(weapons_available[weapons_available.keys()[current_weapon_index]])
		else:
			get_tree().current_scene.get_node("user_interface/weapon/amount_display").text = "Infinite"
