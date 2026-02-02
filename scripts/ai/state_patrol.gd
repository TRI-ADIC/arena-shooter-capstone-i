# scripts/ai/state_patrol.gd
extends FSMState
class_name StatePatrol

var patrol_points = []
var current_index = 0
var speed = 120

func enter():
	# pick a random start point or reset index
	current_index = randi() % patrol_points.size()

func physics_process(delta):
	var target = patrol_points[current_index]
	var direction = (target - owner.global_position).normalized()
	owner.move_and_slide(direction * speed)

	if owner.global_position.distance_to(target) < 10:
		current_index = (current_index + 1) % patrol_points.size()
