# scripts/ai/state_patrol.gd
extends FSMState
class_name StatePatrol

@export var patrol_points : Array[Vector2] = []   # set in the inspector or from code
@export var speed : float = 120.0

var _current_index : int = 0

func enter():
	# Guard against an empty list – pick a safe default index
	if patrol_points.is_empty():
		_current_index = 0
	else:
		_current_index = randi() % patrol_points.size()


func physics_process(delta):
	# Early‑out if there are no points to move toward
	if patrol_points.is_empty():
		return
	
	var target : Vector2 = patrol_points[_current_index]
	var direction : Vector2 = (target - owner.global_position).normalized()
	owner.move_and_slide(direction * speed)

	# Switch to the next waypoint when we’re close enough
	if owner.global_position.distance_to(target) < 10.0:
		_current_index = (_current_index + 1) % patrol_points.size()
