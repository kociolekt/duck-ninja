extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var end = Vector2(2, 1)

onready var arenas = Array()

enum ExitDirection {TOP, BOTTOM, LEFT, RIGHT}

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(ExitDirection.TOP, ExitDirection.BOTTOM, ExitDirection.LEFT, ExitDirection.RIGHT)
	randomize()
	preload_arenas()
	get_random_arena()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func preload_arenas():
	arenas.push_back(preload("res://scenes/map_grass/Grass1.tscn").instance())
	arenas.push_back(preload("res://scenes/map_grass/Grass2.tscn").instance())
	arenas.push_back(preload("res://scenes/map_grass/Grass3.tscn").instance())
	arenas.push_back(preload("res://scenes/map_grass/Grass4.tscn").instance())
	arenas.push_back(preload("res://scenes/map_grass/Grass5.tscn").instance())
	arenas.push_back(preload("res://scenes/map_grass/Grass6.tscn").instance())
	arenas.push_back(preload("res://scenes/map_grass/Grass7.tscn").instance())
	arenas.push_back(preload("res://scenes/map_grass/Grass8.tscn").instance())
	arenas.push_back(preload("res://scenes/map_grass/Grass9.tscn").instance())
	arenas.push_back(preload("res://scenes/map_grass/Grass10.tscn").instance())
	arenas.push_back(preload("res://scenes/map_grass/Grass11.tscn").instance())
	pass

func get_random_arena():
	arenas.shuffle()
	
	var exits_directions = [ExitDirection.RIGHT]
	var exits_positions = [end]
	var collistion_rects = [self.get_used_rect()]

	while exits_positions.size() > 0 and arenas.size() > 0:
		var current_exit_direction = exits_directions.pop_front()
		var current_exit_position = exits_positions.pop_front()
		
		#print(current_exit_direction, current_exit_position)
		
		var current_arena = null
		var current_arena_entrance = null
		
		# find proper arena with entrance matching current_exit_direction
		for arena in arenas:
			var used_rect = arena.get_used_rect()
			for asset in arena.get_children():
				if asset.is_class("Entrance"):
					var asset_map_position = arena.world_to_map(asset.position)
					
					match current_exit_direction:
						ExitDirection.TOP:
							#print("checking top", asset_map_position.y, used_rect.size.y + used_rect.position.y - 1)
							if asset_map_position.y >= used_rect.size.y + used_rect.position.y - 1:
								current_arena = arena
								current_arena_entrance = asset_map_position
								break
						ExitDirection.BOTTOM:
							#print("checking bottom", asset_map_position.y, used_rect.position.y)
							if asset_map_position.y <= used_rect.position.y:
								current_arena = arena
								current_arena_entrance = asset_map_position
								break
						ExitDirection.LEFT:
							#print("checking left", asset_map_position.x, used_rect.size.x + used_rect.position.x - 1)
							if asset_map_position.x >= used_rect.size.x + used_rect.position.x - 1:
								current_arena = arena
								current_arena_entrance = asset_map_position
								break
						ExitDirection.RIGHT:
							#print("checking left entrance", asset_map_position.x, used_rect.position.x)
							if asset_map_position.x <= used_rect.position.x:
								current_arena = arena
								current_arena_entrance = asset_map_position
								break
					
			if current_arena:
				var anchor = current_exit_position - current_arena_entrance;
				
				match current_exit_direction:
					ExitDirection.TOP:
						anchor.y += -1
					ExitDirection.BOTTOM:
						anchor.y += 1
					ExitDirection.LEFT:
						anchor.x += -1
					ExitDirection.RIGHT:
						anchor.x += 1
				
				var current_collision_rect = Rect2(anchor + used_rect.position, used_rect.size)
				var is_collision = false
				for existing_rect in collistion_rects:
					if current_collision_rect.intersects(existing_rect):
						print("Maps collided: %s with %s" % [current_collision_rect, existing_rect])
						is_collision = true
						break
				
				if is_collision:
					break
				else:
					print("Map fits, adding to the game: %s %s " % [current_arena.filename, current_collision_rect])
					collistion_rects.push_back(current_collision_rect)
				
				for cellv in current_arena.get_used_cells():
					var coords = anchor + cellv
					set_cellv(coords, current_arena.get_cellv(cellv))
					update_bitmask_area(coords)
				for asset in current_arena.get_children():
					var coords = map_to_world(anchor) + asset.position
					var newAsset = asset.duplicate()
					newAsset.position = coords;
					add_child(newAsset)
					
					if asset.is_class("Exit"):
						#var used_rect = current_arena.get_used_rect()
						var asset_map_position = current_arena.world_to_map(asset.position)
						
						if asset_map_position.x == used_rect.position.x:
							exits_directions.push_back(ExitDirection.LEFT)
							exits_positions.push_back(world_to_map(newAsset.position))
						elif asset_map_position.x == used_rect.size.x + used_rect.position.x - 1:
							exits_directions.push_back(ExitDirection.RIGHT)
							exits_positions.push_back(world_to_map(newAsset.position))
						elif asset_map_position.y == used_rect.position.y - 1:
							exits_directions.push_back(ExitDirection.TOP)
							exits_positions.push_back(world_to_map(newAsset.position))
						elif asset_map_position.y == used_rect.size.y + used_rect.position.y - 1:
							exits_directions.push_back(ExitDirection.BOTTOM)
							exits_positions.push_back(world_to_map(newAsset.position))
						else:
							print("Exit skipped in: ", current_arena.filename)
							print("map rect: ", used_rect)
							print("exit point: ", asset_map_position)
							
				arenas.remove(arenas.find(current_arena))
				break
			else:
				print('Arena %s does not fit to exit %s in direction %s' % [arena.filename, current_exit_position, current_exit_direction])
				print('Map rect: %s' % arena.get_used_rect())
				print('Entrances positions:')
				for asset in arena.get_children():
					if asset.is_class("Entrance"):
						print(arena.world_to_map(asset.position))
	pass
		
