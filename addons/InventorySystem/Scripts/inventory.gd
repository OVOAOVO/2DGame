class_name Inventory
extends Resource

@export var items: Array[ItemStack] = []

func add_item(item_id: String, quantity: int = 1) -> void:
	print("ADD ITEM CALLED", item_id)
	for item_stack in items:
		if item_stack.unique_id == item_id:
			item_stack.amount += quantity
			emit_changed()
			return
	var new_stack = ItemStack.new(item_id, quantity)
	items.append(new_stack)
	emit_changed()

func get_amount(item_unique_id: String) -> int:
	for item_stack in items:
		if item_stack.unique_id == item_unique_id:
			return item_stack.amount
	printerr("Trying to get the amount of item %s but the inventory doesn't have it." % item_unique_id)
	return 0

func remove_item(item_unique_id: String, amount := 1) -> void:
	for item_stack in items:
		if item_stack.unique_id == item_unique_id:
			item_stack.amount -= amount
			if item_stack.amount <= 0:
				items.erase(item_stack)
			emit_changed()
			return
	printerr("Trying to remove item %s but the inventory doesn't have it." % item_unique_id)

func has_item(item_unique_id: String) -> bool:
	for item_stack in items:
		if item_stack.unique_id == item_unique_id:
			return true
	return false