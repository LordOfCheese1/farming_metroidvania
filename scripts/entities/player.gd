extends "res://scripts/base_classes/entity.gd"

var accel = 0.35
var speed = 300.0
var jump_strength = 600.0


func _ready():
	add_to_group("player")
	entity_setup()


func _physics_process(delta):
	var user_input = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	
	if velocity.y < GRAVITY:
		velocity.y += GRAVITY * delta
	
	velocity.x = lerp(velocity.x, user_input.x * speed, accel)
	
	if is_on_floor():
		accel = 0.35
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_strength
	else:
		accel = 0.1
		if velocity.y < 0:
			if Input.is_action_just_released("jump"):
				velocity.y = velocity.y / 2
	
	move_and_slide()
	
	if Input.is_action_pressed("test"):
		position = get_global_mouse_position()


func _process(_delta):
	$debug_velocity.set_point_position(1, velocity * 0.5)
