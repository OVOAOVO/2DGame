extends Area2D

@export_file("*.tscn") var next_level: String

func _ready():
    self.body_entered.connect(_on_body_entered)
    
func _on_body_entered(body):
    if next_level != "":
        get_tree().change_scene_to_file(next_level)