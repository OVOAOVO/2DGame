extends AnimatedSprite2D

func _ready():
	get_parent().connect("move_state_changed", _on_move_state_changed)


func _on_move_state_changed(is_run, is_jump, is_fall, velocity, dir):

	if is_jump:
		play("Jump")
	elif is_fall:
		play("Fall")
	elif is_run:
		play("Run")
	else:
		play("Idle")

	# 直接用自己
	if dir != 0:
		flip_h = dir < 0