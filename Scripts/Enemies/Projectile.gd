# Projectile.gd
extends Area2D

var speed = 200
var direction = Vector2.ZERO
var player_scene = "res://Scenes/GameOver.tscn"

func _ready():
	connect("body_entered", self, "_on_Projectile_body_entered")

func _physics_process(delta):
	position += direction * speed * delta

func initialize(start_pos, dir):
	position = start_pos
	direction = dir.normalized()

func _on_Projectile_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene(player_scene)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
