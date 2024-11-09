# HomingEnemy.gd
extends Area2D

# Movement settings
var base_speed = 150
var current_speed = 0
var max_speed = 150
var acceleration = 400
var drag = 200
var turn_speed = 3.0  # How fast the enemy can turn

# Homing settings
var detection_radius = 700
var homing_strength = 0.55
var velocity = Vector2.ZERO
var target_direction = Vector2.ZERO

# References
var player = null
var player_scene = "res://Scenes/GameOver.tscn"
var is_homing = false

# Speed multiplier for slow field
var speed_multiplier = 1.0

func _ready():
	connect("body_entered", self, "_on_Enemy_body_entered")
	player = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta):
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player < detection_radius:
			is_homing = true
			# Calculate direction to player
			var to_player = (player.global_position - global_position).normalized()
			# Smoothly rotate target direction towards player
			target_direction = lerp(target_direction, to_player, turn_speed * delta)
		
		# Apply acceleration in target direction
		if is_homing:
			# Accelerate towards target direction
			velocity += target_direction * acceleration * delta * speed_multiplier  # Apply multiplier
			
			# Limit speed
			if velocity.length() > max_speed * speed_multiplier:  # Apply multiplier to max speed
				velocity = velocity.normalized() * max_speed * speed_multiplier
		else:
			# Continue in initial direction with acceleration
			velocity += target_direction * acceleration * delta * speed_multiplier
			if velocity.length() > max_speed * speed_multiplier:
				velocity = velocity.normalized() * max_speed * speed_multiplier
		
		# Apply drag
		var speed = velocity.length()
		if speed > 0:
			var drag_amount = min(speed, drag * delta)
			velocity = velocity.normalized() * (speed - drag_amount)
		
		# Update position
		position += velocity * delta

func initialize(spawn_pos, target_pos):
	position = spawn_pos
	# Set initial direction and velocity
	target_direction = (target_pos - spawn_pos).normalized()
	# Start with some initial velocity
	velocity = target_direction * (max_speed * 0.5)
	current_speed = max_speed * 0.5

func set_movement_properties(new_speed, detection_range, turn_strength):
	max_speed = new_speed
	detection_radius = detection_range
	# Adjust these based on the turn strength (0-1)
	turn_speed = 2.0 + (turn_strength * 2.0)  # 2-4 range
	acceleration = 300 + (turn_strength * 200)  # 300-500 range
	drag = 150 + (turn_strength * 100)  # 150-250 range

func apply_speed_multiplier(multiplier):
	speed_multiplier = multiplier

func _on_Enemy_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
