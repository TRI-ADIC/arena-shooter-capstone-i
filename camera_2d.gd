extends Camera2D

var shake_strength: float = 0.0
var shake_fade: float = 18.0

func _process(delta: float) -> void:
	if shake_strength > 0.0:
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
	else:
		offset = Vector2.ZERO

func apply_shake(amount: float) -> void:
	shake_strength = max(shake_strength, amount)
