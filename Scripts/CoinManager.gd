# CoinManager.gd
extends Node2D

var Coin = preload("res://Scenes/Powerups/Coin.tscn")
var coins_collected = 0
var coins_needed = 10
var max_coins_on_screen = 3

onready var coin_label = $CanvasLayer/CoinLabel
onready var upgrade_ui = $CanvasLayer/UpgradeUI

func _ready():
	randomize()  # Initialize random number generator
	update_coin_label()
	# Initial spawn of 3 coins
	spawn_initial_coins()

func spawn_initial_coins():
	for i in range(max_coins_on_screen):
		spawn_single_coin()

func spawn_single_coin():
	var coin = Coin.instance()
	coin.add_to_group("Coin")
	
	# Get random position within camera view
	var camera = get_tree().get_nodes_in_group("Camera")[0]
	var screen_size = get_viewport().get_visible_rect().size
	var pos = Vector2(
		rand_range(-screen_size.x/2, screen_size.x/2),
		rand_range(-screen_size.y/2, screen_size.y/2)
	) + camera.global_position
	
	coin.position = pos
	coin.connect("coin_collected", self, "_on_coin_collected")
	add_child(coin)

func _on_coin_collected():
	coins_collected += 1
	update_coin_label()
	
	if coins_collected >= coins_needed:
		show_upgrade_selection()
		coins_collected = 0
	
	# Immediately spawn a new coin to replace the collected one
	spawn_single_coin()

func update_coin_label():
	coin_label.text = str(coins_collected) + "/" + str(coins_needed)

func show_upgrade_selection():
	upgrade_ui.show_upgrades()

func _on_upgrade_selected(upgrade_type):
	match upgrade_type:
		"cooldown":
			get_node("/root/Player").attack_cooldown = max(0, get_node("/root/Player").attack_cooldown - 2)
		"slowfield":
			get_node("/root/Player").slow_field_strength += 0.2
		"less_enemies":
			get_node("/root/WaveManager").reduce_enemy_spawns()
		"shield":
			get_node("/root/Player").add_shield()
		"shorter_wave":
			get_node("/root/WaveManager").reduce_wave_time()
		"bigger_attack":
			get_node("/root/Player").attack_radius += 50
	
	update_coin_label()
