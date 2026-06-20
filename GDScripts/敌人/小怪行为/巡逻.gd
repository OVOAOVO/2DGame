@tool
extends ActionLeaf

## 巡逻移动速度
@export var speed: float = 100.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var delta = get_physics_process_delta_time()
	
	# 从黑板读取方向（初始方向由 _ready() 根据 face_right 设置）
	var direction: float = blackboard.get_value("patrol_direction")
	
	# 从黑板读取 _ready() 时存入的节点引用（避免每帧 get_node_or_null）
	var ray_wall = blackboard.get_value("ray_wall", null)
	var ray_edge = blackboard.get_value("ray_edge", null)
	var sprite = blackboard.get_value("sprite", null)
	
	var should_turn = false
	
	if ray_wall is RayCast2D:
		ray_wall.target_position.x = abs(ray_wall.target_position.x) * direction
		ray_wall.force_raycast_update()
		if ray_wall.is_colliding():
			should_turn = true
	
	if ray_edge is RayCast2D:
		ray_edge.target_position.x = abs(ray_edge.target_position.x) * direction
		ray_edge.force_raycast_update()
		if not ray_edge.is_colliding():
			should_turn = true
	
	if should_turn:
		direction *= -1.0
		if sprite is AnimatedSprite2D:
			sprite.flip_h = !sprite.flip_h
	
	# 移动角色
	actor.position.x += direction * speed * delta
	
	# 保存方向回黑板
	blackboard.set_value("patrol_direction", direction)
	
	return SUCCESS