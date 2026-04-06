extends Node2D

@onready var player: Node2D = $Player
@onready var cam: Camera2D = $Camera2D


func _process(delta: float) -> void:
	cam.global_position = player.global_position
