extends Resource
class_name WeaponResource

@export_enum("melee", "throwable", "seeds", "grappling_hook") var weapon_type = "melee"
@export var texture : Texture
@export var default_rot : float = 0.0
@export var sprite_offset : Vector2 = Vector2(0, 0)
@export var melee_damage : int = 0
@export var seed_id : String
@export var projectile_path : String
