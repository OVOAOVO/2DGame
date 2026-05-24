extends Node2D

var _save := SaveGameAsResource.new()

@onready var _save_panel: Panel = %SavePanel
@onready var _inventory_panel: Panel = %InventoryPanel

func _ready() -> void:
	_save_panel.reload_requested.connect(_create_or_load_save)
	_save_panel.save_requested.connect(_save_game)

	_create_or_load_save()

func _create_or_load_save() -> void:
	if SaveGameAsResource.save_exists():
		_save = SaveGameAsResource.load_savegame()
	else:
		_save = SaveGameAsResource.new()
		_save.inventory.add_item("healing_gem", 5)
		_save.inventory.add_item("sword", 1)

		_save.write_savegame()

	_inventory_panel.inventory = _save.inventory
		
func _save_game() -> void:
	_save.write_savegame()
