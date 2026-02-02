# scripts/ai/state_idle.gd
extends FSMState
class_name StateIdle

@export var idle_time : float = 1.0

var _elapsed : float = 0.0

func enter():
	_elapsed = 0.0

func physics_process(delta):
	_elapsed += delta
	if _elapsed >= idle_time:
		owner.emit_signal("idle_finished")
