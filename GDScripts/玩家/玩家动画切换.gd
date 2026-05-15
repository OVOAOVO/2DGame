extends AnimatedSprite2D

enum AnimState {
	NORMAL,
	TOUCHED_ENEMY,
	ATTACK
}

var anim_state = AnimState.NORMAL

func _ready():
	get_parent().connect("move_state_changed", _on_move_state_changed)
	get_parent().get_node("HurtBox").touch_enemy.connect(_on_touch_enemy)
	get_parent().get_node("AttackBox").connect("play_AttackAnim", _on_attack)

func _on_move_state_changed(is_run, is_jump, is_fall, dir):

	# 特殊动画锁
	if anim_state != AnimState.NORMAL:
		return

	if is_jump:
		play("Jump")
	elif is_fall:
		play("Fall")
	elif is_run:
		play("Run")
	else:
		play("Idle")

	if dir != 0:
		flip_h = dir < 0


func _on_touch_enemy():

	# 已经在受击了就别重复播
	if anim_state == AnimState.TOUCHED_ENEMY:
		return

	anim_state = AnimState.TOUCHED_ENEMY

	play("Touch_Enemy")

	await animation_finished

	anim_state = AnimState.NORMAL

func _on_attack():

	if anim_state != AnimState.NORMAL:
		return

	anim_state = AnimState.ATTACK
	play("Attack")

	await animation_finished
	anim_state = AnimState.NORMAL
