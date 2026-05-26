# SaveManager.gd (Autoload)
extends Node

var save: SaveGameAsResource

signal save_loaded
signal save_changed

func init():
	# 有存档 覆盖
	if SaveGameAsResource.save_exists():
		save = SaveGameAsResource.load_savegame()
	
	# 没有存档 创建一个默认存档
	else:
		save = SaveGameAsResource.new()
		save.inventory.add_item("healing_gem", 5)
		save.inventory.add_item("sword", 1)
		save.write_savegame()

	save_loaded.emit()

func save_game():
	save.write_savegame()
	save_changed.emit()