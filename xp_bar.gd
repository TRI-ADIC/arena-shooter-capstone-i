extends CanvasLayer

# -------------------------------------------------------
# xp_bar.gd
# A simple XP progress bar + level label shown on the HUD.
# Add this as a child of the Player scene alongside player_upgrades.gd
# Then connect signals from player_upgrades in _ready().
# -------------------------------------------------------

var _bar: ProgressBar
var _level_label: Label

func _ready() -> void:
	# Build XP bar at bottom of screen in code
	var container = VBoxContainer.new()
	container.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	container.position = Vector2(10, -50)
	container.size = Vector2(200, 40)
	add_child(container)

	_level_label = Label.new()
	_level_label.text = "Level 1"
	_level_label.add_theme_font_size_override("font_size", 12)
	container.add_child(_level_label)

	_bar = ProgressBar.new()
	_bar.min_value = 0
	_bar.max_value = 100
	_bar.value = 0
	_bar.custom_minimum_size = Vector2(200, 16)
	_bar.show_percentage = false
	container.add_child(_bar)

# Called by player_upgrades signals
func on_xp_changed(current_xp: int, xp_to_next: int) -> void:
	_bar.max_value = xp_to_next
	_bar.value = current_xp

func on_level_changed(new_level: int) -> void:
	_level_label.text = "Level " + str(new_level)
