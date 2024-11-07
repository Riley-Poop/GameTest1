extends KinematicBody2D

# Movement variables
var base_speed = 350
var base_dash_speed = 600
var dash_speed = base_dash_speed
var dash_duration = 0.2
var dash_cooldown = 0.5

# Momentum variables
var acceleration = 4000
var friction = 2500
var max_speed = 350

# State variables
var velocity = Vector2()
var movement_direction = Vector2()
var is_dashing = false
var dash_time_remaining = 0
var cooldown_time_remaining = 0
var speed_boost_timer = 0.0
var has_speed_boost = false

# Attack variables
var attack_cooldown = 20.0
var attack_cooldown_remaining = 0.0
var attack_radius = 200
var can_attack = true

# Nodes
onready var attack_circle = $AttackCircle
onready var attack_indicator = $CooldownIndicator  # Your existing sprite node

func _ready():
	add_to_group("Player")
	
	# Create the attack circle if it doesn't exist
	if !has_node("AttackCircle"):
		var circle = Sprite.new()
		circle.texture = preload("res://Extra/Sprites/cirlce.png")
		circle.name = "AttackCircle"
		add_child(circle)
		attack_circle = circle
	
	# Setup initial circle properties
	attack_circle.modulate = Color(1, 1, 1, 0.4)
	var circle_scale = (attack_radius * 2.0) / attack_circle.texture.get_width()
	attack_circle.scale = Vector2(circle_scale, circle_scale)
	attack_circle.visible = false
	
	# Make sure attack indicator is showing at start since attack is ready
	attack_indicator.visible = true

func _physics_process(delta):
	# Handle attack cooldown
	if attack_cooldown_remaining > 0:
		attack_cooldown_remaining -= delta
		if attack_cooldown_remaining <= 0:
			can_attack = true
			# Show indicator when attack is ready again
			attack_indicator.visible = true
	
	# Check for attack input
	if Input.is_action_just_pressed("attack") and can_attack:
		perform_attack()
	
	# Handle speed boost timer
	if speed_boost_timer > 0:
		speed_boost_timer -= delta
		if speed_boost_timer <= 0:
			max_speed = base_speed
			dash_speed = base_dash_speed
			has_speed_boost = false

	# Handle dash cooldown
	if cooldown_time_remaining > 0:
		cooldown_time_remaining -= delta

	if is_dashing:
		move_and_slide(velocity)
		dash_time_remaining -= delta
		if dash_time_remaining <= 0:
			is_dashing = false
			velocity = velocity * 0.5
	else:
		movement_direction = Vector2()
		if Input.is_action_pressed("move_right"):
			movement_direction.x += 1
		if Input.is_action_pressed("move_left"):
			movement_direction.x -= 1
		if Input.is_action_pressed("move_down"):
			movement_direction.y += 1
		if Input.is_action_pressed("move_up"):
			movement_direction.y -= 1
		
		movement_direction = movement_direction.normalized()

		if movement_direction != Vector2.ZERO:
			velocity = velocity.move_toward(movement_direction * max_speed, acceleration * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

		if Input.is_action_just_pressed("dash") and cooldown_time_remaining <= 0 and movement_direction != Vector2.ZERO:
			start_dash()
		
		velocity = move_and_slide(velocity)

func perform_attack():
	can_attack = false
	attack_cooldown_remaining = attack_cooldown
	# Hide indicator when attack is used
	attack_indicator.visible = false
	
	# Show attack effect
	show_attack_effect()
	
	# Get all enemies in radius
	var space_state = get_world_2d().direct_space_state
	var enemies = get_tree().get_nodes_in_group("Enemy")
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= attack_radius:
			enemy.queue_free()

func show_attack_effect():
	attack_circle.visible = true
	
	# Create a tween for the attack animation
	var tween = Tween.new()
	add_child(tween)
	
	# Reset circle properties
	attack_circle.modulate = Color(1, 1, 1, 0.4)
	attack_circle.scale = Vector2.ONE * ((attack_radius * 2.0) / attack_circle.texture.get_width())
	
	# Animate the circle
	tween.interpolate_property(attack_circle, "modulate",
		Color(1, 1, 1, 0.4), Color(1, 1, 1, 0),
		0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	tween.start()
	
	# Hide circle after animation
	yield(tween, "tween_completed")
	attack_circle.visible = false
	tween.queue_free()

func start_dash():
	is_dashing = true
	dash_time_remaining = dash_duration
	cooldown_time_remaining = dash_cooldown
	velocity = movement_direction * dash_speed

func apply_speed_boost(boost_amount, duration):
	has_speed_boost = true
	max_speed = base_speed + boost_amount
	dash_speed = base_dash_speed * 2
	speed_boost_timer = duration
