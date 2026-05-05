extends Area2D

@onready var timer: Timer = get_node("Timer")
@onready var animated_sprite_2d: AnimatedSprite2D = get_node("AnimatedSprite2D")

const  SPEED = 100.0
var direction = -1.0

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

func _process(delta):
	position.x += direction * SPEED * delta

func _on_timer_timeout():
	direction *= -1   # 方向反转
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h