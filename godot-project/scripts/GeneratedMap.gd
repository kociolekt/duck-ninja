extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var end = Vector2(2, 1)

onready var arenas = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
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
	
	for arena in arenas:
		if arena.is_class("TileMap"):
			var anchor = end - arena.start;
			for cellv in arena.get_used_cells():
				var coords = anchor + cellv
				set_cellv(coords, arena.get_cellv(cellv))
				update_bitmask_area(coords)
			for asset in arena.get_children():
				var coords = map_to_world(anchor) + asset.position
				var newAsset = asset.duplicate()
				newAsset.position = coords;
				add_child(newAsset)
			end = anchor + arena.end
	pass
		
