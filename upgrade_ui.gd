extends CanvasLayer

# -------------------------------------------------------
# upgrade_ui.gd
# Displays 3 upgrade card buttons when the player levels up.
# Emits upgrade_chosen(upgrade_dict) when a card is clicked.
# -------------------------------------------------------

signal upgrade_chosen(upgrade: Dictionary)

# We'll build the UI purely in code so no .tscn editor work needed.
var _panel: Panel
var _container: HBoxContainer
var _label: Label

func _ready() -> void:
	# Build the overlay
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_label = Label.new()
	_label.text = "LEVEL UP! Choose an upgrade:"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_label.position = Vector2(-200, 80)
	_label.size = Vector2(400, 40)
	_label.add_theme_font_size_override("font_size", 22)
	add_child(_label)

	_container = HBoxContainer.new()
	_container.set_anchors_preset(Control.PRESET_CENTER)
	_container.position = Vector2(-330, -80)
	_container.size = Vector2(660, 160)
	_container.add_theme_constant_override("separation", 20)
	add_child(_container)

func show_choices(choices: Array, title: String = "LEVEL UP! Choose an upgrade:") -> void:
	# Update the title label (supports both level-up and death screens)
	_label.text = title

	# Clear old cards
	for child in _container.get_children():
		child.queue_free()

	# Build a button card for each choice
	for upgrade in choices:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(200, 140)
		btn.text = upgrade["name"] + "\n\n" + upgrade["desc"]
		btn.add_theme_font_size_override("font_size", 14)
		# Store upgrade data on the button via metadata
		btn.set_meta("upgrade_data", upgrade)
		btn.pressed.connect(_on_card_pressed.bind(btn))
		_container.add_child(btn)

	show()

func hide_ui() -> void:
	hide()

func _on_card_pressed(btn: Button) -> void:
	var upgrade = btn.get_meta("upgrade_data")
	emit_signal("upgrade_chosen", upgrade)
