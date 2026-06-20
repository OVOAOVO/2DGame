extends CharacterBody2D

@export var stats: Stats

@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -850.0

signal move_state_changed(is_running, is_jumping, is_falling, velocity, direction)

@onready var hurtbox = $HurtBox
@onready var attack_box = $AttackBox
var curfacing := 1

var knockback := Vector2.ZERO
var knock_time := 0.0

func _on_knockback(dir: Vector2, force: float):
	knockback = dir * force
	knock_time = 0.15

func _ready():
	hurtbox.hit_knockback.connect(_on_knockback)
	stats = SaveManager.save.player_stats
	print("玩家加载成功，血量: ", stats.health, "/", stats.current_max_health)
	attack_box.owner_stats = stats

func _physics_process(delta):
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		curfacing = sign(direction)
	attack_box.position.x = abs(attack_box.position.x) * curfacing

	if knock_time > 0:
		velocity = knockback
		knock_time -= delta
	else:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		if not is_on_floor():
			velocity += get_gravity() * delta

	move_and_slide()

	emit_signal("move_state_changed",
		abs(velocity.x) > 1,
		velocity.y < 0,
		velocity.y > 0 and not is_on_floor(),
		direction
	)