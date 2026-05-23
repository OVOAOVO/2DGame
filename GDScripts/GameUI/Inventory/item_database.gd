extends Node

var ITEMS: Dictionary[String, ItemData] = {}

func _ready() -> void:
	var items := _load_items()
	for item in items:
		ITEMS[item.unique_id] = item

func get_item_data(uniqueid: String) -> ItemData:
	if not uniqueid in ITEMS:
		printerr("Trying to get item data for %s but it doesn't exist in the database." % uniqueid)
		return null
	return ITEMS[uniqueid]

static func _load_items() -> Array[ItemData]:
	var item_files = []
	var items_folder := "res://Prefab/UI/GameUI/Inventory/items/"

	var directory := DirAccess.open(items_folder)
	if not directory:
		print_debug('Could not open directory "%s"' % [items_folder])
		return item_files

	directory.list_dir_begin()
	var file_name = directory.get_next()
	while file_name != "":
		if file_name.get_extension() == "tres":
			item_files.append(items_folder.path_join(file_name))
		file_name = directory.get_next()
	
	var item_resources: Array[ItemData] = []
	for path in item_files:
		item_resources.append(load(path))

	# Here we ensure that each loaded item has valid data in debug builds.
	if OS.is_debug_build():
		var ids := []
		var bad_items := []
		for item in item_resources:
			if item.unique_id in ids:
				bad_items.append(item)
			else:
				ids.append(item.unique_id)
		for item in bad_items:
			printerr("Item %s has a non-unique ID: %s" % [item.display_name, item.unique_id])

	return item_resources
	
