@tool
extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var sprite = blackboard.get_value("sprite", null)

	if sprite is AnimatedSprite2D:
		# 如果当前不是攻击动画，开始播放
		if sprite.animation != "Attack":
			sprite.play("Attack")

		# 动画还在播 → RUNNING
		if sprite.is_playing():
			return RUNNING
		else:
			# 动画播完一轮 → 切回 Idle，返回 SUCCESS 让行为树重新判断
			sprite.play("Idle")
			return SUCCESS

	return FAILURE
