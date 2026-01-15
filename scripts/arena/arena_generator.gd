extends Node2D

@export var width: int = 20
@export var height: int = 12
@export var tile_layer: TileMapLayer

# Tile IDs (These depend on your TileSet setup)
var floor_atlas_coords = Vector2i(0, 0)
var wall_atlas_coords = Vector2i(6, 12)

func _ready():
	generate_arena()

func generate_arena():
	if not tile_layer:
		print("Error: No TileMapLayer assigned!")
		return
		
	# Clear previous data
	tile_layer.clear()
	
	for x in range(width):
		for y in range(height):
			if x == 0 or x == width - 1 or y == 0 or y == height - 1:
				tile_layer.set_cell(Vector2i(x,y), 0, wall_atlas_coords)
			else:
				tile_layer.set_cell(Vector2i(x,y), 0, floor_atlas_coords)
