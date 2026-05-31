extends Node2D

@onready var save_panel: Panel = %SavePanel
@onready var inventory_panel: Panel = %InventoryPanel

var menu_open := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_init_ui()
	_bind_signals()

	await get_tree().process_frame
	_init_save()


# ----------------------------
# 初始化
# ----------------------------

func _init_ui() -> void:
	save_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_panel.process_mode = Node.PROCESS_MODE_ALWAYS

	_set_menu(false)


func _init_save() -> void:
	# 如果已经有存档，直接刷新一次UI
	if SaveManager.save != null:
		_on_save_loaded()


func _bind_signals() -> void:
	save_panel.reload_requested.connect(_on_reload_requested)
	save_panel.save_requested.connect(_on_save_requested)

	SaveManager.save_loaded.connect(_on_save_loaded)


# ----------------------------
# 输入 & 菜单
# ----------------------------

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		toggle_menu()


func toggle_menu() -> void:
	_set_menu(!menu_open)


func _set_menu(open: bool) -> void:
	menu_open = open

	save_panel.visible = open
	inventory_panel.visible = open

	get_tree().paused = open


# ----------------------------
# UI事件
# ----------------------------

func _on_reload_requested() -> void:
	SaveManager.load_savegame()
	_on_save_loaded()


func _on_save_requested() -> void:
	SaveManager.save_game()


func _on_save_loaded() -> void:
	inventory_panel.inventory = SaveManager.save.inventory
