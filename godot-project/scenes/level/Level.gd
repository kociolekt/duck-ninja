extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	load_game()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			save_game()
			get_tree().change_scene("res://scenes/menu/Menu.tscn")


# Note: This can be called from anywhere inside the tree. This function is
# path independent.
# Go through everything in the persist category and ask them to return a
# dict of relevant variables
func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node has a save function
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		
		# Call the node's save function
		var node_data = node.call("save")
		
		# Check the node is an instanced scene so it can be instanced again during load
		if not node_data.has("filename") and not node_data.has("path"):
			print("persistent node '%s' is not an instanced scene nor does it have path, skipped" % node.name)
			continue

		# Store the save dictionary as a new line in the save file
		save_game.store_line(to_json(node_data))
	save_game.close()

# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		print("nosavefile found, skipped")
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		if not i.filename.empty():
			i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())

		if node_data.has("filename"):
			# Firstly, we need to create the object and add it to the tree and set its position.
			var new_object = load(node_data["filename"]).instance()
			get_node(node_data["parent"]).add_child(new_object)
			new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
	
			# Now we set the remaining variables.
			for i in node_data.keys():
				if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
					continue
				new_object.set(i, node_data[i])
		elif node_data.has("path"):
			var tree_object = get_node(node_data.path)
			if tree_object:
				# Now we set the remaining variables.
				for i in node_data.keys():
					if i == "filename" or i == "path" or i == "parent" or i == "pos_x" or i == "pos_y":
						continue
					tree_object.set(i, node_data[i])
				
	save_game.close()
