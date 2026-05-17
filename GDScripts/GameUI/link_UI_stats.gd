extends Control

@onready var health_bar = $HealthBar

var stats: Stats


func _ready():

	stats = get_parent().stats

	stats.health_changed.connect(_on_health_changed)

	health_bar.setup(
		stats.current_max_health,
		stats.health
	)


func _on_health_changed(cur_health: int, max_health: int):

	health_bar.update_health(
		cur_health,
		max_health
	)
