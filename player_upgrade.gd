extends Node
 
# -------------------------------------------------------
# player_upgrades.gd
# Attach this as a child node of the Player scene.
# Handles XP, leveling up, and the upgrade selection UI.
# Does NOT modify player.gd, bullet.gd, or any enemy scripts.
# -------------------------------------------------------
 
signal xp_changed(current_xp, xp_to_next)
signal level_changed(new_level)
 
# --- XP / Level settings ---
var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 100
 
# --- Player stat modifiers (read by other systems via get_stat) ---
var stats: Dictionary = {
	"speed_bonus":         0.0,   # flat bonus added to base speed
	"fire_rate_mult":      1.0,   # multiplier (1.0 = normal, 0.8 = 20% faster)
	"bullet_damage_bonus": 0,     # flat bonus added to bullet damage
	"max_health_bonus":    0,     # flat bonus added to max HP
	"regen_rate":          0.0,   # HP per second
	"bullet_speed_bonus":  0.0,   # flat bonus to bullet speed
	# --- NEW in Capstone II ---
	"bounce_bonus":        0,     # extra bullet bounces
	"damage_reduction":    0.0,   # % damage reduction (0.15 = 15% less damage)
}
 
# --- All possible upgrades pool ---
const UPGRADE_POOL: Array = [
	{
		"id": "speed_up",
		"name": "Swift Wheels",
		"desc": "Move speed +40",
		"stat": "speed_bonus",
		"value": 40.0
	},
	{
		"id": "fire_rate_up",
		"name": "Rapid Fire",
		"desc": "Fire rate 20% faster",
		"stat": "fire_rate_mult",
		"value": -0.2   # subtracted so cooldown shrinks
	},
	{
		"id": "damage_up",
		"name": "Piercing Rounds",
		"desc": "Bullet damage +5",
		"stat": "bullet_damage_bonus",
		"value": 5
	},
	{
		"id": "health_up",
		"name": "Armor Plating",
		"desc": "Max health +25",
		"stat": "max_health_bonus",
		"value": 25
	},
	{
		"id": "regen_up",
		"name": "Regeneration",
		"desc": "Gain 2 HP per second",
		"stat": "regen_rate",
		"value": 2.0
	},
	{
		"id": "bullet_speed_up",
		"name": "High Velocity",
		"desc": "Bullet speed +100",
		"stat": "bullet_speed_bonus",
		"value": 100.0
	},
	{
		"id": "speed_up_2",
		"name": "Turbo Boost",
		"desc": "Move speed +60",
		"stat": "speed_bonus",
		"value": 60.0
	},
	{
		"id": "damage_up_2",
		"name": "Explosive Tips",
		"desc": "Bullet damage +10",
		"stat": "bullet_damage_bonus",
		"value": 10
	},
	# --- NEW in Capstone II ---
	{
		"id": "bouncy_bullets",
		"name": "Bouncy Bullets",
		"desc": "Bullets bounce 2 extra times",
		"stat": "bounce_bonus",
		"value": 2
	},
	{
		"id": "double_regen",
		"name": "Vampiric",
		"desc": "Gain 4 HP per second",
		"stat": "regen_rate",
		"value": 4.0
	},
	{
		"id": "iron_skin",
		"name": "Iron Skin",
		"desc": "Take 15% less damage",
		"stat": "damage_reduction",
		"value": 0.15
	},
	{
		"id": "bullet_speed_up_2",
		"name": "Hypersonic",
		"desc": "Bullet speed +200",
		"stat": "bullet_speed_bonus",
		"value": 200.0
	},
]
 
# Reference to the upgrade UI scene (set in _ready)
var upgrade_ui: CanvasLayer = null
 
func _ready() -> void:
	# Load and add the upgrade UI as a child
	var ui_scene = load("res://scenes/ui/upgrade_ui.tscn")
	if ui_scene:
		upgrade_ui = ui_scene.instantiate()
		add_child(upgrade_ui)
		# Connect the card chosen signal back to us
		upgrade_ui.connect("upgrade_chosen", _on_upgrade_chosen)
		upgrade_ui.hide_ui()

	# --- NEW: Restore any upgrades carried over from a previous run ---
	for upgrade in RunPersist.carried_upgrades:
		var stat = upgrade["stat"]
		if stats.has(stat):
			stats[stat] += upgrade["value"]
 
# -------------------------------------------------------
# Call this when an enemy dies to grant XP.
# Hook it up in your scene or via Marco's died signal:
#   enemy.died.connect(func(): player_upgrades.add_xp(enemy.xp_value))
# -------------------------------------------------------
func add_xp(amount: int) -> void:
	current_xp += amount
	emit_signal("xp_changed", current_xp, xp_to_next_level)
	if current_xp >= xp_to_next_level:
		_level_up()
 
func _level_up() -> void:
	current_xp -= xp_to_next_level
	current_level += 1
	# Scale XP required for next level
	xp_to_next_level = int(xp_to_next_level * 1.4)
	emit_signal("level_changed", current_level)
	_show_upgrade_selection()
 
func _show_upgrade_selection() -> void:
	# Pause the game while choosing
	get_tree().paused = true
 
	# Pick 3 unique random upgrades
	var pool_copy = UPGRADE_POOL.duplicate()
	pool_copy.shuffle()
	var choices = pool_copy.slice(0, 3)
 
	if upgrade_ui:
		upgrade_ui.show_choices(choices)
 
func _on_upgrade_chosen(upgrade: Dictionary) -> void:
	# Apply the chosen upgrade to stats
	var stat = upgrade["stat"]
	if stats.has(stat):
		stats[stat] += upgrade["value"]

	# --- NEW: Save to RunPersist so it carries into the next run ---
	RunPersist.add_upgrade(upgrade)

	# Resume the game
	get_tree().paused = false

	if upgrade_ui:
		upgrade_ui.hide_ui()

	# --- NEW: If this was a death pick, reload the scene for a fresh run ---
	if RunPersist.came_from_death:
		RunPersist.came_from_death = false
		get_tree().reload_current_scene()

# -------------------------------------------------------
# NEW — Call this from your player health script when HP hits 0.
# Shows the upgrade picker with a "You Died" title before restarting.
# -------------------------------------------------------
func show_death_upgrade_selection() -> void:
	RunPersist.came_from_death = true
	get_tree().paused = true
	var pool_copy = UPGRADE_POOL.duplicate()
	pool_copy.shuffle()
	var choices = pool_copy.slice(0, 3)
	if upgrade_ui:
		upgrade_ui.show_choices(choices, "You Died! Pick a perk for your next run:")

# -------------------------------------------------------
# Getter so other scripts can read bonuses cleanly.
# Example: player_upgrades.get_stat("speed_bonus")
# -------------------------------------------------------
func get_stat(stat_name: String):
	return stats.get(stat_name, 0)
