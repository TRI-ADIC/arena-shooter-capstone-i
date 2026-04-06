extends CharacterBody2D

@export var move_speed: float = 300.0
@export var fire_rate: float = 0.12
@export var bullet_scene: PackedScene

@onready var gun: Node2D = $Gun
@onready var muzzle: Marker2D = $Gun/Muzzle
@onready var muzzle_flash: ColorRect = $Gun/MuzzleFlash
@onready var cam: Camera2D = $"../Camera2D"

var _can_shoot := true

func _ready() -> void:
	if bullet_scene == null:
		push_warning("bullet_scene not set on Player. Drag Bullet.tscn into the export slot.")

func _physics_process(delta: float) -> void:
	_handle_movement()
	_aim_gun()
	_handle_shooting()

func _handle_movement() -> void:
	var input_dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	velocity = input_dir * move_speed
	move_and_slide()

func _aim_gun() -> void:
	var mouse_pos := get_global_mouse_position()
	var dir := mouse_pos - global_position
	gun.rotation = dir.angle()

func _handle_shooting() -> void:
	if Input.is_action_pressed("shoot") and _can_shoot and bullet_scene != null:
		_can_shoot = false
		_spawn_bullet()
		_play_muzzle_flash()
		cam.apply_shake(3.5)
		await get_tree().create_timer(fire_rate).timeout
		_can_shoot = true

func _spawn_bullet() -> void:
	var b := bullet_scene.instantiate()
	get_tree().current_scene.add_child(b)

	var dir := (get_global_mouse_position() - muzzle.global_position).normalized()
	b.global_position = muzzle.global_position
	b.call("setup", dir)
	
	var spread := deg_to_rad(3)
	dir = dir.rotated(randf_range(-spread, spread))

func _play_muzzle_flash() -> void:
	muzzle_flash.visible = true
	muzzle_flash.modulate.a = 1.0
	muzzle_flash.scale = Vector2(1.0, 1.0)

	await get_tree().create_timer(0.06).timeout

	muzzle_flash.visible = false
