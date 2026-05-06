extends Node3D

@onready var car_panel = $UI/CarPanel
@onready var car_text = $UI/CarPanel/CarText
@onready var yes_button = $UI/CarPanel/YesButton
@onready var no_button = $UI/CarPanel/NoButton
@onready var engine_sound = $EngineSound

var player_near_car := false
var car_dialog_open := false
var starting_car := false

func _ready():
	car_panel.visible = false

	yes_button.pressed.connect(_on_yes_pressed)
	no_button.pressed.connect(_on_no_pressed)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func open_car_dialog():
	if starting_car:
		return

	car_dialog_open = true
	car_panel.visible = true
	car_text.text = "Go home?"
	yes_button.text = "1. Yes"
	no_button.text = "2. No"

func close_car_dialog():
	car_dialog_open = false
	car_panel.visible = false

func _input(event):
	if not car_dialog_open:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			_on_yes_pressed()
		elif event.keycode == KEY_2:
			_on_no_pressed()

func _on_yes_pressed():
	if starting_car:
		return

	starting_car = true
	car_text.text = "Starting engine..."
	yes_button.visible = false
	no_button.visible = false

	if engine_sound:
		engine_sound.play()

	await get_tree().create_timer(2.0).timeout

	get_tree().change_scene_to_file("res://scenes/minigame.tscn")

func _on_no_pressed():
	close_car_dialog()
