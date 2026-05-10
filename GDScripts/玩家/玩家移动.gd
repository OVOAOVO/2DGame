extends CharacterBody2D

@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -850.0

signal move_state_changed(is_running, is_jumping, is_falling, velocity, direction)

func _physics_process(delta):

	var direction = Input.get_axis("left", "right")

	# 移动
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 跳
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 重力
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

	# 👉 把状态丢出去
	emit_signal("move_state_changed",
		abs(velocity.x) > 1,
		velocity.y < 0,
		velocity.y > 0 and not is_on_floor(),
		velocity,
		direction
	)