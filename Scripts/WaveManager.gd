extends Node2D

# Wave settings
var current_wave = 1
var base_wave_duration = 20  # Starting wave duration in seconds
var wave_duration_increase = 10  # How many seconds to add per wave
var max_wave_duration = 90  # Cap at 1 minute 30 seconds
var current_wave_duration = 20
var time_remaining = 0

# Enemy speed settings
var base_enemy_speed_min = 200  # Moderate starting speed
var base_enemy_speed_max = 300
var speed_increase_per_wave = 30  # Decent speed increase per wave

# Spawn time settings - Balanced spawning
var base_spawn_time_min = 0.8  # Spawn every 0.8 to 1.5 seconds initially
var base_spawn_time_max = 1.5
var min_spawn_time = 0.8
var max_spawn_time = 1.5
var spawn_reduction_per_wave = 0.1  # Reduce spawn time by 0.1 seconds each wave

# Enemy types and spawning
var BasicEnemy = preload("res://Scenes/Enemies/BasicEnemy.tscn")
var HomingEnemy = preload("res://Scenes/Enemies/HomingEnemy.tscn")
var ShooterEnemy = preload("res://Scenes/Enemies/ShooterEnemy.tscn")
var homing_enemy_wave = 3  # Wave when homing enemies start appearing
var shooter_enemy_wave = 5  # Wave when shooter enemies start appearing
var homing_enemy_chance = 0.3  # 30% chance for homing
var shooter_enemy_chance = 0.2  # 20% chance for shooter

# Node references
var spawn_timer: Timer
var wave_timer: Timer
var camera: Camera2D
var screen_size: Vector2
var spawn_margin = 100

# UI references
onready var wave_label = $CanvasLayer/WaveUI/WaveLabel
onready var time_label = $CanvasLayer/WaveUI/TimeLabel

func _ready():
	# Setup camera
	camera = get_tree().get_nodes_in_group("Camera")[0]
	screen_size = get_viewport().get_visible_rect().size
	
	# Setup timers
	setup_timers()
	
	# Start first wave
	start_wave()
	
	# Update UI
	update_ui()

func setup_timers():
	# Spawn timer
	spawn_timer = Timer.new()
	spawn_timer.connect("timeout", self, "_on_SpawnTimer_timeout")
	add_child(spawn_timer)
	
	# Wave timer
	wave_timer = Timer.new()
	wave_timer.connect("timeout", self, "_on_WaveTimer_timeout")
	add_child(wave_timer)

func clear_all_enemies():
	# Stop the spawn timer temporarily
	spawn_timer.stop()
	
	# Get all enemies and delete them
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		enemy.queue_free()

func start_wave():
	# Clear any remaining enemies from previous wave
	clear_all_enemies()
	
	# Calculate wave duration
	current_wave_duration = min(base_wave_duration + (current_wave - 1) * wave_duration_increase, max_wave_duration)
	time_remaining = current_wave_duration
	
	# Start timers
	wave_timer.wait_time = 1.0  # Update every second for countdown
	wave_timer.start()
	
	# Add a small delay before starting to spawn new enemies
	yield(get_tree().create_timer(1.0), "timeout")
	start_spawn_timer()

func start_spawn_timer():
	# Calculate spawn time reduction for current wave
	var spawn_reduction = (current_wave - 1) * spawn_reduction_per_wave
	
	# Calculate new spawn times with minimum caps
	min_spawn_time = max(base_spawn_time_min - spawn_reduction, 0.4)  # Won't go below 0.4 seconds
	max_spawn_time = max(base_spawn_time_max - spawn_reduction, 0.8)  # Won't go below 0.8 seconds
	
	spawn_timer.wait_time = rand_range(min_spawn_time, max_spawn_time)
	spawn_timer.start()

func _on_SpawnTimer_timeout():
	# Spawn enemies based on wave
	var enemies_to_spawn = 1
	if current_wave >= 5:
		enemies_to_spawn = 2  # Spawn 2 enemies at once after wave 5
	
	for i in range(enemies_to_spawn):
		spawn_enemy()
	start_spawn_timer()

func _on_WaveTimer_timeout():
	time_remaining -= 1
	
	if time_remaining <= 0:
		# Wave complete
		current_wave += 1
		start_wave()
	
	update_ui()

func update_ui():
	wave_label.text = "Wave: " + str(current_wave)
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	time_label.text = "Time: %02d:%02d" % [minutes, seconds]

func spawn_enemy():
	var enemy
	
	# Decide which enemy to spawn based on wave and chances
	if current_wave >= shooter_enemy_wave and randf() < shooter_enemy_chance:
		# Spawn shooter enemy
		enemy = ShooterEnemy.instance()
		# Set shooter specific properties
		enemy.speed = 80  # Slower movement
		enemy.shoot_delay = max(2.0 - (current_wave - shooter_enemy_wave) * 0.2, 0.5)  # Shoots faster in later waves
		enemy.projectile_speed = 200 + (current_wave - shooter_enemy_wave) * 20  # Faster projectiles in later waves
		enemy.projectiles_per_burst = 8 + floor((current_wave - shooter_enemy_wave) / 2)  # More projectiles in later waves
	
	elif current_wave >= homing_enemy_wave and randf() < homing_enemy_chance:
		# Spawn homing enemy
		enemy = HomingEnemy.instance()
		var wave_progression = (current_wave - homing_enemy_wave) * 0.1
		var speed = base_enemy_speed_min * 0.8 + (wave_progression * 100)
		var detection = 200 + (wave_progression * 100)
		var turn_strength = min(0.3 + wave_progression * 0.4, 0.7)
		enemy.set_movement_properties(speed, detection, turn_strength)
	else:
		# Spawn basic enemy
		enemy = BasicEnemy.instance()
		enemy.speed = rand_range(
			base_enemy_speed_min + (current_wave - 1) * speed_increase_per_wave,
			base_enemy_speed_max + (current_wave - 1) * speed_increase_per_wave
		)
	
	# Get camera position (center of screen)
	var camera_center = camera.global_position
	
	# Calculate spawn position outside screen view
	var spawn_side = randi() % 4
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
	
	enemy.initialize(spawn_pos, target_pos)
	add_child(enemy)
