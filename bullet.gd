extends CharacterBody2D

@export var speed: float = 900.0
@export var lifetime: float = 1.2
@export var max_bounces: int = 3

var bounce_count: int = 0

func _ready() -> void:
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)

	if collision:
		var collider := collision.get_collider()

		if collider == null:
			queue_free()
			return

		# Bounce on walls
		if collider.is_in_group("walls"):
			bounce_count += 1

			if bounce_count > max_bounces:
				queue_free()
				return

			velocity = velocity.bounce(collision.get_normal()) * 0.85
			rotation = velocity.angle()

			# tiny push away so it does not stick to the wall
			global_position += collision.get_normal() * 0.5
			return

		# Do NOT ricochet on enemies
		if collider.is_in_group("enemies"):
			queue_free()
			return

		# Default for anything else
		queue_free()

func setup(direction: Vector2) -> void:
	velocity = direction.normalized() * speed
	rotation = direction.angle()
