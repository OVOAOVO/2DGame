@tool
extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	# 从黑板读取 RayCastEye 节点引用（在 小怪.gd 的 _ready() 中存入）
	var ray_eye = blackboard.get_value("ray_eye", null)
	
	# 从黑板读取当前朝向（与巡逻共享 patrol_direction，确保射线方向和精灵朝向一致）
	var direction: float = blackboard.get_value("patrol_direction", 1.0)
	
	if not ray_eye is RayCast2D:
		return FAILURE
	
	# 根据朝向动态调整射线方向，确保总是往脸朝向的方向检测
	ray_eye.position.x = abs(ray_eye.position.x) * direction
	ray_eye.target_position.x = abs(ray_eye.target_position.x) * direction
	ray_eye.force_raycast_update()
	
	# 检测是否碰撞到玩家（玩家在 collision_layer 2）
	# 确保 RayCastEye 的 collision_mask 只勾选第 2 层，避免误碰 TileMap 等
	if ray_eye.is_colliding():
		var collider = ray_eye.get_collider()
		if collider is CollisionObject2D and (collider.collision_layer & 2):
			return SUCCESS
	
	return FAILURE
