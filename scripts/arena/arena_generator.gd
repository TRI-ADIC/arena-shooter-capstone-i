extends Node2D

@export var width: int = 20
@export var height: int = 12
@export var tile_layer: TileMapLayer
@export_range(0, 1) var obstacle_density: float = 0.1 # 10% chance for random walls

var floor_atlas_coords = Vector2i(0, 0)
var wall_atlas_coords = Vector2i(6, 12)
var box_atlas_coords = Vector2i(10, 10)

func _ready():
	# Calling randomize() ensures different seed every time
	randomize()
	generate_arena()

func generate_arena():
	if not tile_layer: return
	
	# Get screen size (pixels)
	var screen_size = get_viewport_rect().size
	var tile_size = 16
	
	# Calculates how many tiles fit in the screen
	var screen_width_in_tiles = int(screen_size.x / tile_size)
	var screen_height_in_tiles = int(screen_size.y / tile_size)
	
	tile_layer.clear()
	
	for x in range(screen_width_in_tiles):
		for y in range(screen_height_in_tiles):
			if x == 0 or x == screen_width_in_tiles -1 or y == 0 or y == screen_height_in_tiles:
				tile_layer.set_cell(Vector2i(x,y), 0, wall_atlas_coords)
			elif randf() < 0.1:
				tile_layer.set_cell(Vector2i(x,y), 0, wall_atlas_coords)
			else:
				tile_layer.set_cell(Vector2i(x,y), 0, floor_atlas_coords)
func _on_button_pressed():
	generate_arena()
	
	var player = get_node_or_null("Player")
	if player:
		player.position = Vector2(150, 150)
