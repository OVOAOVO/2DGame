extends AnimatedSprite2D

var is_hitting = false

func _ready():
	get_parent().connect("move_state_changed", _on_move_state_changed)
	get_parent().get_node("Area2D").touch_enemy.connect(_on_touch_enemy)

func _on_move_state_changed(is_run, is_jump, is_fall, dir):

	if is_hitting:
		return

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

func _on_touch_enemy():
	print("收到 hit 信号")
	is_hitting = true
	play("Touch_Enemy")
	await animation_finished
	is_hitting = false