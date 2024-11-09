# CoinManager.gd
extends Node2D

var Coin = preload("res://Scenes/Coin.tscn")
var coins_collected = 0
var coins_needed = 10
var coins_to_spawn = 3

onready var coin_label = $CanvasLayer/CoinLabel
onready var upgrade_ui = $CanvasLayer/UpgradeUI

func _ready():
	update_coin_label()
	spawn_coins()

func spawn_coins():
	for i in range(coins_to_spawn):
		var coin = Coin.instance()
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
	elif get_tree().get_nodes_in_group("Coin").size() <= coins_to_spawn:
		spawn_coins()

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
	spawn_coins()
