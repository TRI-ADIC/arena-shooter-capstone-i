extends CharacterBody2D

# -------------------------------------------------------
# enemy_base.gd (Marco's original + xp_value for Mahian)
# -------------------------------------------------------

@export var max_hp: int = 100
@export var sprite_path: String = ""
@export var patrol_points: Array[Vector2] = []

# Mahi: XP granted to player on death
@export var xp_value: int = 20

var _current_hp: int
var _ai: Node = null

signal died
signal idle_finished
signal lost_player
signal player_out_of_range

func _ready() -> void:
	_current_hp = max_hp

	if sprite_path != "":
		var tex = load(sprite_path)
		if tex:
			var spr = $Sprite2D if has_node("Sprite2D") else null
			if spr:
				spr.texture = tex
			else:
				spr = Sprite2D.new()
				spr.texture = tex
				add_child(spr)

	var ai_scene = preload("res://scripts/ai/enemy_ai.gd")
	_ai = ai_scene.new(self)
	add_child(_ai)

	if _ai.has_method("set_patrol_points"):
		_ai.set_patrol_points(patrol_points)

func apply_damage(amount: int) -> void:
	_current_hp = max(_current_hp - amount, 0)
	if _current_hp == 0:
		emit_signal("died")
		if _ai and _ai.has_method("change_state"):
			_ai.change_state("dead")

func heal(amount: int) -> void:
	_current_hp = min(_current_hp + amount, max_hp)

func get_health() -> int:
	return _current_hp
