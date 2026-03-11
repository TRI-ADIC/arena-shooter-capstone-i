# scripts/ai/state_patrol.gd
extends FSMState
class_name StatePatrol

@export var speed : float = 120.0

var _current_index : int = 0

func enter():
	var points = enemy.patrol_points
	
	# Guard against an empty list – pick a safe default index
	if points.is_empty():
		_current_index = 0
	else:
		_current_index = randi() % points.size()


func physics_process(delta):
	var points = enemy.patrol_points
	
	# Early‑out if there are no points to move toward
	if points.is_empty():
		return
	
	# Ensure the index is within bounds
	if _current_index >= points.size():
		_current_index = 0  # Reset to start if we went past the end
	
	var target : Vector2 = points[_current_index]
	var direction : Vector2 = (target - enemy.global_position).normalized()
	# 1️⃣ Set the body’s velocity
	enemy.velocity = direction * speed
	# 2️⃣ Apply the movement for this physics frame
	enemy.move_and_slide()
	
	# print("[Patrol] velocity = ", enemy.velocity)

	# Switch to the next waypoint when we’re close enough
	if enemy.global_position.distance_to(target) < 10.0:
		_current_index = (_current_index + 1) % points.size()
