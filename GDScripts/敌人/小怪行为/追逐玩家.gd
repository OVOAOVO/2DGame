@tool
extends ActionLeaf

## 追逐移动速度（巡逻的两倍）
@export var speed: float = 200.0


func tick(actor: Node, blackboard: Blackboard) -> int:
	var delta = get_physics_process_delta_time()
	
	var direction: float = blackboard.get_value("patrol_direction")
	
	var ray_wall = blackboard.get_value("ray_wall", null)
	var ray_edge = blackboard.get_value("ray_edge", null)
	var sprite = blackboard.get_value("sprite", null)
	
	var should_turn = false
	
	if ray_wall is RayCast2D:
		ray_wall.position.x = abs(ray_wall.position.x) * direction
		ray_wall.target_position.x = abs(ray_wall.target_position.x) * direction
		ray_wall.force_raycast_update()
		if ray_wall.is_colliding():
			should_turn = true
	
	if ray_edge is RayCast2D:
		ray_edge.position.x = abs(ray_edge.position.x) * direction
		ray_edge.target_position.x = abs(ray_edge.target_position.x) * direction
		ray_edge.force_raycast_update()
		if not ray_edge.is_colliding():
			should_turn = true
	
	if should_turn:
		direction *= -1.0
		if sprite is AnimatedSprite2D:
			sprite.flip_h = !sprite.flip_h
	
	actor.position.x += direction * speed * delta
	
	blackboard.set_value("patrol_direction", direction)
	
	return SUCCESS