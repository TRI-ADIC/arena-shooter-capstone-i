extends Node2D

@export var tile_layer: TileMapLayer
# Initialize the noise generator
var noise = FastNoiseLite.new()

var floor_atlas_coords = Vector2i(0, 0)
var wall_atlas_coords = Vector2i(6, 12)

func _ready():
	randomize()
	# Configure noise for organic "blobs"
	noise.seed = randi()
	noise.frequency = 0.1 # Lower values create larger open rooms
	generate_arena()

func generate_arena():
	if not tile_layer: return
	noise.seed = randi() # New layout every restart
	
	var screen_size = get_viewport_rect().size
	var tile_size = 16
	var columns = int(screen_size.x / tile_size)
	var rows = int(screen_size.y / tile_size)
	
	tile_layer.clear()
	
	# Define Safe Zone around the center (where player spawns)
	var center_x = columns / 2
	var center_y = rows / 2
	var safe_radius = 3 # No walls within 3 tiles of the center
	
	for x in range(columns):
		for y in range(rows):
			# 1. Force the outer boundary walls
			if x == 0 or x == columns - 1 or y == 0 or y == rows - 1:
				tile_layer.set_cell(Vector2i(x,y), 0, wall_atlas_coords)
			
			# 2. Check for the Safe Zone
			elif abs(x - center_x) < safe_radius and abs(y - center_y) < safe_radius:
				tile_layer.set_cell(Vector2i(x,y), 0, floor_atlas_coords)
				
			# 3. Procedural Walls using Noise
			else:
				var noise_val = noise.get_noise_2d(x, y)
				# If noise value is high, place a wall; otherwise, floor
				if noise_val > 0.25: 
					tile_layer.set_cell(Vector2i(x,y), 0, wall_atlas_coords)
				else:
					tile_layer.set_cell(Vector2i(x,y), 0, floor_atlas_coords)

func _on_button_pressed():
	generate_arena()
	var player = get_node_or_null("Player")
	if player:
		# Move player to center of the current screen resolution
		player.position = get_viewport_rect().size / 2
