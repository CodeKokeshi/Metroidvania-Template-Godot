extends Node

# Centralized player stats.
# Future upgrades should mutate these values instead of hardcoding in combat scripts.
@export var player_hp: int = 100
@export var player_sword_attack: int = 25
@export var player_gun_attack: int = 25


func get_player_hp() -> int:
	return max(0, player_hp)


func get_sword_attack() -> int:
	return max(0, player_sword_attack)


func get_gun_attack() -> int:
	return max(0, player_gun_attack)
