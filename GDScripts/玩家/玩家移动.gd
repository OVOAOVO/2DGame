extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D =  get_node("AnimatedSprite2D")
@onready var jump_sound: AudioStreamPlayer2D = get_node("JumpSound")

const SPEED = 300.0
const JUMP_VELOCITY = -850.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if jump_sound == null:
		print("AudioStreamPlayer2D is NULLL!")
		return
	if animated_sprite_2d == null:
		print("AnimatedSprite2D is NULLL!")
		return

func _physics_process(delta: float) -> void:

	# Add Animation
	if velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "Run" 
	else:
		animated_sprite_2d.animation = "Idle" 

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y < 0:
			animated_sprite_2d.animation = "Jump"
		else:
			animated_sprite_2d.animation = "Fall"

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
		
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true