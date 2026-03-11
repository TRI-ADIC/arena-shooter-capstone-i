# scripts/ai/fsm_state.gd
extends RefCounted
class_name FSMState

var enemy : CharacterBody2D = null   # the actual enemy body

func _init(_enemy : CharacterBody2D):
	enemy = _enemy

func enter(): pass
func exit(): pass
func physics_process(delta): pass
