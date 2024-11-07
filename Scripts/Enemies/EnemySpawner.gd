extends Node2D

export var spawn_time_min = 2.0
export var spawn_time_max = 4.0
export var enemy_speed_min = 150
export var enemy_speed_max = 250

var Enemy = preload("res://Scenes/Enemies/BasicEnemy.tscn")  # Change this to your enemy scene path
var spawn_timer: Timer
var camera: Camera2D
var screen_size: Vector2
var spawn_margin = 100  # Distance outside the screen to spawn enemies

func _ready():
	# Find the camera in the scene
	camera = get_tree().get_nodes_in_group("Camera")[0]  # Make sure to add your camera to a "Camera" group
	screen_size = get_viewport().get_visible_rect().size
	
	# Setup spawn timer
	spawn_timer = Timer.new()
	spawn_timer.connect("timeout", self, "_on_SpawnTimer_timeout")
	add_child(spawn_timer)
	start_timer()

func start_timer():
	spawn_timer.wait_time = rand_range(spawn_time_min, spawn_time_max)
	spawn_timer.start()

func _on_SpawnTimer_timeout():
	spawn_enemy()
	start_timer()

func spawn_enemy():
	var enemy = Enemy.instance()
	
	# Get camera position (center of screen)
	var camera_center = camera.global_position
	
	# Calculate spawn position outside screen view
	var spawn_side = randi() % 4  # 0: top, 1: right, 2: bottom, 3: left
	var spawn_pos = Vector2()
	var target_pos = Vector2()
	
	match spawn_side:
		0:  # Top
			spawn_pos.x = rand_range(camera_center.x - screen_size.x/2, camera_center.x + screen_size.x/2)
			spawn_pos.y = camera_center.y - screen_size.y/2 - spawn_margin
			target_pos.x = rand_range(camera_center.x - screen_size.x/2, camera_center.x + screen_size.x/2)
			target_pos.y = camera_center.y + screen_size.y/2 + spawn_margin
		1:  # Right
			spawn_pos.x = camera_center.x + screen_size.x/2 + spawn_margin
			spawn_pos.y = rand_range(camera_center.y - screen_size.y/2, camera_center.y + screen_size.y/2)
			target_pos.x = camera_center.x - screen_size.x/2 - spawn_margin
			target_pos.y = rand_range(camera_center.y - screen_size.y/2, camera_center.y + screen_size.y/2)
		2:  # Bottom
			spawn_pos.x = rand_range(camera_center.x - screen_size.x/2, camera_center.x + screen_size.x/2)
			spawn_pos.y = camera_center.y + screen_size.y/2 + spawn_margin
			target_pos.x = rand_range(camera_center.x - screen_size.x/2, camera_center.x + screen_size.x/2)
			target_pos.y = camera_center.y - screen_size.y/2 - spawn_margin
		3:  # Left
			spawn_pos.x = camera_center.x - screen_size.x/2 - spawn_margin
			spawn_pos.y = rand_range(camera_center.y - screen_size.y/2, camera_center.y + screen_size.y/2)
			target_pos.x = camera_center.x + screen_size.x/2 + spawn_margin
			target_pos.y = rand_range(camera_center.y - screen_size.y/2, camera_center.y + screen_size.y/2)
	
	# Set random speed for this enemy
	enemy.speed = rand_range(enemy_speed_min, enemy_speed_max)
	
	# Initialize enemy with spawn and target positions
	enemy.initialize(spawn_pos, target_pos)
	
	add_child(enemy)
