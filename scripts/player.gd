extends CharacterBody2D

@export var speed = 200 # base movement speed (pixels/sec)
@export var dash_speed: float = 600.0 # speed multiplier dash
@export var dash_duration: float = 0.15
@export var jump_zone_dash_bonus: float = 1.6 # duration multiplier when inside a jump zone
@export var dash_cooldown: float = 1.0

#---internal state-------------------------------------
var _is_dashing: bool = false
var _dash_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _dash_dir: Vector2 = Vector2.ZERO
var _last_move_dir: Vector2 = Vector2.RIGHT # fallback dash direction
var _in_jump_zone: bool = false
var _jump_zone_count: int = 0				# track overlapping zones


func _ready() -> void:
	add_to_group("player")
	if not InputMap.has_action("jump"):
		InputMap.add_action("jump")
		var ev := InputEventKey.new()
		ev.physical_keycode = KEY_SPACE
		InputMap.action_add_event("jump", ev)

func _physics_process(delta: float) -> void:
	# Tick timers
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta

	#--Active dash phase---
	if _is_dashing:
		_dash_timer -= delta
		if _dash_timer <= 0.0:
			_is_dashing = false
		else:
			velocity = _dash_dir * dash_speed
			move_and_slide()
			return

	# Normal movement
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		_last_move_dir = direction

	#--Dash input---
	if Input.is_action_just_pressed("jump") and _cooldown_timer <= 0.0:
		var dash_dir = direction if direction != Vector2.ZERO else _last_move_dir
		_start_dash(dash_dir.normalized())
		return

	velocity = direction * speed
	move_and_slide()

## Called when the player begins to dash
func _start_dash(dir: Vector2) -> void:
	_is_dashing = true
	_dash_dir = dir
	# jump zones boost dash range
	var bonus = jump_zone_dash_bonus if _in_jump_zone else 1.0
	_dash_timer = dash_duration * bonus
	_cooldown_timer = dash_cooldown

# ── Jump-zone interface (called by Area2D signals in arena_generator) ────────

## Marks the player as being inside a jump zone.
func enter_jump_zone() -> void:
	_jump_zone_count += 1
	_in_jump_zone = true

## Called when the player leaves a jump zone area.
func exit_jump_zone() -> void:
	_jump_zone_count = max(0, _jump_zone_count - 1)
	_in_jump_zone = _jump_zone_count > 0

## Resets jump-zone tracking (call this when the arena regenerates).
func reset_jump_zone_state() -> void:
	_jump_zone_count = 0
	_in_jump_zone = false

# ── Read-only accessors (useful for other systems / HUD) ─────────────────────

## Returns true while the player is mid-dash.
func is_dashing() -> bool:
	return _is_dashing

## Returns true while the player stands in a jump zone.
func is_in_jump_zone() -> bool:
	return _in_jump_zone

## Returns remaining dash cooldown in seconds.
func get_dash_cooldown_remaining() -> float:
	return max(0.0, _cooldown_timer)
