extends Node

## ============================================================
## DropManager —— 掉落拾取管理器（全局单例）
## ============================================================
## 用法：
##   # 方式1：传 PackedScene
##   DropManager.drop(preload("res://items/coin.tscn"), global_position)
##
##   # 方式2：传资源路径
##   DropManager.drop_at_path("res://items/coin.tscn", global_position)
##
##   # 方式3：指定挂载父节点
##   DropManager.drop(scene, pos, get_tree().current_scene)
## ============================================================

const PickupableScript := preload("res://addons/dropandpickup/pickupable.gd")


func _ready() -> void:
	_ensure_interact_action()


## 掉落物品（传入 PackedScene）
## [item_scene] 物品场景资源
## [position]   世界坐标
## [parent]     挂载父节点（默认 current_scene）
## 返回实例化的节点
func drop(item_scene: PackedScene, position: Vector2, parent: Node = null) -> Node:
	if not item_scene:
		push_error("DropManager.drop(): item_scene 为空")
		return null

	var instance := item_scene.instantiate()

	if instance is Node2D:
		instance.position = position
	elif instance is Control:
		instance.position = position

	if not parent:
		parent = get_tree().current_scene
	if not parent:
		push_error("DropManager.drop(): 无有效父节点")
		instance.queue_free()
		return null

	parent.add_child(instance)

	# 确保物品有 Pickupable 组件
	_ensure_pickupable(instance)

	return instance


## 掉落物品（传入资源路径字符串）
func drop_at_path(item_path: String, position: Vector2, parent: Node = null) -> Node:
	if not ResourceLoader.exists(item_path):
		push_error("DropManager.drop_at_path(): 资源不存在 —— " + item_path)
		return null

	var scene := load(item_path) as PackedScene
	if not scene:
		push_error("DropManager.drop_at_path(): 无法作为 PackedScene 加载 —— " + item_path)
		return null

	return drop(scene, position, parent)


## 掉落物品（传入 ItemData .tres 资源）
## [item_data] 物品数据资源（如 preload("res://items/sword.tres")）
## [position]   世界坐标
## [parent]     挂载父节点（默认 current_scene）
## 返回实例化的节点
func drop_item(item_data: ItemData, position: Vector2, scale := Vector2(2, 2), parent: Node = null) -> Node:
	if not item_data:
		push_error("DropManager.drop_item(): item_data 为空")
		return null

	if not item_data.unique_id or item_data.unique_id.is_empty():
		push_error("DropManager.drop_item(): item_data.unique_id 为空")
		return null

	# 动态构建掉落物节点
	var root := Node2D.new()
	root.name = item_data.display_name
	root.position = position

	# 显示物品图标
	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = item_data.icon
	sprite.scale = scale
	root.add_child(sprite)

	# 拾取组件（携带物品数据）
	var pickup := PickupableScript.new()
	pickup.name = "Pickupable"
	pickup.item_data = item_data
	pickup.prompt_text = "按 E 拾取 " + item_data.display_name
	root.add_child(pickup)

	if not parent:
		parent = get_tree().current_scene
	if not parent:
		push_error("DropManager.drop_item(): 无有效父节点")
		root.queue_free()
		return null

	parent.add_child(root)
	return root


## 确保目标节点树中有 Pickupable 组件，没有则自动添加
func _ensure_pickupable(target: Node) -> void:
	if _find_pickupable(target) != null:
		return

	var pickup := PickupableScript.new()
	pickup.name = "Pickupable"
	target.add_child(pickup)


## 递归查找 Pickupable（含自身）
func _find_pickupable(node: Node) -> Node:
	if node.script == PickupableScript:
		return node
	for child in node.get_children():
		var found := _find_pickupable(child)
		if found:
			return found
	return null


## 如果没有 "interact" 输入动作，自动注册（默认绑定 E 键）
func _ensure_interact_action() -> void:
	if InputMap.has_action(&"interact"):
		return

	InputMap.add_action(&"interact")
	var ev := InputEventKey.new()
	ev.keycode = KEY_E
	InputMap.action_add_event(&"interact", ev)
	print("[DropManager] 已自动注册 'interact' 输入动作 → 绑定 E 键")
