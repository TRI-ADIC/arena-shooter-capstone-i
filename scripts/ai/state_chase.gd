# scripts/ai/state_chase.gd
extends FSMState
class_name StateChase

@export var chase_speed : float = 200.0
@export var max_chase_distance : float = 800.0   # stop chasing if player gets too far

func physics_process(delta):
	var player = enemy.get_node_or_null("/root/TestArena/Player")
	if not player:
		return
	
	var to_player = player.global_position - enemy.global_position
	var distance = to_player.length()
	
	if distance > max_chase_distance:
		# Too far – let the AI decide to go back to patrol
		enemy.emit_signal("lost_player")   # optional signal you can listen for
		return
	
	var direction = to_player.normalized()
	# 1️⃣ Set the body’s velocity
	enemy.velocity = direction * chase_speed
	# 2️⃣ Apply the movement for this physics frame
	enemy.move_and_slide()
