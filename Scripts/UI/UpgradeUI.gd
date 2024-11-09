# UpgradeUI.gd
extends Control

var upgrades = [
	{
		"name": "Attack Cooldown",
		"description": "Reduce attack cooldown by 2 seconds",
		"type": "cooldown",
		"rarity": "common"
	},
	{
		"name": "Slow Field",
		"description": "Slow down nearby enemies",
		"type": "slowfield",
		"rarity": "common"
	},
	{
		"name": "Less Enemies",
		"description": "Reduce enemy spawn rate",
		"type": "less_enemies",
		"rarity": "common"
	},
	{
		"name": "Shield",
		"description": "Protect from one hit",
		"type": "shield",
		"rarity": "rare"
	},
	{
		"name": "Shorter Wave",
		"description": "Reduce next wave duration",
		"type": "shorter_wave",
		"rarity": "common"
	},
	{
		"name": "Bigger Attack",
		"description": "Increase attack radius",
		"type": "bigger_attack",
		"rarity": "common"
	}
]

var selected_upgrades = []

func _ready():
	hide()
	# Connect button signals
	$ButtonContainer/Button1.connect("pressed", self, "_on_Button1_pressed")
	$ButtonContainer/Button2.connect("pressed", self, "_on_Button2_pressed")
	$ButtonContainer/Button3.connect("pressed", self, "_on_Button3_pressed")

func show_upgrades():
	# Shuffle and pick 3 random upgrades
	randomize()
	upgrades.shuffle()
	selected_upgrades = upgrades.slice(0, 2)
	
	# Update button text and show UI
	for i in range(3):
		var button = $ButtonContainer.get_child(i)
		var upgrade = selected_upgrades[i]
		button.text = upgrade.name + "\n" + upgrade.description
		if upgrade.rarity == "rare":
			button.modulate = Color(1, 0.8, 0)  # Golden color for rare upgrades
		else:
			button.modulate = Color(1, 1, 1)  # Reset to normal color
	
	show()
	get_tree().paused = true

func _on_Button1_pressed():
	apply_upgrade(0)

func _on_Button2_pressed():
	apply_upgrade(1)

func _on_Button3_pressed():
	apply_upgrade(2)

func apply_upgrade(index):
	var upgrade = selected_upgrades[index]
	var player = get_tree().get_nodes_in_group("Player")[0]
	var wave_manager = get_tree().get_nodes_in_group("WaveManager")[0]
	
	match upgrade.type:
		"cooldown":
			player.upgrade_attack_cooldown()
		"slowfield":
			player.upgrade_slow_field()
		"less_enemies":
			wave_manager.reduce_enemy_spawns()
		"shield":
			player.add_shield()
		"shorter_wave":
			wave_manager.reduce_wave_time()
		"bigger_attack":
			player.upgrade_attack_radius()
	
	# Hide the upgrade UI and unpause the game
	hide()
	get_tree().paused = false
