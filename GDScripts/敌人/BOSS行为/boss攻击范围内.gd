@tool
extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	# 从黑板读取 RayCastEye 节点引用（在 Boss.gd 的 _ready() 中存入）
	var ray_eye = blackboard.get_value("ray_eye", null)

	# 从黑板读取当前朝向（与 boss走向玩家 共享 patrol_direction）
	var direction: float = blackboard.get_value("patrol_direction", 1.0)

	if not ray_eye is RayCast2D:
		return FAILURE

	# 根据朝向动态调整射线方向
	ray_eye.position.x = abs(ray_eye.position.x) * direction
	ray_eye.target_position.x = abs(ray_eye.target_position.x) * direction
	ray_eye.force_raycast_update()

	# 检测是否碰撞到玩家（玩家在 collision_layer 2）
	if ray_eye.is_colliding():
		var collider = ray_eye.get_collider()
		if collider is CollisionObject2D and (collider.collision_layer & 2):
			return SUCCESS

	return FAILURE
