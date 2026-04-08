extends Node
class_name PlayerHealth

# Signals for UI and game events
signal health_changed(current_health, max_health)
signal player_damaged(damage_amount)
signal player_healed(heal_amount)
signal player_died()
signal health_critical()  # <25% health
signal health_warning()   # <50% health
signal invincibility_started()
signal invincibility_ended()

# Health properties
@export var max_health: float = 125.0
@export var starting_health: float = 125.0
@export var health_regen_per_second: float = 0.0
@export var invincibility_time: float = 0.75  # Seconds of invincibility after damage
@export var out_of_combat_regen: float = 2.0  # Regen when not hit for a while
@export var out_of_combat_delay: float = 7.0  # Seconds before out-of-combat regen kicks in

# Current state
var current_health: float
var is_alive: bool = true
var is_invincible: bool = false
var invincibility_timer: float = 0.0
var time_since_last_damage: float = 0.0

# Health state tracking
enum HealthState { SAFE, WARNING, DANGER, CRITICAL }
var current_state: HealthState = HealthState.SAFE

func _ready():
	current_health = starting_health
	health_changed.emit(current_health, max_health)
	_update_health_state()

func _process(delta):
	# Handle invincibility timer
	if is_invincible:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			is_invincible = false
			invincibility_ended.emit()
	
	# Track time since last damage for out-of-combat regen
	if is_alive:
		time_since_last_damage += delta
	
	# Apply health regeneration
	if health_regen_per_second > 0 and current_health < max_health and is_alive:
		heal(health_regen_per_second * delta, false)
	
	# Out-of-combat regeneration
	if time_since_last_damage >= out_of_combat_delay and current_health < max_health and is_alive:
		heal(out_of_combat_regen * delta, false)

func take_damage(amount: float) -> void:
	if not is_alive or is_invincible:
		return
	
	# Apply damage
	current_health -= amount
	current_health = max(0, current_health)
	
	# Reset out-of-combat timer
	time_since_last_damage = 0.0
	
	# Trigger invincibility frames
	is_invincible = true
	invincibility_timer = invincibility_time
	invincibility_started.emit()
	
	# Emit signals
	player_damaged.emit(amount)
	health_changed.emit(current_health, max_health)
	
	# Update and check health state
	_update_health_state()
	
	# Check for death
	if current_health <= 0:
		die()

func heal(amount: float, emit_signal: bool = true) -> void:
	if not is_alive:
		return
	
	var old_health = current_health
	current_health += amount
	current_health = min(current_health, max_health)
	
	var actual_heal = current_health - old_health
	
	if emit_signal and actual_heal > 0:
		player_healed.emit(actual_heal)
	
	health_changed.emit(current_health, max_health)
	_update_health_state()

func set_max_health(new_max: float, heal_difference: bool = true) -> void:
	var difference = new_max - max_health
	max_health = new_max
	
	if heal_difference and difference > 0:
		heal(difference)
	else:
		current_health = min(current_health, max_health)
	
	health_changed.emit(current_health, max_health)

func die() -> void:
	if not is_alive:
		return
	
	is_alive = false
	current_health = 0
	current_state = HealthState.CRITICAL
	player_died.emit()

func revive(health_amount: float = -1) -> void:
	is_alive = true
	if health_amount < 0:
		current_health = max_health
	else:
		current_health = min(health_amount, max_health)
	health_changed.emit(current_health, max_health)
	_update_health_state()

# Update health state and emit appropriate signals
func _update_health_state() -> void:
	var old_state = current_state
	var health_percent = get_health_percentage()
	
	if health_percent <= 25.0:
		current_state = HealthState.CRITICAL
	elif health_percent <= 50.0:
		current_state = HealthState.DANGER
	elif health_percent <= 75.0:
		current_state = HealthState.WARNING
	else:
		current_state = HealthState.SAFE
	
	# Emit signals when entering new states
	if current_state != old_state:
		if current_state == HealthState.CRITICAL:
			health_critical.emit()
		elif current_state == HealthState.DANGER:
			health_warning.emit()

# Utility functions
func get_health_percentage() -> float:
	if max_health <= 0:
		return 0.0
	return (current_health / max_health) * 100.0

func is_at_full_health() -> bool:
	return current_health >= max_health

func is_critical() -> bool:
	return current_state == HealthState.CRITICAL

func is_below_half() -> bool:
	return get_health_percentage() <= 50.0

func get_health_state() -> HealthState:
	return current_state
