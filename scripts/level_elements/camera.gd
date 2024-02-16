extends Camera2D


@export var follow_path : NodePath
var smoothing = 0.3


func _physics_process(_delta):
	zoom = lerp(zoom, Vector2(1.0, 1.0), 0.2)
	var follow = get_node_or_null(follow_path)
	if follow != null:
		position = lerp(position, follow.position + follow.velocity * 0.1, smoothing)


func set_boundaries(left : int, right : int, up : int, down : int):
	limit_left = left
	limit_right = right
	limit_top = up
	limit_bottom = down
