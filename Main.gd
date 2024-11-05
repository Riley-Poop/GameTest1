extends Node2D

# Define the spawn area boundaries
var min_position = Vector2(-941, -519)
var max_position = Vector2(930, 514)
var speed_power_up_scene = preload("res://Scenes/Powerups/Speed Powerup.tscn")

# Player speed settings
var original_speed = 300  # Player's regular speed
var boosted_speed = 800   # Boosted speed
var boost_duration = 5    # Boost duration in seconds

func _ready():
	# Start the timer with a random interval between 20 and 60 seconds
	reset_power_up_timer()

# This function is triggered every time the timer times out
func _on_power_up_timer_timeout():
	spawn_power_up()
	reset_power_up_timer()  # Reset timer with a new random interval

# Function to spawn a power-up at a random position within the defined area
func spawn_power_up():
	var power_up_instance = speed_power_up_scene.instance()
	
	var random_x = min_position.x + randf() * (max_position.x - min_position.x)
	var random_y = min_position.y + randf() * (max_position.y - min_position.y)
	power_up_instance.position = Vector2(random_x, random_y)
	
	power_up_instance.connect("collected", self, "_on_power_up_collected")
	add_child(power_up_instance)

# This function handles the power-up collection event
func _on_power_up_collected():
	# Pass the boosted speed and duration to the player
	$Player.start_speed_boost(boosted_speed, boost_duration)

# Function to reset the timer with a random interval
func reset_power_up_timer():
	var random_interval = 20.0 + randf() * 40.0  # Random time between 20 and 60 seconds
	$power_up_timer.start(random_interval)
