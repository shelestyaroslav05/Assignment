extends CharacterBody2D

@export var move_speed := 12.0

var lane_positions = [800.0, 960.0, 1120.0]
var current_lane := 1
var can_move := false

func _ready():
	current_lane = 1
	global_position.x = lane_positions[current_lane]

func _process(delta):
	if not can_move:
		return

	if Input.is_action_just_pressed("move_left"):
		current_lane = clamp(current_lane - 1, 0, lane_positions.size() - 1)

	if Input.is_action_just_pressed("move_right"):
		current_lane = clamp(current_lane + 1, 0, lane_positions.size() - 1)

	var target_x = lane_positions[current_lane]
	global_position.x = lerp(global_position.x, target_x, move_speed * delta)
