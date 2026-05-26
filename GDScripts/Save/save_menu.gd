extends Node2D

@onready var _save_panel: Panel = %SavePanel
@onready var _inventory_panel: Panel = %InventoryPanel

var _menu_open := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	await get_tree().process_frame

	SaveManager.init()

	_save_panel.reload_requested.connect(_on_reload)
	_save_panel.save_requested.connect(_on_save)
	SaveManager.save_loaded.connect(_on_save_loaded)

	# UI始终可响应输入（只设一次）
	_save_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_inventory_panel.process_mode = Node.PROCESS_MODE_ALWAYS

	_set_menu(false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		_toggle_menu()


func _toggle_menu() -> void:
	_set_menu(!_menu_open)


func _set_menu(open: bool) -> void:
	_menu_open = open

	_save_panel.visible = open
	_inventory_panel.visible = open

	get_tree().paused = open


func _on_reload() -> void:
	SaveManager.init()


func _on_save() -> void:
	SaveManager.save_game()


func _on_save_loaded() -> void:
	_inventory_panel.inventory = SaveManager.save.inventory