extends Area3D

var player_inside := false
var shop = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name != "Player":
		return

	player_inside = true
	shop = get_tree().current_scene

	if not shop.has_basket:
		shop.show_message("Cashier: Good afternoon! Take a basket and choose your products.")
	else:
		shop.show_message("Cashier: Ready to checkout? Press E.")

func _on_body_exited(body):
	if body.name != "Player":
		return

	player_inside = false
	shop.show_message("")

func _input(event):
	if not player_inside:
		return

	if event.is_action_pressed("interact"):
		if not shop.has_basket:
			shop.show_message("Cashier: First take a basket.")
			return

		shop.open_checkout()
