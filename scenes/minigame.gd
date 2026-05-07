extends Node2D

@export var obstacle_scene: PackedScene

var player
var road
var start_panel
var start_button
var restart_button
var trip_progress
var result_label
var heart_1
var heart_2
var heart_3
var spawn_timer
var game_timer
var game_music
var crash_sound

var lives := 3
var progress := 0.0
var max_progress := 100.0
var game_duration := 60.0
var elapsed_time := 0.0

var game_running := false
var game_finished := false

var lane_positions = [800.0, 960.0, 1120.0]
var player_start_y := 900.0
var obstacle_spawn_y := -80.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	randomize()

	player = find_child("PlayerCar", true, false)
	road = find_child("Road", true, false)

	start_panel = find_child("StartPanel", true, false)
	start_button = find_child("StartButton", true, false)
	restart_button = find_child("RestartButton", true, false)

	trip_progress = find_child("TripProgress", true, false)
	result_label = find_child("ResultLabel", true, false)

	heart_1 = find_child("Heart1", true, false)
	heart_2 = find_child("Heart2", true, false)
	heart_3 = find_child("Heart3", true, false)

	spawn_timer = find_child("SpawnTimer", true, false)
	game_timer = find_child("GameTimer", true, false)
	game_music = find_child("GameMusic", true, false)
	crash_sound = find_child("CrashSound", true, false)

	calculate_lanes_from_road()

	if start_button and not start_button.pressed.is_connected(_on_start_button_pressed):
		start_button.pressed.connect(_on_start_button_pressed)

	if restart_button and not restart_button.pressed.is_connected(_on_restart_button_pressed):
		restart_button.pressed.connect(_on_restart_button_pressed)

	if spawn_timer and not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	if spawn_timer:
		spawn_timer.stop()

	if game_timer:
		game_timer.stop()

	reset_game_state()

func calculate_lanes_from_road():
	if road == null:
		lane_positions = [800.0, 960.0, 1120.0]
		return

	var road_x = road.global_position.x
	var road_width = road.size.x
	var lane_width = road_width / 3.0

	lane_positions = [
		road_x + lane_width * 0.5,
		road_x + lane_width * 1.5,
		road_x + lane_width * 2.5
	]

func reset_game_state():
	calculate_lanes_from_road()

	lives = 3
	progress = 0.0
	elapsed_time = 0.0
	game_running = false
	game_finished = false

	if player:
		player.can_move = false
		player.current_lane = 1
		player.lane_positions = lane_positions
		player.global_position.x = lane_positions[1]
		player.global_position.y = player_start_y

	if trip_progress:
		trip_progress.min_value = 0
		trip_progress.max_value = 100
		trip_progress.value = 0

	if result_label:
		result_label.visible = false

	if start_panel:
		start_panel.visible = true

	if restart_button:
		restart_button.visible = false

	update_hearts()
	clear_obstacles()

func _process(delta):
	if not game_running:
		return

	elapsed_time += delta
	progress = clamp((elapsed_time / game_duration) * max_progress, 0.0, max_progress)

	if trip_progress:
		trip_progress.value = progress

	if elapsed_time >= game_duration:
		win_game()

func _on_start_button_pressed():
	start_game()

func start_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	calculate_lanes_from_road()

	if start_panel:
		start_panel.visible = false

	if restart_button:
		restart_button.visible = false

	if result_label:
		result_label.visible = false

	lives = 3
	progress = 0.0
	elapsed_time = 0.0
	game_running = true
	game_finished = false

	if player:
		player.can_move = true
		player.current_lane = 1
		player.lane_positions = lane_positions
		player.global_position.x = lane_positions[1]
		player.global_position.y = player_start_y

	if trip_progress:
		trip_progress.value = 0

	update_hearts()
	clear_obstacles()

	if spawn_timer:
		spawn_timer.wait_time = 1.1
		spawn_timer.start()

	if game_music and game_music.stream != null:
		game_music.stop()
		game_music.play()

func _on_spawn_timer_timeout():
	if not game_running:
		return

	spawn_obstacle_row()

func spawn_obstacle_row():
	if obstacle_scene == null:
		print("ERROR: obstacle_scene is empty. Set it in MiniGame inspector.")
		return

	var safe_lane = randi_range(0, 2)
	var blocked_lanes = []

	for i in range(3):
		if i != safe_lane:
			blocked_lanes.append(i)

	blocked_lanes.shuffle()

	var obstacle_count = randi_range(1, 2)

	for i in range(obstacle_count):
		var lane = blocked_lanes[i]
		var obstacle = obstacle_scene.instantiate()
		obstacle.add_to_group("obstacles")
		add_child(obstacle)
		obstacle.global_position = Vector2(lane_positions[lane], obstacle_spawn_y)

func player_hit():
	if not game_running:
		return

	if crash_sound and crash_sound.stream != null:
		crash_sound.play()

	lives -= 1
	update_hearts()

	if lives <= 0:
		lose_game()

func update_hearts():
	if heart_1:
		heart_1.visible = lives >= 1
	if heart_2:
		heart_2.visible = lives >= 2
	if heart_3:
		heart_3.visible = lives >= 3

func stop_gameplay():
	game_running = false
	game_finished = true

	if player:
		player.can_move = false

	if spawn_timer:
		spawn_timer.stop()

	if game_timer:
		game_timer.stop()

	clear_obstacles()

func clear_obstacles():
	for obstacle in get_tree().get_nodes_in_group("obstacles"):
		obstacle.queue_free()

func lose_game():
	if game_finished:
		return

	stop_gameplay()

	if game_music and game_music.playing:
		game_music.stop()

	if result_label:
		result_label.visible = true
		result_label.text = "GAME OVER"

	if restart_button:
		restart_button.visible = true

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func win_game():
	if game_finished:
		return

	stop_gameplay()

	if result_label:
		result_label.visible = true
		result_label.text = "YOU GOT HOME!"

	if restart_button:
		restart_button.visible = true

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_button_pressed():
	if game_music and game_music.playing:
		game_music.stop()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	get_tree().change_scene_to_file("res://scenes/shop.tscn")

func is_game_active():
	return game_running
