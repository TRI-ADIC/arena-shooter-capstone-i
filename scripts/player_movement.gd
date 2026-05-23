# scripts/player_movement.gd  (attach to Player)
extends CharacterBody2D

@export var speed : float = 250.0

func _physics_process(delta):
	var input_vec = Vector2.ZERO
	input_vec.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vec.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if input_vec != Vector2.ZERO:
		input_vec = input_vec.normalized()
		velocity = input_vec * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
