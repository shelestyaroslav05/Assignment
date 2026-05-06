extends CharacterBody2D

var lane_positions = [80.0, 240.0, 400.0]
var current_lane = 1
var can_move = false

func _ready():
	position.x = lane_positions[current_lane]

func _input(event):
	if not can_move:
		return

	if event.is_action_pressed("move_left"):
		current_lane -= 1
		current_lane = clamp(current_lane, 0, 2)
		position.x = lane_positions[current_lane]

	if event.is_action_pressed("move_right"):
		current_lane += 1
		current_lane = clamp(current_lane, 0, 2)
		position.x = lane_positions[current_lane]
