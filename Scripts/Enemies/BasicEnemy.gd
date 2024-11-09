# Enemy.gd (Basic Enemy)
extends Area2D

var speed = 200
var direction = Vector2.ZERO
var player_scene = "res://Scenes/GameOver.tscn"
var speed_multiplier = 1.0

func _ready():
	add_to_group("Enemy")
	connect("body_entered", self, "_on_Enemy_body_entered")

func _physics_process(delta):
	position += direction * speed * speed_multiplier * delta

func initialize(spawn_pos, target_pos):
	position = spawn_pos
	direction = (target_pos - spawn_pos).normalized()

func apply_speed_multiplier(multiplier):
	speed_multiplier = multiplier

func _on_Enemy_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
