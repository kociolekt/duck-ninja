class_name Player
extends Actor

signal player_stats_changed

const FLOOR_DETECT_DISTANCE = 5.0

const DOUBLE_KEY_TIMEOUT = 0.3 # Timeout between key presses
const MAX_KEY_CHAIN = 2
var last_key_delta = 0    # Time since last keypress
var key_chain = []        # Current combo
var filter_keys = InputMap.get_action_list("move_right") + InputMap.get_action_list("move_left")

const MAX_DASH_TIME = 2

export(String) var action_suffix = ""

export var can_cliff = true
export var can_dash = 2
export var can_run = true
export var can_double_jump = 2
export var can_wall_jump = 4

onready var cliff_detector_top = $CliffDetectorTop
onready var cliff_detector_top2 = $CliffDetectorTop2
onready var cliff_detector_bottom = $CliffDetectorBottom
onready var cliff_detector_bottom2 = $CliffDetectorBottom2
onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var camera = $Camera2D

export var coins = 0;
var last_checkpoint = Vector2.ZERO;

func _ready():
	last_checkpoint = position
	yield(get_tree().create_timer(.5), "timeout") # waiting for GUI to be ready and connected
	emit_signal("player_stats_changed", self)

func _input(event):
	if event is InputEventKey and event.pressed and !event.echo: # If distinct key press down
		for action in filter_keys:
			if action.scancode == event.scancode:
				if last_key_delta > DOUBLE_KEY_TIMEOUT:                   # Reset combo if stale
					key_chain = []
					
				key_chain.append(OS.get_scancode_string(action.scancode))
				
				if key_chain.size() > MAX_KEY_CHAIN:                 # Prune if necessary
					key_chain.pop_front()
			
				last_key_delta = 0                                   # Reset keypress timer

var is_running = false

var jump_was_pressed = false
var double_jumped = 0

var is_dashing = false
var dashed = 0
var is_on_cliff = false

var wall_jump_timeout = 0.3
var wall_jump_direction = 0
var is_wall_jump_eligible = 0
var is_wall_jumping = false

func _physics_process(_delta):
	var is_on_floor = is_on_floor()
	
	# walking and running
	var right = Input.get_action_strength("move_right" + action_suffix)
	var left = Input.get_action_strength("move_left" + action_suffix)
	var move_direction = right - left
	var walk_max_speed = 20
	var friction = 3
	
	if (is_on_floor or is_running) and (key_chain == ["Right", "Right"] or key_chain == ["Left", "Left"]):
		walk_max_speed *= 3
		is_running = true
	
	if not is_dashing:
		if move_direction:
			_velocity.x += move_direction * 10
			if abs(_velocity.x) > walk_max_speed:
				_velocity.x = sign(_velocity.x) * walk_max_speed
		else:
			if abs(_velocity.x) < friction:
				_velocity.x = 0
			else:
				_velocity.x -= sign(_velocity.x) * friction
	
	# dashing
	if not is_on_floor:
		if dashed < can_dash:
			if key_chain == ["Right", "Right"] and Input.is_action_just_pressed("move_right" + action_suffix):
				_velocity.x = 100
				_velocity.y = -10
				dashed += 1
				is_dashing = true
			if key_chain == ["Left", "Left"] and Input.is_action_just_pressed("move_left" + action_suffix):
				_velocity.x = -100
				_velocity.y = -10
				dashed += 1
				is_dashing = true
	else:
		dashed = 0
		is_dashing = false
	
	if Input.is_action_just_released("move_right" + action_suffix):
		is_running = false
		is_dashing = false
	
	if Input.is_action_just_released("move_left" + action_suffix):
		is_running = false
		is_dashing = false
	
	# jumping
	var jump_just_pressed = Input.is_action_just_pressed("jump" + action_suffix)
	var jump_pressing = Input.get_action_strength("jump" + action_suffix)
	
	if is_on_floor:
		double_jumped = 0
	
	if not is_wall_jump_eligible and ((jump_just_pressed and is_on_floor) or (jump_just_pressed and can_double_jump > double_jumped)):
		_velocity.y = -50
		jump_was_pressed = true
		if not is_on_floor:
			double_jumped += 1
		
	if jump_was_pressed and jump_pressing:
		_velocity.y -= 0.5
	else:
		jump_was_pressed = false
		
	# wall jumping
	if cliff_detector_bottom.is_colliding() and Input.get_action_strength("move_right" + action_suffix):
		is_wall_jump_eligible = wall_jump_timeout
		wall_jump_direction = -1
	elif cliff_detector_bottom2.is_colliding() and Input.get_action_strength("move_left" + action_suffix):
		is_wall_jump_eligible = wall_jump_timeout
		wall_jump_direction = 1
	else:
		is_wall_jump_eligible = is_wall_jump_eligible - _delta if is_wall_jump_eligible - _delta > 0 else 0
		
	if is_wall_jump_eligible > 0:
		_velocity.y = _velocity.y if _velocity.y < 10 else 1
		if (Input.get_action_strength("move_left" + action_suffix) and wall_jump_direction == -1) or (Input.get_action_strength("move_right" + action_suffix) and wall_jump_direction == 1):
			if jump_just_pressed:
				_velocity.y = -50
				jump_was_pressed = true
				is_wall_jumping = true
	else:
		is_wall_jumping = false
	
	if is_wall_jumping:
		_velocity.x = wall_jump_direction * is_wall_jump_eligible * 100
	
	print(double_jumped)
	
	# cliff
	if is_on_cliff():
		_velocity.x = 0
		_velocity.y = 0
		is_dashing = false
		is_running = false
		dashed = 0
		double_jumped = 0
		is_on_cliff = true
	else:
		is_on_cliff = false
	
	# reset on button or on fall
	if Input.is_action_just_released("reset" + action_suffix) or position.y > 760:
		reset_to_last_checkpoint()
	
	# actually moving
	var snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE if jump_just_pressed else Vector2.ZERO
	_velocity = move_and_slide_with_snap(
		_velocity, snap_vector, FLOOR_NORMAL, false, 4, 0.9, false
	)
	
	# keyschain
	last_key_delta += _delta
	
	# sprite direction
	if move_direction != 0:
		sprite.scale.x = 1 if move_direction > 0 else -1
	
	# animation
	var animation = get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)


func get_new_animation():
	var animation_new = ""
	if is_on_floor():
		animation_new = "run" if abs(_velocity.x) > 0.1 else "idle"
	elif is_on_cliff:
		animation_new = "hang"
	elif not is_on_floor():
		animation_new = "falling" if _velocity.y > 0 else "jumping"
	return animation_new


func is_on_cliff():
	if not can_cliff:
		return false
		
	var right = Input.get_action_strength("move_right" + action_suffix)
	var left = Input.get_action_strength("move_left" + action_suffix)
	
	if _velocity.y > 0:
		if right and not cliff_detector_top.is_colliding() and cliff_detector_bottom.is_colliding():
			return true
		if left and not cliff_detector_top2.is_colliding() and cliff_detector_bottom2.is_colliding():
			return true
		
	return false
	pass

func reset_to_last_checkpoint():
	var tmpZoom = camera.zoom
	camera.zoom = Vector2.ZERO
	position = last_checkpoint
	camera.zoom = tmpZoom

func save():
	var save_dict = {
		"path"  : get_path(),
		"coins" : coins
	}
	return save_dict

func _on_CoinCollider_body_entered(coin):
	coins += coin.amount
	coin.collect()
	emit_signal("player_stats_changed", self)
	pass


func _on_CheckpointCollider_area_shape_entered(area_id, area, area_shape, self_shape):
	last_checkpoint = area.global_position
	pass # Replace with function body.
