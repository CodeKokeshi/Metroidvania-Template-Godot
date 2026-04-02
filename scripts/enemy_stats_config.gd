extends Node

# Centralized enemy stats.
# Keep all enemy damage and hp values here.
@export var bluecrawler_damage: int = 25
@export var bluecrawler_hp: int = 50


func get_enemy_damage(enemy_key: StringName) -> int:
	match String(enemy_key):
		"blue_crawler", "bluecrawler":
			return max(0, bluecrawler_damage)
		_:
			return 0


func get_enemy_hp(enemy_key: StringName) -> int:
	match String(enemy_key):
		"blue_crawler", "bluecrawler":
			return max(0, bluecrawler_hp)
		_:
			return 0
