extends Area2D

var duration = 10.0  # Power-up disappears after 10 seconds


signal picked_up  # Signal to notify the player has picked it up

func _ready():
	# Set a timer to remove the power-up after its duration
	yield(get_tree().create_timer(duration), "timeout")
	queue_free()  # Remove the power-up if not picked up



func _on_Speed_Powerup_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("picked_up")  # Notify player script
		queue_free()  # Remove power-up after pickup

