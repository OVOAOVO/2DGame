extends Area2D

signal touch_enemy
signal hit_knockback(knock_dir: Vector2, force: float)

@export var knock_force := 400.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area):
	if area.is_in_group("Enemy"):
		_do_knockback(area.global_position, knock_force)


## 外部调用：从指定位置击退玩家
func apply_knockback(from_pos: Vector2, force: float = 0.0) -> void:
	if force <= 0.0:
		force = knock_force
	_do_knockback(from_pos, force)


func _do_knockback(from_pos: Vector2, force: float) -> void:
	print("Enemy碰到玩家了")
	emit_signal("touch_enemy")
	var dir = (global_position - from_pos).normalized()
	emit_signal("hit_knockback", dir, force)