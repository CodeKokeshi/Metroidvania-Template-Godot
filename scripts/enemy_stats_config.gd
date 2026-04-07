extends Node

# Centralized enemy stats.
# Keep all enemy damage and hp values here.
@export var blue_crawler_hp: int = 75
@export var blue_crawler_attack: int = 25

# Just sample for future additions.
# @export var red_crawler_hp: int = 100
# @export var red_crawler_attack: int = 50


func get_enemy_attack(enemy_key: StringName) -> int:
	match String(enemy_key):
		"blue_crawler", "bluecrawler":
			return max(0, blue_crawler_attack)
		_:
			return 0


func get_enemy_hp(enemy_key: StringName) -> int:
	match String(enemy_key):
		"blue_crawler", "bluecrawler":
			return max(0, blue_crawler_hp)
		_:
			return 0
