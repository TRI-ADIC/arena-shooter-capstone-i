# scripts/ai/state_attack.gd
extends FSMState
class_name StateAttack

@export var fire_rate : float = 1.5          # seconds between shots
@export var attack_range : float = 250.0

var _time_since_last_shot : float = 0.0

func enter():
	_time_since_last_shot = 0.0

func physics_process(delta):
	_time_since_last_shot += delta
	
	var player = get_node_or_null("/root/Main/Player")
	if not player:
		return
	
	var distance = owner.global_position.distance_to(player.global_position)
	if distance > attack_range:
		# Player left range – tell the AI to switch state
		owner.emit_signal("player_out_of_range")
		return
	
	if _time_since_last_shot >= fire_rate:
		_time_since_last_shot = 0.0
		fire_bullet()

func fire_bullet():
	# -----------------------------------------------------------------
	# Replace this stub with your own projectile‑spawning code.
	# Example (assuming you have a PackedScene called "Bullet.tscn"):
	#
	# var bullet_scene = preload("res://scenes/bullet.tscn")
	# var bullet = bullet_scene.instantiate()
	# bullet.global_position = owner.global_position
	# var dir = (player.global_position - owner.global_position).normalized()
	# bullet.direction = dir
	# get_tree().root.add_child(bullet)
	#
	# -----------------------------------------------------------------
	print("[Enemy] Fire! (stub)")
