extends Node3D

var budget_label
var message_label

var shelf_panel
var title_label
var option_button_1
var option_button_2
var option_button_3

var checkout_panel
var checkout_text
var yes_button
var no_button

var readme_panel
var readme_open := true

var budget := 0
var has_basket := false
var basket_items = []
var basket_total := 0

var current_shelf_items = []
var active_shelf = null

var checkout_mode := "normal"

var items_database = {
	"cereal": {"name": "Cereal", "price": 4},
	"milk": {"name": "Milk", "price": 2},
	"sugar": {"name": "Sugar", "price": 2},
	"flour": {"name": "Flour", "price": 3},
	"apple": {"name": "Apples", "price": 2},
	"water": {"name": "Water", "price": 1},
	"juice": {"name": "Juice", "price": 3},
	"bread": {"name": "Bread", "price": 2}
}

func _ready():
	budget_label = get_node("UI/BudgetLabel")
	message_label = get_node("UI/MessageLabel")

	shelf_panel = get_node("UI/ShelfPanel")
	title_label = get_node("UI/ShelfPanel/TitleLabel")
	option_button_1 = get_node("UI/ShelfPanel/OptionButton1")
	option_button_2 = get_node("UI/ShelfPanel/OptionButton2")
	option_button_3 = get_node("UI/ShelfPanel/OptionButton3")

	checkout_panel = get_node("UI/CheckoutPanel")
	checkout_text = get_node("UI/CheckoutPanel/CheckoutText")
	yes_button = get_node("UI/CheckoutPanel/YesButton")
	no_button = get_node("UI/CheckoutPanel/NoButton")

	readme_panel = get_node("UI/ReadmePanel")

	randomize()
	budget = randi_range(12, 30)

	shelf_panel.visible = false
	checkout_panel.visible = false
	readme_panel.visible = true
	readme_open = true

	message_label.text = ""

	option_button_1.pressed.connect(func(): buy_item(0))
	option_button_2.pressed.connect(func(): buy_item(1))
	option_button_3.pressed.connect(func(): buy_item(2))

	yes_button.pressed.connect(_on_checkout_yes_pressed)
	no_button.pressed.connect(_on_checkout_no_pressed)

	update_budget_ui()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if readme_open:
			if event.keycode == KEY_1:
				close_readme()
			return

		if shelf_panel.visible:
			if event.keycode == KEY_1:
				buy_item(0)
			elif event.keycode == KEY_2:
				buy_item(1)
			elif event.keycode == KEY_3:
				buy_item(2)
			elif event.keycode == KEY_ESCAPE:
				close_shelf_menu(active_shelf)

		elif checkout_panel.visible:
			if event.keycode == KEY_1:
				_on_checkout_yes_pressed()
			elif event.keycode == KEY_2:
				_on_checkout_no_pressed()

func close_readme():
	readme_open = false
	readme_panel.visible = false
	show_message("Your budget today is €" + str(budget))

func update_budget_ui():
	budget_label.text = "Budget: €%d | Basket: €%d" % [budget, basket_total]

func show_message(text: String):
	message_label.text = text

func take_basket():
	if readme_open:
		return

	if has_basket:
		show_message("You already have a basket.")
		return

	has_basket = true
	show_message("You picked up a basket.")

func open_shelf_from_types(shelf_name: String, types: Array, shelf_node = null):
	if readme_open:
		return

	active_shelf = shelf_node
	current_shelf_items.clear()

	for t in types:
		if items_database.has(t):
			current_shelf_items.append(items_database[t])

	var buttons = [option_button_1, option_button_2, option_button_3]

	for b in buttons:
		b.visible = false

	if current_shelf_items.is_empty():
		show_message("No valid items on this shelf.")
		return

	title_label.text = shelf_name

	for i in range(min(current_shelf_items.size(), buttons.size())):
		var item = current_shelf_items[i]
		buttons[i].visible = true
		buttons[i].text = "%d. Take %s - €%d" % [i + 1, item["name"], item["price"]]

	shelf_panel.visible = true

func close_shelf_menu(shelf_node = null):
	if shelf_node != null and active_shelf != shelf_node:
		return

	shelf_panel.visible = false
	current_shelf_items.clear()
	active_shelf = null

func buy_item(index: int):
	if index >= current_shelf_items.size():
		return

	if not has_basket:
		show_message("Products won't fit in your hands. Take a basket.")
		close_shelf_menu(active_shelf)
		return

	var item = current_shelf_items[index]
	basket_items.append(item)
	basket_total += item["price"]

	show_message("Added %s (€%d)" % [item["name"], item["price"]])
	update_budget_ui()
	close_shelf_menu(active_shelf)

func open_checkout():
	if readme_open:
		return

	checkout_panel.visible = true

	yes_button.visible = true
	no_button.visible = true
	yes_button.disabled = false
	no_button.disabled = false

	yes_button.text = "1. Yes"
	no_button.text = "2. No"

	checkout_mode = "normal"

	checkout_text.text = "Cashier: Ready to checkout?\nTotal: €%d" % basket_total

func _on_checkout_yes_pressed():
	if checkout_mode == "remove_last_item":
		remove_last_item()
		return

	if basket_total == 0:
		checkout_text.text = "Cashier: Your basket is empty."
		return

	if basket_total > budget:
		suggest_remove_last_item()
		return

	complete_checkout()

func suggest_remove_last_item():
	if basket_items.is_empty():
		checkout_text.text = "Cashier: Your basket is empty."
		return

	var last_item = basket_items[basket_items.size() - 1]
	var over_amount = basket_total - budget

	checkout_mode = "remove_last_item"

	checkout_text.text = "Cashier: You are €%d over budget.\nMaybe put back %s (€%d)?" % [
		over_amount,
		last_item["name"],
		last_item["price"]
	]

	yes_button.text = "1. Put Back"
	no_button.text = "2. Keep Shopping"

func remove_last_item():
	if basket_items.is_empty():
		return

	var last_item = basket_items.pop_back()
	basket_total -= last_item["price"]

	update_budget_ui()

	checkout_mode = "normal"
	yes_button.text = "1. Yes"
	no_button.text = "2. No"

	if basket_total <= budget:
		checkout_text.text = "Cashier: Good choice.\nNew total: €%d.\nReady to pay?" % basket_total
	else:
		suggest_remove_last_item()

func complete_checkout():
	yes_button.disabled = true
	no_button.disabled = true

	budget -= basket_total
	update_budget_ui()

	checkout_text.text = "Cashier: Thank you for shopping!"
	show_message("Going outside...")

	await get_tree().create_timer(2.0).timeout

	get_tree().change_scene_to_file("res://scenes/street.tscn")

func _on_checkout_no_pressed():
	checkout_panel.visible = false

	checkout_mode = "normal"
	yes_button.text = "1. Yes"
	no_button.text = "2. No"

	show_message("Cashier: You can keep shopping.")
