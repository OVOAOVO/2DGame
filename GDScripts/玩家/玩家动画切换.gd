extends AnimatedSprite2D

enum AnimState {
	NORMAL,
	TOUCHED_ENEMY,
	ATTACK
}

var anim_state = AnimState.NORMAL

var attack_box: Node

func _ready():
	get_parent().connect("move_state_changed", _on_move_state_changed)
	get_parent().get_node("HurtBox").touch_enemy.connect(_on_touch_enemy)
	attack_box = get_parent().get_node("AttackBox")
	attack_box.play_AttackAnim.connect(_on_attack)
	frame_changed.connect(_on_frame_changed)

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

	# 通知攻击盒子启用对应状态的碰撞形状
	attack_box.start_attack()

	play("Attack")

	await animation_finished

	attack_box.end_attack()
	anim_state = AnimState.NORMAL


# 监听动画帧变化
func _on_frame_changed():
	if anim_state != AnimState.ATTACK:
		return

	var hit_frames: Array = attack_box.get_hit_frames()
	if hit_frames.is_empty():
		return

	# 检测帧的前一帧 → 提前开启碰撞
	if frame + 1 in hit_frames:
		attack_box.enable_collision_for_frame(frame + 1)
	# 检测帧 → 只做命中检测（碰撞已在上帧开启）
	elif frame in hit_frames:
		attack_box.do_hit_check_at_frame()