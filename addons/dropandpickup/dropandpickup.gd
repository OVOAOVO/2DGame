@tool
extends EditorPlugin


func _enable_plugin() -> void:
	add_autoload_singleton("DropManager", "res://addons/dropandpickup/drop_manager.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton("DropManager")


func _enter_tree() -> void:
	pass


func _exit_tree() -> void:
	pass
