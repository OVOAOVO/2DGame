extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var health := 0 : set = set_health


func _ready():
	timer.timeout.connect(_on_timer_timeout)


func setup(max_health: int, current_health: int):
	max_value = max_health

	damage_bar.max_value = max_health

	value = current_health
	damage_bar.value = current_health

	health = current_health


func set_health(new_health: int):

	var prev_health := health

	health = clampi(new_health, 0, int(max_value))

	value = health

	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health


func set_max_health(new_max: int):

	var health_percent := 0.0

	if max_value > 0:
		health_percent = float(health) / max_value

	max_value = new_max
	damage_bar.max_value = new_max

	health = int(new_max * health_percent)

	value = health
	damage_bar.value = health


func update_health(cur_health: int, max_health: int):

	if max_value != max_health:
		set_max_health(max_health)

	set_health(cur_health)


func _on_timer_timeout():
	damage_bar.value = health