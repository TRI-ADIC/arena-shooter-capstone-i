extends Node

# -------------------------------------------------------
# player_upgrade.gd
# Attach as a child node of the Player scene.
# Handles XP, leveling up, and the upgrade selection UI.
# -------------------------------------------------------

signal xp_changed(current_xp, xp_to_next)
signal level_changed(new_level)

var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 100

var stats: Dictionary = {
	"speed_bonus":          0.0,
	"fire_rate_mult":       1.0,
	"bullet_damage_bonus":  0,
	"max_health_bonus":     0,
	"regen_rate":           0.0,
	"bullet_speed_bonus":   0.0,
}

const UPGRADE_POOL: Array = [
	{"id": "speed_up",       "name": "Swift Wheels",    "desc": "Move speed +40",        "stat": "speed_bonus",          "value": 40.0},
	{"id": "fire_rate_up",   "name": "Rapid Fire",      "desc": "Fire rate 20% faster",  "stat": "fire_rate_mult",       "value": -0.2},
	{"id": "damage_up",      "name": "Piercing Rounds", "desc": "Bullet damage +5",      "stat": "bullet_damage_bonus",  "value": 5},
	{"id": "health_up",      "name": "Armor Plating",   "desc": "Max health +25",        "stat": "max_health_bonus",     "value": 25},
	{"id": "regen_up",       "name": "Regeneration",    "desc": "Gain 2 HP per second",  "stat": "regen_rate",           "value": 2.0},
	{"id": "bullet_spd_up",  "name": "High Velocity",   "desc": "Bullet speed +100",     "stat": "bullet_speed_bonus",   "value": 100.0},
	{"id": "speed_up_2",     "name": "Turbo Boost",     "desc": "Move speed +60",        "stat": "speed_bonus",          "value": 60.0},
	{"id": "damage_up_2",    "name": "Explosive Tips",  "desc": "Bullet damage +10",     "stat": "bullet_damage_bonus",  "value": 10},
]

# --- FIX: create UI directly in code, no .tscn needed ---
var upgrade_ui = null

func _ready() -> void:
	# Load upgrade_ui.gd and instantiate it as a CanvasLayer
	var ui_script = load("res://upgrade_ui.gd")
	if ui_script:
		upgrade_ui = CanvasLayer.new()
		upgrade_ui.set_script(ui_script)
		add_child(upgrade_ui)
		upgrade_ui.connect("upgrade_chosen", _on_upgrade_chosen)
		upgrade_ui.hide_ui()
	else:
		push_warning("upgrade_ui.gd not found - upgrade screen will not show")

func add_xp(amount: int) -> void:
	current_xp += amount
	emit_signal("xp_changed", current_xp, xp_to_next_level)
	if current_xp >= xp_to_next_level:
		_level_up()

func _level_up() -> void:
	current_xp -= xp_to_next_level
	current_level += 1
	xp_to_next_level = int(xp_to_next_level * 1.4)
	emit_signal("level_changed", current_level)
	_show_upgrade_selection()

func _show_upgrade_selection() -> void:
	get_tree().paused = true
	var pool_copy = UPGRADE_POOL.duplicate()
	pool_copy.shuffle()
	var choices = pool_copy.slice(0, 3)
	if upgrade_ui:
		upgrade_ui.show_choices(choices)

func _on_upgrade_chosen(upgrade: Dictionary) -> void:
	var stat = upgrade["stat"]
	if stats.has(stat):
		stats[stat] += upgrade["value"]
	get_tree().paused = false
	if upgrade_ui:
		upgrade_ui.hide_ui()

func get_stat(stat_name: String):
	return stats.get(stat_name, 0)
