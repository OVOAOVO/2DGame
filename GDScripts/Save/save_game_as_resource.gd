class_name SaveGameAsResource
extends Resource

const SAVE_GAME_BASE_PATH := "user://save"

@export var version := 1
@export var inventory := Inventory.new()

func write_savegame() -> void:
	ResourceSaver.save(self, get_save_path())


static func save_exists() -> bool:
	return ResourceLoader.exists(get_save_path())


static func load_savegame() -> Resource:
	var save_path := get_save_path()
	return ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_IGNORE)


# This function allows us to save and load a text resource in debug builds and a
# binary resource in the released product.
static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return SAVE_GAME_BASE_PATH + extension