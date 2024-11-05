extends Area2D

signal collected  # Signal to notify when the power-up is collected

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body.is_in_group("Player"):  # Ensure only the player can collect it
		emit_signal("collected")  # Signal the collection
		queue_free()  # Remove the power-up from the scene
