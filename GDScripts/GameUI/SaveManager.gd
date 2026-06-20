# SaveManager.gd (Autoload)
extends Node

## 玩家属性的模板 .tres（创建新存档时从此复制 base_* 初始值）
## preload 确保导出时资源被打包，玩家首次运行即可使用
const STATS_TEMPLATE := preload("res://Prefab/玩家属性.tres")

var save: SaveGameAsResource
var has_save: bool = false  ## 用来显示隐藏菜单

signal save_loaded
signal save_changed

func _enter_tree():
	init()
	
func init():
	# 有存档 → 直接加载
	if SaveGameAsResource.save_exists():
		save = SaveGameAsResource.load_savegame()
		has_save = true
	# 没有存档 → 从模板创建新存档
	else:
		save = SaveGameAsResource.new()
		has_save = false

		#.tres 模板复制所有 base_* 属性，你的数值调整在这一个文件里生效
		save.player_stats.copy_base_from(STATS_TEMPLATE)

		save.inventory.add_item("healing_gem", 5)
		save.inventory.add_item("sword", 1)
		save.player_stats.setup_stats() # 用 base_* 重算 current_* 并满血
		save.write_savegame()

	save_loaded.emit()
	print("SaveManager init")

func save_game():
	# scene_loader 是 autoload，scene_path 记录了最后一次加载的场景路径，这里直接保存到存档里，确保下次继续游戏能从这个场景开始
	save.current_level = scene_loader.scene_path
	save.write_savegame()
	print("[SaveManager] 已保存，地图: ", save.current_level)
	has_save = true
	save_changed.emit()

func load_last_level():
	"""加载存档中记录的地图，无存档时加载主场景"""
	var level_path: String = save.current_level if save else ""
	if level_path.is_empty():
		level_path = ProjectSettings.get_setting("application/run/main_scene")
	print("[SaveManager] load_last_level → 路径: ", level_path)
	if not level_path.is_empty() and ResourceLoader.exists(level_path):
		scene_loader.load_scene(level_path)
	else:
		printerr("[SaveManager] 无法加载地图，路径无效: ", level_path, " 文件是否存在: ", ResourceLoader.exists(level_path))