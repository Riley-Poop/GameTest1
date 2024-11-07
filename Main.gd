extends Node2D

export var min_spawn_time = 10.0
export var max_spawn_time = 60.0

# Define spawn area using Vector2
export(Vector2) var spawn_area_min = Vector2(-927, -504)  # Top-left corner
export(Vector2) var spawn_area_max = Vector2(920, 505)    # Bottom-right corner

var PowerUp = preload("res://Scenes/Powerups/SpeedPowerup.tscn")
var spawn_timer: Timer

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.connect("timeout", self, "_on_SpawnTimer_timeout")
	add_child(spawn_timer)
	start_spawn_timer()

func start_spawn_timer():
	spawn_timer.wait_time = rand_range(min_spawn_time, max_spawn_time)
	spawn_timer.start()

func spawn_power_up():
	var power_up = PowerUp.instance()
	
	# Get random position between the two Vector2 points
	var random_x = rand_range(spawn_area_min.x, spawn_area_max.x)
	var random_y = rand_range(spawn_area_min.y, spawn_area_max.y)
	
	# Set the position
	power_up.position = Vector2(random_x, random_y)
	
	# Connect the collected signal
	power_up.connect("collected", self, "_on_PowerUp_collected")
	
	add_child(power_up)
	start_spawn_timer()

func _on_PowerUp_collected(speed_boost, duration):
	var player = get_tree().get_nodes_in_group("Player")[0]
	if player:
		player.apply_speed_boost(speed_boost, duration)

func _on_SpawnTimer_timeout():
	spawn_power_up()
