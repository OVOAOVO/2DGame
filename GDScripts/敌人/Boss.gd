extends Node2D

@export var stats: Stats

@onready var area = $Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var blackboard: Blackboard = $Blackboard

# 初始是否面向右
@export var face_right: bool = false


func _ready() -> void:
	if animated_sprite_2d == null:
		print("[Boss] AnimatedSprite2D is NULL!")
		return
	if blackboard == null:
		print("[Boss] Blackboard is NULL!")
		return

	# 把行为树需要的节点引用一次性存入黑板，避免每帧 get_node_or_null
	blackboard.set_value("ray_eye", get_node_or_null("RayCastEye"))
	blackboard.set_value("sprite", animated_sprite_2d)

	# 设置初始方向（正=右，负=左），与 face_right 一致
	var initial_dir: float = -1.0
	if face_right:
		initial_dir = 1.0
	blackboard.set_value("patrol_direction", initial_dir)
