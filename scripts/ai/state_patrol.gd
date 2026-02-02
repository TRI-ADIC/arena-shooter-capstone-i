# scripts/ai/state_patrol.gd
extends FSMState
class_name StatePatrol

@export var patrol_points : Array[Vector2] = []   # set in the inspector or from code
@export var speed : float = 120.0

var _current_index : int = 0

func enter():
	_current_index = randi() % patrol_points.size()

func physics_process(delta):
	if patrol_points.empty():
		return
	
	var target = patrol_points[_current_index]
	var direction = (target - owner.global_position).normalized()
	owner.move_and_slide(direction * speed)

	if owner.global_position.distance_to(target) < 10.0:
		_current_index = (_current_index + 1) % patrol_points.size()
