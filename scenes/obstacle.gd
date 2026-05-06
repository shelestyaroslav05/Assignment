extends Area2D

@export var speed := 300.0
@export var normal_texture: Texture2D
@export var broken_texture: Texture2D

var is_hit := false

@onready var sprite = $ObstacleSprite
@onready var collision = $CollisionShape2D

func _ready():
	add_to_group("obstacles")

	if normal_texture != null:
		sprite.texture = normal_texture

	body_entered.connect(_on_body_entered)

func _process(delta):
	var game = get_tree().current_scene
	if game != null and game.has_method("is_game_active"):
		if not game.is_game_active():
			return

	position.y += speed * delta

	if position.y > 900:
		queue_free()

func _on_body_entered(body):
	if is_hit:
		return

	var game = get_tree().current_scene

	if game == null:
		return

	if not game.has_method("player_hit"):
		return

	if body.name != "PlayerCar":
		return

	is_hit = true
	collision.set_deferred("disabled", true)

	if broken_texture != null:
		sprite.texture = broken_texture

	game.player_hit()

	await get_tree().create_timer(0.4).timeout
	queue_free()
