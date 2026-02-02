# scripts/ai/state_dead.gd
extends FSMState
class_name StateDead

@export var death_animation : String = "die"
@export var removal_delay : float = 0.5   # seconds after animation ends

var _timer : float = 0.0

func enter():
	# Play a death animation if the enemy has an AnimationPlayer
	var anim_player = owner.get_node_or_null("AnimationPlayer")
	if anim_player and anim_player.has_animation(death_animation):
		anim_player.play(death_animation)
	_timer = 0.0

func physics_process(delta):
	_timer += delta
	if _timer >= removal_delay:
		owner.queue_free()
