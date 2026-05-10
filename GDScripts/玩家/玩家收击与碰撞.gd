extends Area2D

signal touch_enemy
signal hit_knockback(knock_dir: Vector2, force: float)

@export var knock_force := 400.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area):
	if area.is_in_group("Enemy"):
		print("Enemy碰到玩家了")
		emit_signal("touch_enemy")
		# 新信号（击退）
		var dir = (global_position - area.global_position).normalized()
		emit_signal("hit_knockback", dir, knock_force)