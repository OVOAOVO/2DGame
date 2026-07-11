extends Area2D

## Boss 受击 + 玩家碰撞

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

signal hitted(damage, knock_force, hit_pos)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	hitted.connect(_on_hitted)

	add_to_group("Enemy")
	#print("[Boss] Area2D 已就绪, 已加入 Enemy 组")


func _on_body_entered(body):
	#print("[Boss] body_entered: ", body.name, " (type: ", body.get_class(), ")")
	if body.name == "Player":
		print("[Boss] 碰到玩家!")


func _on_area_entered(area):
	#print("[Boss] area_entered: ", area.name, " (type: ", area.get_class(), ")")
	if area.is_in_group("player_attack"):
		#print("[Boss] 被玩家攻击盒命中!")
		var damage: int = area.get_meta("damage", 10)
		var knock_force: float = area.get_meta("knock_force", 100.0)
		var hit_pos: Vector2 = area.global_position
		print("[Boss] 伤害:%d  击退力:%.1f  命中位置:%s" % [damage, knock_force, hit_pos])
		hitted.emit(damage, knock_force, hit_pos)


func _on_hitted(damage, force, hit_pos):
	print("[Boss] _on_hitted 触发! damage:%d force:%.1f" % [damage, force])

	# 计算伤害
	var old_health = get_parent().stats.health
	var final_damage = max(1, damage - get_parent().stats.current_defense)
	get_parent().stats.health -= final_damage
	var new_health = get_parent().stats.health
	print("[Boss] 受到伤害: ", final_damage, " | HP: ", old_health, " -> ", new_health)

	# 死亡判断
	if get_parent().stats.health <= 0:
		#print("[Boss] 死亡!")
		var player_stats = SaveManager.save.player_stats
		player_stats.experience += 5000
		#print("[Boss] 玩家获得经验: 5000 | 等级: ", player_stats.level)
		get_parent().queue_free()
		return

	# 击退
	var dir = (global_position - hit_pos).normalized()
	dir.y = 0
	dir = dir.normalized()
	get_parent().position += dir * force * 0.03
	#print("[Boss] 击退: dir=%s  dist=%.1f" % [dir, force * 0.03])
