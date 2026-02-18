# scripts/enemy_base.gd
extends CharacterBody2D                 # Godot 4 – use KinematicBody2D for Godot 3

# ------------------------------------------------------------------
# ABSTRACT SETTINGS – child scenes should override these
# ------------------------------------------------------------------
@export var max_hp : int = 100          # default, can be changed per enemy
@export var sprite_path : String = ""   # child sets a texture or AnimatedSprite2D
@export var patrol_points : Array[Vector2] = []   # optional, used by FSM

# ------------------------------------------------------------------
# INTERNAL STATE (do NOT edit from children)
# ------------------------------------------------------------------
var _current_hp : int
var _ai : Node = null                    # will hold the EnemyAI script instance

# ------------------------------------------------------------------
# SIGNALS – useful for UI, score, etc.
# ------------------------------------------------------------------
signal died                               # emitted when hp reaches 0

# ------------------------------------------------------------------
# READY – set up health, sprite, and attach the FSM
# ------------------------------------------------------------------
func _ready() -> void:
	_current_hp = max_hp

	# 1️⃣ Set up the visual representation (optional)
	if sprite_path != "":
		var tex = load(sprite_path)
		if tex:
			# Try to find a Sprite2D or AnimatedSprite2D child automatically
			var spr = $Sprite2D if has_node("Sprite2D") else null
			if spr:
				spr.texture = tex
			else:
				# If the scene has no Sprite2D, create one on the fly
				spr = Sprite2D.new()
				spr.texture = tex
				add_child(spr)

	# 2️⃣ Attach the FSM (the AI script you already wrote)
	var ai_scene = preload("res://scripts/ai/enemy_ai.gd")
	_ai = ai_scene.new()
	add_child(_ai)                       # makes _ai part of the node tree
	# The AI expects the *owner* to be the enemy node; because we added it as a child,
	# its `owner` property will automatically be this enemy node.

	# 3️⃣ Pass any data the AI needs (e.g., patrol points)
	if _ai.has_method("set_patrol_points"):
		_ai.set_patrol_points(patrol_points)

# ------------------------------------------------------------------
# PUBLIC API – child scenes (or external code) can call these
# ------------------------------------------------------------------
func apply_damage(amount : int) -> void:
	_current_hp = max(_current_hp - amount, 0)
	if _current_hp == 0:
		emit_signal("died")
		# Let the FSM handle the death animation / removal
		if _ai and _ai.has_method("change_state"):
			_ai.change_state("dead")

func heal(amount : int) -> void:
	_current_hp = min(_current_hp + amount, max_hp)

func get_health() -> int:
	return _current_hp
