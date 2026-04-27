extends CharacterBody2D

# -------------------------------------------------------
# bullet.gd (Jason's original + Mahi's upgrade hooks)
# -------------------------------------------------------

@export var speed: float = 900.0
@export var lifetime: float = 1.2
@export var max_bounces: int = 3
@export var damage: int = 10  # base damage

var bounce_count: int = 0

# Mahi: bonus stats applied via setup_with_upgrades
var _damage_bonus: int = 0
var _speed_bonus: float = 0.0

func _ready() -> void:
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		var collider := collision.get_collider()
		if collider == null:
			queue_free()
			return
		if collider.is_in_group("walls"):
			bounce_count += 1
			if bounce_count > max_bounces:
				queue_free()
				return
			velocity = velocity.bounce(collision.get_normal()) * 0.85
			rotation = velocity.angle()
			global_position += collision.get_normal() * 0.5
			return
		if collider.is_in_group("enemies"):
			# Mahi: apply total damage including upgrade bonus
			if collider.has_method("apply_damage"):
				collider.apply_damage(damage + _damage_bonus)
			queue_free()
			return
		queue_free()

# Jason's original setup
func setup(direction: Vector2) -> void:
	velocity = direction.normalized() * speed
	rotation = direction.angle()

# Mahi: extended setup that reads upgrade stats
func setup_with_upgrades(direction: Vector2, upgrades: Node) -> void:
	_damage_bonus = upgrades.get_stat("bullet_damage_bonus")
	_speed_bonus  = upgrades.get_stat("bullet_speed_bonus")
	velocity = direction.normalized() * (speed + _speed_bonus)
	rotation = direction.angle()
