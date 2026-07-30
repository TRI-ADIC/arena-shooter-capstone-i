# scripts/run_persist.gd
# -------------------------------------------------------
# RunPersist — Autoload singleton
# Add this in Project > Project Settings > Autoload
# Name it: RunPersist
#
# Stores upgrades the player has picked so they survive
# a scene reload (i.e. after dying and restarting the run).
# -------------------------------------------------------
extends Node

# List of upgrade dicts the player has picked this session
var carried_upgrades: Array = []

# Whether the current run started from a death (vs fresh start)
var came_from_death: bool = false

# Add an upgrade to the carry list
func add_upgrade(upgrade: Dictionary) -> void:
	carried_upgrades.append(upgrade)

# Call this to wipe everything (e.g. main menu / full reset)
func reset() -> void:
	carried_upgrades.clear()
	came_from_death = false

# Returns the combined stat value for a given stat across all carried upgrades
func get_total_bonus(stat_name: String) -> float:
	var total = 0.0
	for upgrade in carried_upgrades:
		if upgrade.get("stat") == stat_name:
			total += upgrade["value"]
	return total
