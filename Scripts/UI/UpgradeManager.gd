# UpgradeManager.gd
extends Node

signal coins_updated(current_coins)

var coins_collected = 0
var coins_required = 10
var coin_scene = preload("res://Scenes/Powerups/Coin.tscn")
var active_coins = []
var available_upgrades = [
	{
		"name": "Attack Cooldown",
		"description": "Reduce attack cooldown by 2 seconds",
		"type": "cooldown",
		"value": 2,
		"weight": 10  # Normal chance
	},
	{
		"name": "Slow Field",
		"description": "Slow nearby enemies",
		"type": "slow_field",
		"value": 0.2,  # 20% slower
		"weight": 10
	},
	{
		"name": "Less Enemies",
		"description": "Reduce enemy spawn rate",
		"type": "less_enemies",
		"value": 0.1,  # 10% less enemies
		"weight": 10
	},
	{
		"name": "Shield",
		"description": "One-time protection from damage",
		"type": "shield",
		"value": 1,
		"weight": 3  # Rare
	},
	{
		"name": "Shorter Wave",
		"description": "Reduce next wave duration",
		"type": "wave_time",
		"value": 5,  # 5 seconds less
		"weight": 10
	},
	{
		"name": "Bigger Attack",
		"description": "Increase attack radius",
		"type": "attack_radius",
		"value": 20,  # Increase by 20 units
		"weight": 10
	}
]

onready var coin_counter_label = $CanvasLayer/CoinCounter
onready var upgrade_panel = $CanvasLayer/UpgradePanel
onready var upgrade_buttons = []  # Will be populated with the three button nodes

func _ready():
	upgrade_panel.visible = false
	update_coin_counter()
	setup_upgrade_buttons()

func setup_upgrade_buttons():
	# Setup your three upgrade option buttons here
	for button in upgrade_buttons:
		button.connect("pressed", self, "_on_upgrade_selected", [button])

func spawn_coin():
	var coin = coin_scene.instance()
	var spawn_pos = get_random_position()
	coin.position = spawn_pos
	coin.connect("collected", self, "_on_coin_collected")
	active_coins.append(coin)
	add_child(coin)

func get_random_position():
	# Get a random position within the playable area
	var camera = get_tree().get_nodes_in_group("Camera")[0]
	var screen_size = get_viewport().get_visible_rect().size
	var margin = 50
	
	return Vector2(
		rand_range(camera.global_position.x - screen_size.x/2 + margin, 
				  camera.global_position.x + screen_size.x/2 - margin),
		rand_range(camera.global_position.y - screen_size.y/2 + margin,
				  camera.global_position.y + screen_size.y/2 - margin)
	)

func _on_coin_collected():
	coins_collected += 1
	update_coin_counter()
	
	if coins_collected >= coins_required:
		show_upgrade_selection()
		clear_remaining_coins()

func update_coin_counter():
	coin_counter_label.text = str(coins_collected) + "/" + str(coins_required)

func clear_remaining_coins():
	for coin in active_coins:
		if is_instance_valid(coin):
			coin.queue_free()
	active_coins.clear()
	coins_collected = 0

func show_upgrade_selection():
	# Shuffle and pick 3 random upgrades
	var shuffled_upgrades = []
	var temp_upgrades = available_upgrades.duplicate()
	
	# Create weighted list based on weights
	var weighted_list = []
	for upgrade in temp_upgrades:
		for i in range(upgrade.weight):
			weighted_list.append(upgrade)
	
	# Pick 3 random upgrades from weighted list
	for i in range(3):
		if weighted_list.size() > 0:
			var index = randi() % weighted_list.size()
			shuffled_upgrades.append(weighted_list[index])
			# Remove all instances of this upgrade from weighted list
			weighted_list = weighted_list.filter(func(item): return item.type != shuffled_upgrades[-1].type)
	
	# Update the buttons with the selected upgrades
	for i in range(min(3, shuffled_upgrades.size())):
		var button = upgrade_buttons[i]
		var upgrade = shuffled_upgrades[i]
		button.text = upgrade.name + "\n" + upgrade.description
		button.upgrade_data = upgrade
	
	upgrade_panel.visible = true
	get_tree().paused = true  # Pause the game while selecting

func _on_upgrade_selected(button):
	var upgrade = button.upgrade_data
	apply_upgrade(upgrade)
	upgrade_panel.visible = false
	get_tree().paused = false
	update_coin_counter()

func apply_upgrade(upgrade):
	match upgrade.type:
		"cooldown":
			var player = get_tree().get_nodes_in_group("Player")[0]
			player.attack_cooldown = max(0, player.attack_cooldown - upgrade.value)
		
		"slow_field":
			var player = get_tree().get_nodes_in_group("Player")[0]
			if !player.has_slow_field:
				player.has_slow_field = true
			player.slow_field_strength += upgrade.value
		
		"less_enemies":
			var wave_manager = get_node("/root/WaveManager")  # Adjust path as needed
			wave_manager.spawn_reduction_per_wave += upgrade.value
		
		"shield":
			var player = get_tree().get_nodes_in_group("Player")[0]
			player.has_shield = true
		
		"wave_time":
			var wave_manager = get_node("/root/WaveManager")
			wave_manager.current_wave_duration -= upgrade.value
		
		"attack_radius":
			var player = get_tree().get_nodes_in_group("Player")[0]
			player.attack_radius += upgrade.value

func _on_spawn_timer_timeout():
	if active_coins.size() < 5:  # Limit maximum coins on screen
		spawn_coin()
