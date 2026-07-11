@tool
class_name CollisionGen
extends Node

## ============================================================
## CollisionGen —— 一键从 AnimatedSprite2D 帧生成碰撞多边形
## ============================================================
## 挂到 Area2D（或任意节点）上，指向 AnimatedSprite2D，
## 点击按钮即生成 {动画名}_frame{帧号} 格式的 CollisionPolygon2D。
## ============================================================

@export_group("目标")
## 指向 AnimatedSprite2D 的路径（不填则自动查找第一个同级 AnimatedSprite2D）
@export var sprite_path: NodePath:
	set(v):
		sprite_path = v
		update_configuration_warnings()

@export_group("参数")
## 多边形简化精度 (px)，越大顶点越少、精度越低
@export_range(0.5, 10.0, 0.5) var epsilon: float = 2.0

## alpha 通道阈值，低于此值视为透明
@export_range(0.0, 1.0, 0.05) var alpha_threshold: float = 0.1

## 只取最大轮廓（true）还是保留所有分离的轮廓（false）
@export var largest_only: bool = true

## 清洗多边形时去除共线点的角度容差（度），越小保留越多顶点
@export_range(0.1, 10.0, 0.1) var colinear_tolerance: float = 1.0

## 缩小纹理再处理的比例，0.5=半分辨率，大幅提升性能且更稳定
@export_range(0.25, 1.0, 0.25) var scale_down: float = 1.0

@export_group("操作")
## 勾选即生成（完成后自动回弹）
@export var 生成碰撞: bool = false:
	set(v):
		if v:
			生成碰撞 = false
			generate()


## ---- 公共 API（可从代码调用）----

func generate() -> int:
	"""执行生成，返回生成的碰撞体数量"""
	var sprite := _resolve_sprite()
	if not sprite:
		return 0

	var sprite_frames := sprite.sprite_frames
	if not sprite_frames or sprite_frames.get_animation_names().is_empty():
		push_warning("SpriteFrames 为空或没有动画")
		return 0

	var target := _resolve_target(sprite)
	if not target:
		return 0

	_remove_generated(target)

	var total := 0
	var scene_root := _scene_root()

	for anim_name: String in sprite_frames.get_animation_names():
		for frame_idx: int in range(sprite_frames.get_frame_count(anim_name)):
			var texture := sprite_frames.get_frame_texture(anim_name, frame_idx)
			if not texture:
				continue

			var image := texture.get_image()
			if image.is_empty():
				continue

			# 可选缩小纹理，减少噪点让轮廓更干净
			if scale_down < 1.0:
				var new_w := maxi(8, int(image.get_width() * scale_down))
				var new_h := maxi(8, int(image.get_height() * scale_down))
				image.resize(new_w, new_h, Image.INTERPOLATE_LANCZOS)

			var bitmap := BitMap.new()
			bitmap.create_from_image_alpha(image, alpha_threshold)

			var polys: Array[PackedVector2Array] = bitmap.opaque_to_polygons(
				Rect2(Vector2.ZERO, image.get_size()),
				epsilon
			)
			if polys.is_empty():
				print("⚠ 无有效像素: %s_frame%d" % [anim_name, frame_idx])
				continue

			var best := _pick(polys, largest_only)

			# 偏移回原始坐标（如果做了缩放）
			var scale_ratio := 1.0 / scale_down
			var offset := -image.get_size() * scale_ratio / 2.0
			for j in best.size():
				best[j] = best[j] * scale_ratio + offset

			# ---- 清洗多边形，防止 convex decomposition 失败 ----
			best = _sanitize_polygon(best)

			if best.size() < 3:
				print("⚠ 清洗后顶点不足: %s_frame%d (原有 %d 顶点)" % [anim_name, frame_idx, polys[0].size()])
				continue

			var col := CollisionPolygon2D.new()
			col.name = "%s_frame%d" % [anim_name, frame_idx]
			col.polygon = best
			col.disabled = true
			col.visible = false

			target.add_child(col)
			if scene_root:
				col.owner = scene_root

			total += 1

	print("✅ CollisionGen: 生成 %d 个碰撞多边形" % total)
	return total


## ---- 内部 ----

func _resolve_sprite() -> AnimatedSprite2D:
	if sprite_path:
		var n := get_node_or_null(sprite_path)
		if n is AnimatedSprite2D:
			return n
		push_error("sprite_path 不是 AnimatedSprite2D")
		return null

	# 自动查找
	var candidates: Array[Node] = []
	for c in get_parent().get_children():
		if c is AnimatedSprite2D:
			candidates.append(c)
	if candidates.size() == 1:
		return candidates[0]
	if candidates.size() > 1:
		push_error("找到 %d 个 AnimatedSprite2D，请手动设置 sprite_path" % candidates.size())
	else:
		push_error("找不到 AnimatedSprite2D，请设置 sprite_path")
	return null


func _resolve_target(p_sprite: AnimatedSprite2D) -> Node:
	if get_parent() is CollisionObject2D:
		return get_parent()
	return p_sprite.get_parent()


func _remove_generated(target: Node) -> void:
	for c in target.get_children():
		if c is CollisionPolygon2D and "_frame" in c.name:
			c.queue_free()


func _pick(polys: Array[PackedVector2Array], single: bool) -> PackedVector2Array:
	var best := polys[0]
	for i in range(1, polys.size()):
		if polys[i].size() > best.size():
			best = polys[i]
	return best


## 清洗多边形：去重、去共线、修正绕序
func _sanitize_polygon(poly: PackedVector2Array) -> PackedVector2Array:
	if poly.size() < 3:
		return poly

	# --- 1. 去除重复/过近的连续顶点 ---
	const MIN_DIST := 0.3
	var step1 := PackedVector2Array()
	for i in poly.size():
		var curr := poly[i]
		var prev := poly[i - 1] if i > 0 else poly[poly.size() - 1]
		if i == 0 or curr.distance_squared_to(prev) > MIN_DIST * MIN_DIST:
			step1.append(curr)
	if step1.size() < 3:
		return step1

	# --- 2. 去除近似共线的中间顶点 ---
	#     三个点几乎在一条直线上时，中间那个对碰撞没贡献
	var tolerance_rad := deg_to_rad(colinear_tolerance)
	var step2 := PackedVector2Array()
	step2.append(step1[0])
	for i in range(1, step1.size() - 1):
		var a := step1[i - 1]
		var b := step1[i]
		var c := step1[i + 1]
		var ba := (a - b).normalized()
		var bc := (c - b).normalized()
		var angle := ba.angle_to(bc)  # 以 b 为顶点的角度
		if abs(angle) > tolerance_rad:  # 不够直 → 保留这个拐点
			step2.append(b)
	step2.append(step1[step1.size() - 1])

	if step2.size() < 3:
		return step2

	# --- 3. 确保顺时针（Godot 2D 物理期望的绕序） ---
	if not Geometry2D.is_polygon_clockwise(step2):
		step2.reverse()

	return step2


func _scene_root() -> Node:
	if Engine.is_editor_hint():
		return get_tree().edited_scene_root if get_tree() else null
	return get_tree().current_scene


func get_configuration_warnings() -> PackedStringArray:
	var w: PackedStringArray = []
	if not sprite_path:
		var found := false
		for c in get_parent().get_children():
			if c is AnimatedSprite2D:
				found = true
				break
		if not found:
			w.append("找不到 AnimatedSprite2D，请设置 sprite_path")
	return w
