extends Area2D

@export var is_parry_emitter = false
@export var damage : float
@export var ignore_in_detection = []
@export var ignore_tag = ""
@export var give_iframes_to_hitbox_on_parry : NodePath
signal has_hit
signal has_been_parried
var parry_sound = load("res://audio/sfx/parry.wav")


func _ready():
	add_to_group("hurtbox")


func ignore(tag_to_be_ignored : String):
	ignore_in_detection.append(tag_to_be_ignored)


func _on_area_entered(area):
	if area.is_in_group("hurtbox"):
		if !ignore_in_detection.has(area.ignore_tag):
			parry(area)


func parry(opposing_hurtbox):
	# are you a parry emitter and the opposing hurtbox isn't?
	if is_parry_emitter && !opposing_hurtbox.is_parry_emitter:
		print("parry - " + str(opposing_hurtbox.damage * 1.5) + " dmg")
		# do the parry effect
		opposing_hurtbox.emit_signal("has_been_parried")
		emit_signal("has_hit")
		VisualScreenEffects.parry_flash_effect()
		if Globals.gameplay_scene_active:
			get_tree().current_scene.get_node("camera").zoom = Vector2(1.3, 1.3)
		Globals.pause_for(8)
		SoundManager.new_sound(parry_sound)
		# add iframes to this entity's hitbox so they can't take damage during the parry
		var iframe_hitbox = get_node_or_null(give_iframes_to_hitbox_on_parry)
		if iframe_hitbox != null:
			iframe_hitbox.immunity = iframe_hitbox.max_immunity
		# look for a hitbox to give damage to on the opposing hurtbox
		var hitbox = look_for_hitbox(opposing_hurtbox)
		if hitbox != null:
			get_node(hitbox.entity).last_hit_from = global_position
			hitbox.trigger_external_hit(opposing_hurtbox.damage * 1.5)
		else: # check if opposing hurtbox belongs to a projectile if no hitbox is found
			if opposing_hurtbox.get_parent().is_in_group("projectile"):
				opposing_hurtbox.get_parent().velocity *= -1
				opposing_hurtbox.damage *= 1.5


func look_for_hitbox(hurtbox):
	var hitbox = null
	for i in hurtbox.get_parent().get_children():
		if i.is_in_group("hitbox"):
			hitbox = i
			break
	return hitbox
