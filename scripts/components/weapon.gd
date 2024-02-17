extends Node2D

@export var weapon_resource : WeaponResource
var melee_attack_cd = 0
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


func _physics_process(_delta):
	if melee_attack_cd > 0:
		melee_attack_cd -= 1
		$hurtbox/CollisionShape2D.disabled = false
	else:
		$hurtbox/CollisionShape2D.disabled = true
		if Input.is_action_just_pressed("action"):
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


func melee_attack():
	melee_attack_cd = 12


func throw_attack():
	pass
