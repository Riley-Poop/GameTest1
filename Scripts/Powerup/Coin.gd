# Coin.gd
extends Area2D

signal coin_collected

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_Coin_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("coin_collected")
		queue_free()
