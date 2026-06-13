extends Panel

# Emitted when the player presses the save button
signal save_requested

@onready var save_button: Button = %SaveButton


func _ready() -> void:
	save_button.pressed.connect(save_requested.emit)
