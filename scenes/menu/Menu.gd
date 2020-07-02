extends Node2D

var level_scene = preload("res://scenes/level/Level.tscn")

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()

func _on_Start_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			start()
	pass # Replace with function body.

func start():
	get_tree().change_scene_to(level_scene)
	pass


func _on_Quit_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			get_tree().quit()
	pass # Replace with function body.
