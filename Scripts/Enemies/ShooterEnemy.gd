# ShooterEnemy.gd
extends Area2D

# Movement
var speed = 80  # Slower than basic enemy
var direction = Vector2.ZERO
var player_scene = "res://Scenes/GameOver.tscn"

# Shooting
var Projectile = preload("res://Scenes/Enemies/Projectile.tscn")
var can_shoot = true
var shoot_timer: Timer
var shoot_delay = 2.0  # Time between shots
var projectile_speed = 200
var projectiles_per_burst = 8  # Number of projectiles in circular pattern

func _ready():
	add_to_group("Enemy")
	# Connect the body entered signal for player collision
	connect("body_entered", self, "_on_Enemy_body_entered")
	
	# Setup shooting timer
	shoot_timer = Timer.new()
	add_child(shoot_timer)
	shoot_timer.wait_time = shoot_delay
	shoot_timer.connect("timeout", self, "_on_ShootTimer_timeout")
	shoot_timer.start()

func _physics_process(delta):
	position += direction * speed * delta

func initialize(spawn_pos, target_pos):
	position = spawn_pos
	direction = (target_pos - spawn_pos).normalized()
	
	# Make the shooter enemy larger
	scale = Vector2(2, 2)  # Twice the size of regular enemies

func shoot():
	# Shoot projectiles in a circular pattern
	for i in range(projectiles_per_burst):
		var angle = (2 * PI * i) / projectiles_per_burst
		var projectile_direction = Vector2(cos(angle), sin(angle))
		
		var projectile = Projectile.instance()
		projectile.speed = projectile_speed
		projectile.initialize(position, projectile_direction)
		get_tree().get_root().add_child(projectile)

func _on_ShootTimer_timeout():
	shoot()

# This is the function that kills the player on contact
func _on_Enemy_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene(player_scene)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
