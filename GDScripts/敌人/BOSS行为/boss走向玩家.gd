@tool
extends ActionLeaf

## Boss 移动速度
@export var speed: float = 150.0


func tick(actor: Node, blackboard: Blackboard) -> int:
	var delta = get_physics_process_delta_time()

	# 获取玩家节点
	var player = _find_player(actor)
	if player == null:
		return FAILURE

	# 从黑板获取精灵引用
	var sprite = blackboard.get_value("sprite", null)

	# 计算朝向玩家的方向
	var to_player_x = player.global_position.x - actor.global_position.x
	var direction: float = 1.0 if to_player_x > 0 else -1.0

	# Boss 始终走向玩家，播放 walk 动画
	if sprite is AnimatedSprite2D:
		if sprite.animation != "Walk":
			sprite.play("Walk")
		sprite.flip_h = direction > 0

	actor.position.x += direction * speed * delta

	# 保存方向到黑板
	blackboard.set_value("patrol_direction", direction)

	return SUCCESS


func _find_player(actor: Node) -> Node:
	# 玩家和 Boss 在同一关卡场景中，都是场景根节点的子节点
	var player = actor.get_parent().get_node_or_null("Player")
	if player:
		return player

	# 备选：从 current_scene 查找
	player = actor.get_tree().current_scene.get_node_or_null("Player")
	return player
