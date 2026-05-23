extends Area2D

signal play_AttackAnim

@export var knock_force := 400.0
@export var attack_duration := 0.15

var attacking := false
var attack_time_left := 0.0

var hit_list := []

# 这个属性用来让攻击盒子知道它属于哪个角色，从而访问角色的 stats属性
var owner_stats: Stats

func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		start_attack()


func start_attack():
	if attacking:
		return

	attacking = true
	attack_time_left = attack_duration
	hit_list.clear()

	emit_signal("play_AttackAnim")


func _physics_process(delta):
	if not attacking:
		return

	attack_time_left -= delta

	_do_hit_check()

	if attack_time_left <= 0:
		attacking = false

func _do_hit_check():
	var areas = get_overlapping_areas()

	for area in areas:
		if area.is_in_group("Enemy") and area not in hit_list:
			hit_list.append(area)
			print("HitedAnim")
			var damage = owner_stats.current_attack
			area.hitted.emit(damage, knock_force, global_position)