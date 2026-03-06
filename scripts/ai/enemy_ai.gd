# scripts/ai/enemy_ai.gd
extends Node

# Store a reference to the enemy (the node that owns the AI)
var enemy : CharacterBody2D = null

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
func _init(_enemy : CharacterBody2D = null) -> void:
	enemy = _enemy

func _ready() -> void:
		# 1️⃣ Does the global class exist?
	if StateIdle is GDScript:
		print("[CHECK] StateIdle is a registered class")
	else:
		print("[CHECK] StateIdle is NOT a class – it's a ", typeof(StateIdle))

	# 2️⃣ Create an instance and print its class name
	var test = StateIdle.new(null)   # we don’t need a real enemy for this check
	print("[CHECK] test.get_class() → ", test.get_class())
	
	set_physics_process(true)   # make sure _physics_process runs
	
	# ---- Debug prints – now inside a function! ----
	# print("[EnemyAI] Loaded state scripts:")
	# print("  StateIdle   → ", StateIdle)
	# print("  StatePatrol → ", StatePatrol)
	# print("  StateChase  → ", StateChase)
	# print("  StateAttack → ", StateAttack)
	# print("  StateDead   → ", StateDead)
	
	# Build the dictionary of state objects
	_states["idle"]   = StateIdle.new(enemy)
	_states["patrol"] = StatePatrol.new(enemy)
	_states["chase"]  = StateChase.new(enemy)
	_states["attack"] = StateAttack.new(enemy)
	_states["dead"]   = StateDead.new(enemy)
	
	_verify_states()

	# Connect signals that states may emit
	connect("lost_player", Callable(enemy, "_on_lost_player"))
	connect("player_out_of_range", Callable(enemy, "_on_player_out_of_range"))
	connect("idle_finished", Callable(enemy, "_on_idle_finished"))

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
		# <<< DEBUG >>> -------------------------------------------------
		# print("[EnemyAI] current state → ", _current_state.get_class())
		# ----------------------------------------------------------------
		_current_state.physics_process(delta)
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
	var player = get_node_or_null("/root/TestArena/Player")
	# -----------------------------------------------------------------
	# Defensive check – if the player isn’t present, we simply say we
	# don’t see it. This prevents the “null.global_position” crash.
	# -----------------------------------------------------------------
	if player == null:
		# Uncomment the line below if you want to see when this happens.
		print("[EnemyAI] sees_player() – player node not found")
		return false

	# At this point `player` is a valid node with a global_position.
	return enemy.global_position.distance_to(player.global_position) < 400.0   # vision radius

func in_attack_range() -> bool:
	var player = get_node_or_null("/root/TestArena/Player")
	if not player: return false
	return enemy.global_position.distance_to(player.global_position) < 250.0   # same as attack_range

func is_dead() -> bool:
	# Replace with your own health check
	return enemy.has_meta("hp") and enemy.get_meta("hp") <= 0

# ----------------------------------------------------------------------
# Signal callbacks -------------------------------------------------------
func _on_lost_player():
	change_state("patrol")

func _on_player_out_of_range():
	change_state("patrol")

func _on_idle_finished():
	change_state("patrol")
	
func _verify_states():
	for name in _states.keys():
		var inst = _states[name]
		print("[VERIFY] ", name, " instance class → ", inst.get_class())
