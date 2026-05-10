extends Area2D

signal touch_enemy

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area):
	if area.is_in_group("Enemy"):
		print("Enemy碰到玩家了")
		emit_signal("touch_enemy")