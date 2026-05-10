extends Node2D

@onready var area = $Area2D
@onready var timer: Timer = $Area2D/Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $Area2D/AnimatedSprite2D

const  SPEED = 100.0
var direction = -1.0

# 👉 新增：初始是否面向右
@export var face_right: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if timer == null:
		print("Timer is NULLL!")
		return
	if animated_sprite_2d == null:
		print("AnimatedSprite2D is NULLL!")
		return
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
	# 根据初始朝向设置 direction 和 flip
	if face_right:
		direction = -1.0
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
	else:
		direction = 1.0
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h

func _process(delta):
	position.x += direction * SPEED * delta

func _on_timer_timeout():
	direction *= -1   # 方向反转
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
