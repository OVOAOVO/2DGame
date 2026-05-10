extends Area2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area):
	if area.is_in_group("Enemy"):
		print("Enemy碰到玩家了")