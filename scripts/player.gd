extends CharacterBody2D

@export var speed = 200

func _physics_process(_delta):
	# Get input direction (WASD or Arrow keys)
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Apply movement
	velocity = direction * speed
	move_and_slide()
	 
