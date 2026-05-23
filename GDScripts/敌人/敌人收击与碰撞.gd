extends Area2D

enum State {
	MOVE,
	HIT
}

@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var state = State.MOVE

signal hitted(damage, knock_force, hit_pos)

func _ready() -> void:

	# 玩家碰撞（CharacterBody2D / RigidBody2D）
	body_entered.connect(_on_body_entered)

	# 另一个 Area2D 碰撞（比如攻击盒）
	# area_entered.connect(_on_area_entered)
	
	hitted.connect(_on_hitted)

func _on_body_entered(body):
	if body.name == "Player":
		print("guaaa")

func _on_hitted(damage, force, hit_pos):
	if state == State.HIT:
		return

	state = State.HIT
	timer.paused = true
	animated_sprite_2d.speed_scale = 0


	# 扣血前
	var old_health = get_parent().stats.health
	# 计算伤害
	var final_damage = max(
		1,
		damage - get_parent().stats.current_defense
	)
	get_parent().stats.health -= final_damage
	var new_health = get_parent().stats.health
	print(
	"敌人受到伤害: ",
	final_damage,
	" | HP: ",
	old_health,
	" -> ",
	new_health
	)

	# 死亡判断
	if get_parent().stats.health <= 0:
		# 播放死亡动画
		print("敌人死亡")
		get_parent().queue_free()
		return

	# 计算击退方向和力度
	var dir = (global_position - hit_pos).normalized()
	dir.y = 0
	dir = dir.normalized()
	get_parent().position += dir * force * 0.1

	state = State.MOVE
	animated_sprite_2d.speed_scale = 1
	timer.paused = false
