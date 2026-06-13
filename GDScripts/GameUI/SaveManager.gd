# SaveManager.gd (Autoload)
extends Node

var save: SaveGameAsResource
var has_save: bool = false  ## 用来显示隐藏菜单

signal save_loaded
signal save_changed

func _enter_tree():
	init()
	
func init():
	# 有存档 覆盖
	if SaveGameAsResource.save_exists():
		save = SaveGameAsResource.load_savegame()
		has_save = true
	# 没有存档 创建一个默认存档
	else:
		save = SaveGameAsResource.new()
		has_save = false
		save.inventory.add_item("healing_gem", 5)
		save.inventory.add_item("sword", 1)
		save.player_stats.setup_stats() # 初始初始化
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