# “背包里的一格物品数据”
# 物品ID
# 有多少个
class_name ItemStack
extends Resource

@export var unique_id := ""
@export var amount := 1

func _init(id := "", quantity := 1) -> void:
	unique_id = id
	amount = quantity