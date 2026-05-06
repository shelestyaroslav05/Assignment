extends Area3D

@export var shelf_name: String = "Shelf"
@export var item_types: Array[String] = []

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name != "Player":
		return

	var shop = get_tree().current_scene
	if shop != null and shop.has_method("open_shelf_from_types"):
		shop.open_shelf_from_types(shelf_name, item_types, self)

func _on_body_exited(body):
	if body.name != "Player":
		return

	var shop = get_tree().current_scene
	if shop != null and shop.has_method("close_shelf_menu"):
		shop.close_shelf_menu(self)
