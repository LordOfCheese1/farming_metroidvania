extends StaticBody2D

@export var is_opened = false


func _ready():
	if is_opened:
		$sprite.position.y = -170
	else:
		$sprite.position.y = 0


func _process(_delta):
	$CollisionShape2D.disabled = is_opened


func open():
	$anim.play("open")
	is_opened = true


func close():
	$anim.play("close")
	is_opened = false
