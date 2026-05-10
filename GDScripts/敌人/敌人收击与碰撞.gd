extends Area2D

func _ready() -> void:

	# 玩家碰撞（CharacterBody2D / RigidBody2D）
	body_entered.connect(_on_body_entered)

	# 另一个 Area2D 碰撞（比如攻击盒）
	# area_entered.connect(_on_area_entered)


func _on_body_entered(body):
	if body.name == "Player":
		print("guaaa")

# func _on_area_entered(other_area):
#		print("敌人被攻击了")
