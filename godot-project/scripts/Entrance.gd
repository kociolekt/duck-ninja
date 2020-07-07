class_name Entrance
extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var type_name = "Entrance"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func is_class(type): return type == type_name or .is_class(type)
func    get_class(): return type_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
