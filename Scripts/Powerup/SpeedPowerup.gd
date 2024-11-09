# PowerUp.gd
extends Area2D

signal collected

var lifetime = 5.0  # How long the power-up stays on screen
var speed_boost = 400  # How much extra speed to give
var boost_duration = 3.0  # How long the speed boost lasts
var despawn_timer: Timer

func _ready():
	# Connect the body entered signal
	connect("body_entered", self, "_on_PowerUp_body_entered")
	
	# Create despawn timer
	despawn_timer = Timer.new()
	despawn_timer.wait_time = lifetime
	despawn_timer.one_shot = true
	despawn_timer.connect("timeout", self, "_on_DespawnTimer_timeout")
	add_child(despawn_timer)
	despawn_timer.start()

func _on_SpeedPowerup_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("collected", speed_boost, boost_duration)
		queue_free()

func _on_DespawnTimer_timeout():
	queue_free()
