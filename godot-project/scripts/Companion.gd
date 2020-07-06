class_name Companion
extends Actor

const FLOOR_DETECT_DISTANCE = 1.0

onready var player = $"../Player"
onready var map = $"../MapGenerator"

var friction = 5
var max_speed = 20

enum State {WALK, JUMP, TELEPORT, IDLE}
var current_state = State.IDLE

var half_tile = 16 / 2
var floor_tile = 2
var last_player_map_pos = null
var player_path = []
var current_target = null
var tile_offset = Vector2(8, 10)

func _ready():
	pass

func _process(delta):
	var cat_map_pos = map.world_to_map(global_position - map.global_position)
	var player_map_pos = map.world_to_map(player.global_position - map.global_position)
	var player_floor_map_pos = player_map_pos + Vector2.DOWN
	var is_player_on_floor = map.get_cellv(player_floor_map_pos) == floor_tile
	
	# calculate player path on floors
	if cat_map_pos == player_map_pos:
		# optimize if player stands on cat tile
		player_path.clear()
		current_target = null
		current_state = State.IDLE
	elif last_player_map_pos != player_map_pos:
		# player changed tile so lets add it do player_path
		last_player_map_pos = player_map_pos
		if is_player_on_floor:
			player_path.append(player_map_pos)

	# constantly get new target
	if not current_target and player_path.size() > 1:
		current_target = player_path.pop_front()

	if current_target:
		var direction_map = current_target - cat_map_pos
		var target_position = map.map_to_world(current_target) + map.global_position + tile_offset;
		
		# calculate next state from idle
		if current_state == State.IDLE:
			if abs(direction_map.x) == 1 and (direction_map.y == 0 or direction_map.y == 1):
				current_state = State.WALK
			elif direction_map.length() < 10:
				current_state = State.JUMP
			else:
				current_state = State.TELEPORT

		
		# do the movement
		match current_state:
			State.WALK:
				do_walk_to_position(target_position)
			State.JUMP:
				do_jump_to_position(target_position, delta)
			State.TELEPORT:
				do_teleport_to_position(target_position)
			State.IDLE:
				slow_down_x()
	else:
		slow_down_x()

	# reset on button or on fall
	if position.y > 760:
		current_state = State.TELEPORT

	# actually moving
	var snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE if is_jumping else Vector2.ZERO
	_velocity = move_and_slide_with_snap(
		_velocity, snap_vector, FLOOR_NORMAL, false, 4, 0.9, false
	)

func do_walk_to_position(target_position):
	var sub_x = target_position.x - global_position.x
	var direction_x = sign(sub_x)
	var distance_x = abs(sub_x) 
	
	_velocity.x = (_velocity.x + direction_x) if abs(_velocity.x) < max_speed else direction_x * max_speed
	
	if distance_x < 0.3:
		global_position.x = target_position.x
		
		if sign(target_position.y - global_position.y) < 5:
			current_target = null
			current_state = State.IDLE
		
var is_jumping = false
var jump_p0 = null
var jump_p1 = null
var jump_p2 = null
var jump_time = 0
		
func do_jump_to_position(target_position, delta):
	var sub_x = target_position.x - global_position.x
	var direction_x = sign(sub_x)
	var distance_x = abs(sub_x)
	
	if !is_jumping:
		var mid_point_x = global_position.x + int(sub_x / 2)
		var mid_point_y = min(global_position.y, target_position.y) - 29
		
		jump_p0 = global_position
		jump_p1 = Vector2(mid_point_x, mid_point_y)
		jump_p2 = target_position
		
		var jump_lp0 = jump_p0 + Vector2(-3, 0)
		var jump_lp1 = jump_p1 + Vector2(-3, 0)
		var jump_lp2 = jump_p2 + Vector2(-3, 0)
		
		var jump_pp0 = jump_p0 + Vector2(3, 0)
		var jump_pp1 = jump_p1 + Vector2(3, 0)
		var jump_pp2 = jump_p2 + Vector2(3, 0)
		
		if check_trajectory_collision(jump_p0, jump_p1, jump_p2) or check_trajectory_collision(jump_lp0, jump_lp1, jump_lp2) or check_trajectory_collision(jump_pp0, jump_pp1, jump_pp2):
			current_state = State.TELEPORT
		else:
			is_jumping = true
		
	if is_jumping:
		jump_time += delta
		global_position = _quadratic_bezier(jump_p0, jump_p1, jump_p2, jump_time)
		_velocity = Vector2.ZERO
		if jump_time > delta * 2 and get_slide_count() > 0:
			is_jumping = false
			jump_time = 0
			_velocity = Vector2.ZERO
			current_state = State.TELEPORT
		
	if distance_x < 0.3:
		global_position.x = target_position.x
		
		if sign(target_position.y - global_position.y) < 5:
			current_target = null
			current_state = State.IDLE
			is_jumping = false
			jump_time = 0
			_velocity = Vector2.ZERO

func do_teleport_to_position(target_position):
	global_position = target_position
	_velocity.x = 0
	current_target = null
	current_state = State.IDLE
	is_jumping = false
	jump_time = 0

func check_trajectory_collision(p0, p1, p2):
	var space_state = get_world_2d().direct_space_state
	var point1 = _quadratic_bezier(p0, p1, p2, 0.01)
	var point2 = _quadratic_bezier(p0, p1, p2, 0.25)
	var point3 = _quadratic_bezier(p0, p1, p2, 0.50)
	var point4 = _quadratic_bezier(p0, p1, p2, 0.75)
	var point5 = _quadratic_bezier(p0, p1, p2, 0.99)
	# use global coordinates, not local to node
	var result1 = space_state.intersect_ray(point1, point2)
	var result2 = space_state.intersect_ray(point2, point3)
	var result3 = space_state.intersect_ray(point3, point4)
	var result4 = space_state.intersect_ray(point4, point5)
	
	return result1 or result2 or result3 or result4

func slow_down_x():
	_velocity.x = _velocity.x - (sign(_velocity.x) * friction) if abs(_velocity.x) > friction else 0

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var r = q0.linear_interpolate(q1, t)
	return r
