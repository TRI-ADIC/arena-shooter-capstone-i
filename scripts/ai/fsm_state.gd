# scripts/ai/fsm_state.gd
extends RefCounted

class_name FSMState

var owner : Node = null   # the enemy node that owns this state

func _init(_owner):
	owner = _owner

func enter(): pass
func exit(): pass
func physics_process(delta): pass
