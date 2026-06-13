extends Node2D

#@export_file("*.tscn") var next_level: String
@export var load_scene: StringName = &""
@export var play_button: Button
@export var area: Area2D

func _ready():
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
	if area:
		area.body_entered.connect(_on_body_entered)

func _on_play_button_pressed() -> void:
	if load_scene.is_empty():
		printerr("LevelManager: load_scene 未设置，无法加载场景")
		return
	scene_loader.load_scene(load_scene)

func _on_body_entered(body):
	if load_scene.is_empty():
		printerr("LevelManager: load_scene 未设置，无法加载场景")
		return
	scene_loader.load_scene(load_scene)
