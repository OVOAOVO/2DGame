class_name Pickupable
extends Area2D

## ============================================================
## Pickupable —— 拾取组件
## ============================================================
## 放在物品 TSCN 中即可让物品可被拾取。
## 也可由 DropManager 在 spawn 时自动添加。
##
## 使用方式：
##   1. 在物品 TSCN 中直接添加 Pickupable 节点（推荐，可自定义碰撞）
##   2. 或者什么都不做，DropManager.spawn() 会自动补上
##
## 信号：
##   picked_up    物品被拾取时发出
## ============================================================

## 拾取时发出的信号（携带自身引用）
signal picked_up

## 此掉落物对应的物品数据（.tres 资源，拾取后加入背包）
@export var item_data: ItemData = null

## 提示文本
@export var prompt_text: String = "按 E 拾取"
## 拾取后是否自动 queue_free
@export var auto_free: bool = true
## 自动创建碰撞体时的半径
@export var pickup_radius: float = 32.0
## 提示文本 Y 轴偏移（相对于物品位置）
@export var prompt_offset: Vector2 = Vector2(-30, -40)

var _player_nearby: bool = false
var _label: Label


func _ready() -> void:
	# 确保有碰撞体
	if not _has_collision_shape():
		_create_default_collision()

	# 默认碰撞层：检测 Player 层（layer 2）
	if collision_mask == 1:  # 未配置过的默认值
		collision_mask = 2

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# 创建提示 Label
	_label = Label.new()
	_label.name = "PickupPrompt"
	_label.text = prompt_text
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 13)
	_label.modulate = Color(0, 0, 0, 0.9)
	_label.visible = false
	_label.position = prompt_offset
	add_child(_label)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_nearby:
		return
	if event.is_action_pressed(&"interact"):
		_pick_up()
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"Player"):
		_player_nearby = true
		if _label:
			_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"Player"):
		_player_nearby = false
		if _label:
			_label.visible = false


func _pick_up() -> void:
	picked_up.emit()

	# 如果有物品数据，加入玩家背包
	if item_data:
		SaveManager.save.inventory.add_item(item_data.unique_id)
		print("[Pickupable] 拾取: %s → 背包" % item_data.display_name)

	if auto_free:
		# 释放父节点（物品本体），而非仅释放 Pickupable 自己
		get_parent().queue_free()


func _has_collision_shape() -> bool:
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			return true
	return false


func _create_default_collision() -> void:
	var shape := CollisionShape2D.new()
	shape.name = "PickupShape"
	var circle := CircleShape2D.new()
	circle.radius = pickup_radius
	shape.shape = circle
	add_child(shape)
