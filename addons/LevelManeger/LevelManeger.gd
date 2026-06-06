@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_autoload_singleton("scene_loader", "res://addons/LevelManeger/scripts/scene_loader.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("scene_loader")

