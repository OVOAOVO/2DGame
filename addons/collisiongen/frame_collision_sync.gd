@tool
class_name FrameCollisionSync
extends Node

## ============================================================
## FrameCollisionSync —— 动画帧 ↔ 碰撞多边形自动同步
## ============================================================
## 配合 CollisionGen 使用。
## 当 AnimatedSprite2D 切换帧时，自动启用对应命名规则
## ({动画名}_frame{帧号}) 的 CollisionPolygon2D。
##
## === 公共接口 ===
##   enable()            开启自动同步
##   disable()           关闭自动同步（碰撞全禁用）
##   sync_now()          立即同步到当前帧
##   rebuild()           重建碰撞索引（CollisionGen 生成完新碰撞后调用）
##   get_current()       返回当前启用的 CollisionPolygon2D（无则 null）
##   is_syncing()        当前是否在同步中
##   get_lookup_table()  返回内部索引表 {anim: [col0, col1, ...]}
## ============================================================

## 指向 AnimatedSprite2D（不填自动查找同级）
@export var animated_sprite: NodePath:
	set(v):
		animated_sprite = v
		update_configuration_warnings()

## 是否在 _ready 时自动开始同步
@export var auto_start: bool = true

## 调试输出：每次切换帧时打印当前动画、帧号、碰撞体名称
@export var debug_print: bool = true

# ---- 私有 ----
var _sprite: AnimatedSprite2D
var _lookup: Dictionary = {}
var _all_collisions: Array[CollisionPolygon2D] = []
var _active: bool = false
var _ready_done: bool = false


func _ready() -> void:
	_ready_done = true
	_sprite = _resolve_sprite()
	rebuild()
	if auto_start and _sprite:
		enable()


func _exit_tree() -> void:
	if _sprite and _sprite.frame_changed.is_connected(_on_frame_changed):
		_sprite.frame_changed.disconnect(_on_frame_changed)
		_sprite.animation_changed.disconnect(_on_animation_changed)


# ============================================================
#  公共接口
# ============================================================

func enable() -> void:
	"""开启自动同步，同时立刻同步当前帧"""
	if not _sprite:
		push_warning("FrameCollisionSync: 未找到 AnimatedSprite2D，无法启用")
		return
	if not _sprite.frame_changed.is_connected(_on_frame_changed):
		_sprite.frame_changed.connect(_on_frame_changed)
		_sprite.animation_changed.connect(_on_animation_changed)
	_active = true

	if debug_print:
		print("─".repeat(50))
		print("[FrameCollisionSync] 同步已开启")
		print("[FrameCollisionSync] 索引: %d 个动画, 共 %d 个碰撞体" % [_lookup.size(), _all_collisions.size()])
		for anim_name: String in _lookup:
			print("    %-16s -> %2d 帧" % [anim_name, _lookup[anim_name].size()])
		print("─".repeat(50))

	_sync(_sprite.animation, _sprite.frame)


func disable() -> void:
	"""关闭自动同步，禁用所有碰撞体"""
	_active = false
	if _sprite:
		if _sprite.frame_changed.is_connected(_on_frame_changed):
			_sprite.frame_changed.disconnect(_on_frame_changed)
			_sprite.animation_changed.disconnect(_on_animation_changed)
	for col in _all_collisions:
		col.disabled = true
		col.visible = false


func sync_now() -> void:
	"""手动触发一次同步（即使 auto_sync 关闭也能用）"""
	if not _sprite:
		return
	_sync(_sprite.animation, _sprite.frame)


func rebuild() -> void:
	"""重建碰撞索引表。CollisionGen 生成新碰撞后需调用此方法。"""
	_lookup.clear()
	_all_collisions.clear()

	var source := get_parent()
	if not source:
		return

	for child in source.get_children():
		if not child is CollisionPolygon2D:
			continue
		if not "_frame" in child.name:
			continue

		# 从 "idle_frame3" 解析出 anim="idle", idx=3
		var slices := child.name.get_slice_count("_frame")
		if slices < 2:
			continue
		var idx_str := child.name.get_slice("_frame", slices - 1)
		if not idx_str.is_valid_int():
			continue
		var anim := child.name.trim_suffix("_frame" + idx_str)
		var idx := idx_str.to_int()

		if not _lookup.has(anim):
			_lookup[anim] = []
		_lookup[anim].append([idx, child])
		_all_collisions.append(child as CollisionPolygon2D)

	# 按帧号排序
	for anim: String in _lookup:
		var pairs: Array = _lookup[anim]
		pairs.sort_custom(func(a, b): return a[0] < b[0])
		var sorted: Array[CollisionPolygon2D] = []
		for pair in pairs:
			sorted.append(pair[1])
		_lookup[anim] = sorted

	# 如果已经激活，刷新当前帧
	if _active and _sprite:
		_sync(_sprite.animation, _sprite.frame)


func get_current() -> CollisionPolygon2D:
	"""返回当前启用的碰撞体，没有则返回 null"""
	if not _sprite:
		return null
	var anim_str: String = _sprite.animation
	var cols: Array = _lookup.get(anim_str, [])
	if cols and _sprite.frame < cols.size():
		return cols[_sprite.frame]
	return null


func is_syncing() -> bool:
	return _active


func get_lookup_table() -> Dictionary:
	return _lookup.duplicate()


# ============================================================
#  内部
# ============================================================

func _resolve_sprite() -> AnimatedSprite2D:
	if animated_sprite and not animated_sprite.is_empty():
		var n := get_node_or_null(animated_sprite)
		if n is AnimatedSprite2D:
			return n

	# 自动找同级
	for c in get_parent().get_children():
		if c is AnimatedSprite2D:
			return c
	return null


func _on_frame_changed() -> void:
	if not _active:
		return
	_sync(_sprite.animation, _sprite.frame)


func _on_animation_changed() -> void:
	if not _active:
		return
	_sync(_sprite.animation, _sprite.frame)


func _sync(anim: StringName, frame: int) -> void:
	for col in _all_collisions:
		col.disabled = true
		col.visible = false

	# StringName -> String，确保和 rebuild() 里用 child.name (String) 存的键一致
	var anim_str: String = anim
	var cols: Array = _lookup.get(anim_str, [])
	if frame < cols.size():
		var target: CollisionPolygon2D = cols[frame]
		target.disabled = false
		if Engine.is_editor_hint():
			target.visible = true

		if debug_print:
			print("[FrameCollisionSync] 动画:%-16s  帧:%2d  ->  碰撞: %s" % [anim_str, frame, target.name])
	elif debug_print:
		print("[FrameCollisionSync] 动画:%-16s  帧:%2d  ->  [缺失] lookup 中 %s 有 %d 帧，请求第 %d 帧" % [anim_str, frame, anim_str, cols.size(), frame])


func get_configuration_warnings() -> PackedStringArray:
	var w: PackedStringArray = []
	if not animated_sprite or animated_sprite.is_empty():
		var found := false
		for c in get_parent().get_children():
			if c is AnimatedSprite2D:
				found = true
				break
		if not found:
			w.append("找不到 AnimatedSprite2D，请设置 animated_sprite 路径")
	return w
