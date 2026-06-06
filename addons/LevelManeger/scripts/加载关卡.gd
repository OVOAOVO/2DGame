extends Node2D

#@export_file("*.tscn") var next_level: String
@export var initial_scene: StringName = &""
@export var play_button: Button
@export var area: Area2D

func _ready():
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
	if area:
		area.body_entered.connect(_on_body_entered)

func _on_play_button_pressed() -> void:
	scene_loader.load_scene(initial_scene)

func _on_body_entered(body):
	#if next_level != "":
	#   get_tree().call_deferred("change_scene_to_file", next_level)
	scene_loader.load_scene(initial_scene)
