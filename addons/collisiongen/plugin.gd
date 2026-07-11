@tool
extends EditorPlugin

## 注册 FrameCollisionSync 为自定义节点，让它出现在 "添加节点" 对话框里

func _enter_tree() -> void:
	add_custom_type(
		"FrameCollisionSync",
		"Node",
		preload("res://addons/collisiongen/frame_collision_sync.gd"),
		preload("res://addons/collisiongen/icon_frame_sync.svg")
	)
	add_custom_type(
		"CollisionGen",
		"Node",
		preload("res://addons/collisiongen/collision_gen.gd"),
		preload("res://addons/collisiongen/icon_collision_gen.svg")
	)


func _exit_tree() -> void:
	remove_custom_type("FrameCollisionSync")
	remove_custom_type("CollisionGen")
