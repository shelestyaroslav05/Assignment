extends Area3D

var player_inside := false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		player_inside = true
		get_tree().current_scene.show_message("Press E to take basket.")

func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false
		get_tree().current_scene.show_message("")

func _input(event):
	if player_inside and event.is_action_pressed("interact"):
		get_tree().current_scene.take_basket()
		get_parent().visible = false
		queue_free()
