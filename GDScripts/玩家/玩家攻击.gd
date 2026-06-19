extends Area2D

signal play_AttackAnim()

@export var knock_force := 400.0

## 攻击配置：攻击名(String) → { "frame_to_shape": { 帧号(int) → NodePath } }
## NodePath 在编辑器中拖入 CollisionShape2D 节点作为软引用
@export var attack_config: Dictionary = {
	"attack_1": {
		"frame_to_shape": { 4: NodePath("") }
	}
}

var hit_list := []
var current_attack: String = ""

var owner_stats: Stats

func _ready():
	_disable_all_shapes()


func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		current_attack = "attack_1"
		emit_signal("play_AttackAnim")


func start_attack():
	hit_list.clear()


func end_attack():
	_disable_shapes_by_key(current_attack)
	current_attack = ""


## 获取当前攻击的所有检测帧（供动画脚本查询）
func get_hit_frames() -> Array:
	var cfg = attack_config.get(current_attack, {})
	var frame_to_shape: Dictionary = cfg.get("frame_to_shape", {})
	return frame_to_shape.keys()


## 由动画在检测帧调用，只对当前帧对应的形状做命中检测
func do_hit_check_at_frame():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.is_in_group("Enemy") and area not in hit_list:
			hit_list.append(area)
			print("HitedAnim")
			var damage = owner_stats.current_attack
			area.hitted.emit(damage, knock_force, global_position)


## 在检测帧的前一帧调用，提前开启碰撞形状
func enable_collision_for_frame(frame: int):
	_disable_shapes_by_key(current_attack)  # 先关掉其他的

	var cfg = attack_config.get(current_attack, {})
	var frame_to_shape: Dictionary = cfg.get("frame_to_shape", {})
	var path: NodePath = frame_to_shape.get(frame, NodePath(""))

	if path and not path.is_empty():
		var shape = get_node(path) as CollisionShape2D
		if shape:
			shape.disabled = false


func _disable_shapes_by_key(attack_key: String):
	var cfg = attack_config.get(attack_key, {})
	var frame_to_shape: Dictionary = cfg.get("frame_to_shape", {})
	for path in frame_to_shape.values():
		if path and not path.is_empty():
			var shape = get_node(path) as CollisionShape2D
			if shape:
				shape.disabled = true


func _disable_all_shapes():
	for cfg in attack_config.values():
		var frame_to_shape: Dictionary = cfg.get("frame_to_shape", {})
		for path in frame_to_shape.values():
			if path and not path.is_empty():
				var shape = get_node(path) as CollisionShape2D
				if shape:
					shape.disabled = true
