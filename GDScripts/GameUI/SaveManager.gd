# SaveManager.gd (Autoload)
extends Node

var save: SaveGameAsResource
const CURRENT_VERSION = 2

signal save_loaded
signal save_changed

func _enter_tree():
	init()
	
func init():
	# 有存档 覆盖
	if SaveGameAsResource.save_exists():
		save = SaveGameAsResource.load_savegame()
		_upgrade_save()
	# 没有存档 创建一个默认存档
	else:
		save = SaveGameAsResource.new()
		save.inventory.add_item("healing_gem", 5)
		save.inventory.add_item("sword", 1)
		save.player_stats.setup_stats() # 初始初始化
		save.write_savegame()

	save_loaded.emit()
	print("SaveManager init")

func save_game():
	save.write_savegame()
	save_changed.emit()

func _upgrade_save():
	if save.version < 2:
		print("检测到旧存档版本1，创建默认玩家属性")
		if save.player_stats == null:
			save.player_stats = Stats.new()
			save.player_stats.setup_stats()

		save.version = 2

		save.write_savegame()