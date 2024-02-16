extends "res://scripts/base_classes/entity.gd"

var accel : float= 0.35
var speed : float = 300.0
var jump_strength : float = 600.0
var x_dir = 1


func _ready():
	add_to_group("player")
	entity_setup()


func _physics_process(delta):
	var user_input = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	if user_input.x != 0:
		x_dir = user_input.x / abs(user_input.x)
	
	if velocity.y < GRAVITY:
		velocity.y += GRAVITY * delta
	
	velocity.x = lerp(velocity.x, user_input.x * speed, accel)
	
	if is_on_floor():
		speed = 300.0
		accel = 0.35
		if Input.is_action_just_pressed("jump"):
			jump()
	else:
		speed = 350.0
		accel = 0.1
		if velocity.y < 0:
			if Input.is_action_just_released("jump"):
				velocity.y = velocity.y / 2
	
	move_and_slide()
	
	if Input.is_action_pressed("test"):
		position = get_global_mouse_position()


func _process(_delta):
	$debug_velocity.set_point_position(1, velocity * 0.5)
	$debug_velocity/label.text = str(Vector2i(snapped(velocity.x, 1.0), snapped(velocity.y, 1.0)))


func jump():
	velocity.y = -jump_strength
	if abs(velocity.x) / speed > 0.3:
		velocity.x = x_dir * 350.0