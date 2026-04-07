extends Node2D

# ── Signals ──────────────────────────────────────────────────────────────────
## Emitted after every (re)generation.  jump_zone_positions is an Array of
## Vector2 world-space centres that other systems (enemy spawners, HUDs …)
## can read without coupling to this script.
signal arena_generated(jump_zone_positions: Array[Vector2])

# ── Exports ───────────────────────────────────────────────────────────────────
@export var tile_layer: TileMapLayer
## Number of jump-zone pads to scatter around the arena.
@export var jump_zone_count: int = 3

# ── Tile atlas coordinates ────────────────────────────────────────────────────
var floor_atlas_coords   = Vector2i(0, 0)
var wall_atlas_coords    = Vector2i(6, 12)
## A visually distinct tile used to mark jump-zone centres.
## Change this to match whichever tile you want in your tilesheet.
var jump_zone_atlas_coords = Vector2i(3, 0)

# ── Runtime data (read by other scripts via get_jump_zone_positions()) ────────
var _jump_zone_positions: Array[Vector2] = []

# ── Noise ─────────────────────────────────────────────────────────────────────
var noise := FastNoiseLite.new()

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	randomize()
	noise.seed  = randi()
	noise.frequency = 0.1   # lower → larger open rooms
	generate_arena()

# ─────────────────────────────────────────────────────────────────────────────
func generate_arena() -> void:
	if not tile_layer:
		return

	noise.seed = randi()   # new layout on every call

	# ── Reset jump-zone state ────────────────────────────────────────────
	_jump_zone_positions.clear()

	# Remove old Area2D jump-zone nodes from previous generation
	for child in get_children():
		if child.is_in_group("jump_zone_area"):
			child.queue_free()

	# ── Notify the player so it doesn't remain "in a zone" after regen ──
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("reset_jump_zone_state"):
		player.reset_jump_zone_state()

	# ── Geometry ─────────────────────────────────────────────────────────
	var screen_size  := get_viewport_rect().size
	var tile_size    := 16
	var columns      := int(screen_size.x / tile_size)
	var rows         := int(screen_size.y / tile_size)
	var center_x     := columns / 2
	var center_y     := rows   / 2
	var safe_radius  := 3      # wall-free zone around player spawn

	tile_layer.clear()

	# ── Pass 1 : basic floor / wall tiles ────────────────────────────────
	for x in range(columns):
		for y in range(rows):
			var cell := Vector2i(x, y)
			if x == 0 or x == columns - 1 or y == 0 or y == rows - 1:
				# Hard boundary
				tile_layer.set_cell(cell, 0, wall_atlas_coords)
			elif abs(x - center_x) < safe_radius and abs(y - center_y) < safe_radius:
				# Safe spawn zone – always open floor
				tile_layer.set_cell(cell, 0, floor_atlas_coords)
			else:
				# Noise-driven organic walls
				var v := noise.get_noise_2d(x, y)
				tile_layer.set_cell(cell, 0,
					wall_atlas_coords if v > 0.25 else floor_atlas_coords)

	# ── Pass 2 : scatter jump zones ───────────────────────────────────────
	_place_jump_zones(columns, rows, center_x, center_y, safe_radius, tile_size)

	# ── Done ─────────────────────────────────────────────────────────────
	arena_generated.emit(_jump_zone_positions)

# ── Jump-zone placement ───────────────────────────────────────────────────────
func _place_jump_zones(
		columns: int, rows: int,
		center_x: int, center_y: int,
		safe_radius: int, tile_size: int) -> void:

	var placed   := 0
	var attempts := 0
	var max_att  := 300

	while placed < jump_zone_count and attempts < max_att:
		attempts += 1
		var x := randi_range(2, columns - 3)
		var y := randi_range(2, rows   - 3)

		# Keep clear of spawn safe zone
		if abs(x - center_x) < safe_radius + 3 and abs(y - center_y) < safe_radius + 3:
			continue

		# Require a 3×3 block of open floor around the candidate tile
		var ok := true
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				var c := tile_layer.get_cell_atlas_coords(Vector2i(x + dx, y + dy))
				if c == wall_atlas_coords or c == Vector2i(-1, -1):
					ok = false
					break
			if not ok:
				break
		if not ok:
			continue

		# Place the special jump-zone tile at the centre
		tile_layer.set_cell(Vector2i(x, y), 0, jump_zone_atlas_coords)

		# Record world position and spawn detection area
		var world_pos: Vector2 = tile_layer.map_to_local(Vector2i(x, y))
		_jump_zone_positions.append(world_pos)
		_spawn_jump_zone_area(world_pos, tile_size)
		placed += 1

# ── Area2D factory for a single jump zone ────────────────────────────────────
func _spawn_jump_zone_area(world_pos: Vector2, tile_size: int) -> void:
	var area := Area2D.new()
	area.add_to_group("jump_zone_area")
	area.collision_layer = 0          # doesn't need its own physics layer
	area.collision_mask  = 1          # detects layer-1 bodies (player / enemies)

	var shape_node := CollisionShape2D.new()
	var rect       := RectangleShape2D.new()
	# Slightly larger than one tile so the player feels the zone before reaching centre
	rect.size = Vector2(tile_size * 2.0, tile_size * 2.0)
	shape_node.shape = rect

	area.add_child(shape_node)
	area.position = world_pos
	add_child(area)

	area.body_entered.connect(_on_jump_zone_body_entered)
	area.body_exited.connect(_on_jump_zone_body_exited)

# ── Area2D callbacks ──────────────────────────────────────────────────────────
func _on_jump_zone_body_entered(body: Node) -> void:
	if body.has_method("enter_jump_zone"):
		body.enter_jump_zone()

func _on_jump_zone_body_exited(body: Node) -> void:
	if body.has_method("exit_jump_zone"):
		body.exit_jump_zone()

# ── Public API ────────────────────────────────────────────────────────────────
## Returns the last generated list of jump-zone world positions.
## Other branches (enemy spawners, minimap …) can call this after
## connecting to the arena_generated signal.
func get_jump_zone_positions() -> Array[Vector2]:
	return _jump_zone_positions

# ── Button wired in arena.tscn ────────────────────────────────────────────────
func _on_button_pressed() -> void:
	generate_arena()
	# Re-centre the player using group lookup instead of a hard-coded path,
	# so this works regardless of how other branches structure their scenes.
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.position = get_viewport_rect().size / 2
