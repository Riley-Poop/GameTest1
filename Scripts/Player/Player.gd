extends KinematicBody2D

# Speed variables
var original_speed = 300  # Default speed
var speed = original_speed  # Current speed
var boosted_speed = 800  # Boosted speed (for reference, but overridden on pickup)
var dash_speed = 650
var dash_duration = 0.2  # Duration in seconds
var dash_cooldown = 1.0  # Cooldown time between dashes
var velocity = Vector2()

# Dash and boost states
var is_dashing = false
var dash_time_remaining = 0
var cooldown_time_remaining = 0

func _ready():
	# Ensure the timer node exists and connect the timeout signal
	$BoostTimer.connect("timeout", self, "_end_speed_boost")

func start_speed_boost(boost_speed, duration):
	speed = boost_speed  # Set to boosted speed
	$BoostTimer.start(duration)  # Start timer for boost duration

func _end_speed_boost():
	speed = original_speed  # Reset to original speed after the boost ends

func _physics_process(delta):
	# Handle dash cooldown
	if cooldown_time_remaining > 0:
		cooldown_time_remaining -= delta

	if is_dashing:
		# Dash in the current direction and reduce dash time
		move_and_slide(velocity)
		dash_time_remaining -= delta
		if dash_time_remaining <= 0:
			is_dashing = false
			velocity = Vector2()  # Stop movement after dash completes
	else:
		# Handle normal movement if not dashing
		velocity = Vector2()
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1

		# Normalize and apply speed for regular movement
		if velocity != Vector2():
			velocity = velocity.normalized() * speed
		
		# Check for dash input and start dash if available
		if Input.is_action_just_pressed("dash") and cooldown_time_remaining <= 0 and velocity != Vector2():
			start_dash()

		# Regular movement
		move_and_slide(velocity)

func start_dash():
	# Set dash state
	is_dashing = true
	dash_time_remaining = dash_duration
	cooldown_time_remaining = dash_cooldown
	velocity = velocity.normalized() * dash_speed
