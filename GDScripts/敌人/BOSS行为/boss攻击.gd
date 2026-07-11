@tool
extends ActionLeaf

## 攻击击退力度
@export var attack_knock_force := 500.0

var _player: Node = null
var _player_hurtbox: Area2D = null


func tick(actor: Node, blackboard: Blackboard) -> int:
	var sprite = blackboard.get_value("sprite", null)

	if sprite is AnimatedSprite2D:
		# 如果当前不是攻击动画，开始播放
		if sprite.animation != "Attack":
			sprite.play("Attack")
			# 缓存玩家引用
			_cache_player(actor)

		# 动画还在播 → 每帧检测 overlap 并击退
		if sprite.is_playing():
			_check_hit(actor)
			return RUNNING
		else:
			sprite.play("Idle")
			return SUCCESS

	return FAILURE


func _cache_player(actor: Node) -> void:
	_player = actor.get_parent().get_node_or_null("Player")
	if not _player:
		_player = actor.get_tree().current_scene.get_node_or_null("Player")
	if _player:
		_player_hurtbox = _player.get_node_or_null("HurtBox")


func _check_hit(actor: Node) -> void:
	if not _player or not _player_hurtbox:
		return

	var area = actor.get_node_or_null("Area2D")
	if not area:
		return

	# 每帧检查玩家身体是否在 Boss 碰撞区域内
	for body in area.get_overlapping_bodies():
		if body == _player:
			if _player_hurtbox.has_method("apply_knockback"):
				_player_hurtbox.apply_knockback(actor.global_position, attack_knock_force)
			return
