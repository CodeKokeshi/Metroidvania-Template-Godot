extends Node

signal health_changed(current_health: int, max_health: int)
signal health_depleted()

const MIN_HEALTH: int = 0

var _max_health: int = 100
var _current_health: int = 100


func _ready() -> void:
	_emit_health_changed()


func set_level_base_health(max_health: int, refill_current: bool = true) -> void:
	set_max_health(max_health, refill_current)


func set_max_health(max_health: int, refill_current: bool = false) -> int:
	_max_health = max(MIN_HEALTH, max_health)
	if refill_current:
		_current_health = _max_health
	else:
		_current_health = clampi(_current_health, MIN_HEALTH, _max_health)
	_emit_health_changed()
	if _current_health <= MIN_HEALTH:
		health_depleted.emit()
	return _max_health


func set_current_health(new_health: int) -> int:
	_current_health = clampi(new_health, MIN_HEALTH, _max_health)
	_emit_health_changed()
	if _current_health <= MIN_HEALTH:
		health_depleted.emit()
	return _current_health


func apply_damage(amount: int) -> int:
	if amount <= 0:
		return _current_health
	return set_current_health(_current_health - amount)


func heal(amount: int) -> int:
	if amount <= 0:
		return _current_health
	return set_current_health(_current_health + amount)


func restore_full_health() -> void:
	set_current_health(_max_health)


func get_current_health() -> int:
	return _current_health


func get_health() -> int:
	return get_current_health()


func get_max_health() -> int:
	return _max_health


func get_missing_health() -> int:
	return _max_health - _current_health


func get_health_ratio() -> float:
	if _max_health <= 0:
		return 0.0
	return float(_current_health) / float(_max_health)


func has_full_health() -> bool:
	return _current_health >= _max_health


func is_dead() -> bool:
	return _current_health <= MIN_HEALTH


func _emit_health_changed() -> void:
	health_changed.emit(_current_health, _max_health)
