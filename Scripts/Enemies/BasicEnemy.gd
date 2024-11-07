extends Area2D

var speed = 200
var direction = Vector2.ZERO
var player_scene = "res://Scenes/GameOver.tscn"  # Change this to your game over scene path

func _ready():
	connect("body_entered", self, "_on_Enemy_body_entered")

func _physics_process(delta):
	position += direction * speed * delta

func initialize(spawn_pos, target_pos):
	position = spawn_pos
	# Calculate direction toward target (will stay constant)
	direction = (target_pos - spawn_pos).normalized()

func _on_BasicEnemy_body_entered(body):
	if body.is_in_group("Player"):
		# Load game over scene
		get_tree().change_scene(player_scene)

# Delete enemy if it goes too far off screen
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
