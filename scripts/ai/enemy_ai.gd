# scripts/ai/enemy_ai.gd
extends CharacterBody2D   # Godot 4 – use KinematicBody2D for Godot 3

# Preloads --------------------------------------------------------------
const StatePatrol = preload("res://scripts/ai/state_patrol.gd")
const StateChase  = preload("res://scripts/ai/state_chase.gd")
const StateAttack = preload("res://scripts/ai/state_attack.gd")
const StateDead   = preload("res://scripts/ai/state_dead.gd")
const StateIdle   = preload("res://scripts/ai/state_idle.gd")

# Signals ---------------------------------------------------------------
signal lost_player
signal player_out_of_range
signal idle_finished

# State storage ---------------------------------------------------------
var _states = {}
var _current_state : FSMState = null

# ----------------------------------------------------------------------
func _ready():
	# Build the dictionary of state objects
	_states["idle"]   = StateIdle.new(self)
	_states["patrol"] = StatePatrol.new(self)
	_states["chase"]  = StateChase.new(self)
	_states["attack"] = StateAttack.new(self)
	_states["dead"]   = StateDead.new(self)

	# Connect signals that states may emit
	connect("lost_player", Callable(self, "_on_lost_player"))
	connect("player_out_of_range", Callable(self, "_on_player_out_of_range"))
	connect("idle_finished", Callable(self, "_on_idle_finished"))

	# Start with a brief idle, then patrol
	change_state("idle")

# ----------------------------------------------------------------------
func change_state(name: String) -> void:
	if _current_state:
		_current_state.exit()
	_current_state = _states[name]
	_current_state.enter()

# ----------------------------------------------------------------------
func _physics_process(delta):
	if _current_state:
		_current_state.physics_process(delta)

	# Global transition checks (you can also move them into states)
	if _current_state == _states["patrol"] and sees_player():
		change_state("chase")
	elif _current_state == _states["chase"]:
		if in_attack_range():
			change_state("attack")
		elif !sees_player():
			change_state("patrol")
	elif _current_state == _states["attack"]:
		if !in_attack_range():
			change_state("chase")
		elif is_dead():
			change_state("dead")

# ----------------------------------------------------------------------
# Helper utilities -------------------------------------------------------
func sees_player() -> bool:
	var player = get_node_or_null("/root/Main/Player")
	if not player: return false
	return owner.global_position.distance_to(player.global_position) < 400.0   # vision radius

func in_attack_range() -> bool:
	var player = get_node_or_null("/root/Main/Player")
	if not player: return false
	return owner.global_position.distance_to(player.global_position) < 250.0   # same as attack_range

func is_dead() -> bool:
	# Replace with your own health check
	return owner.has_meta("hp") and owner.get_meta("hp") <= 0

# ----------------------------------------------------------------------
# Signal callbacks -------------------------------------------------------
func _on_lost_player():
	change_state("patrol")

func _on_player_out_of_range():
	change_state("patrol")

func _on_idle_finished():
	change_state("patrol")
