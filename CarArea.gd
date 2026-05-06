extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name != "Player":
		return

	var street = get_tree().current_scene
	street.open_car_dialog()

func _on_body_exited(body):
	if body.name != "Player":
		return

	var street = get_tree().current_scene
	street.close_car_dialog()
