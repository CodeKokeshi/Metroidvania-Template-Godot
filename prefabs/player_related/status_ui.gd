extends CanvasLayer

@onready var health_bar: TextureProgressBar = $"Health"

var health_manager: Node = null


func _ready() -> void:
	health_manager = get_node_or_null("/root/HealthManager")
	if health_manager == null:
		_apply_health_values(int(health_bar.value), max(1, int(health_bar.max_value)))
		return

	health_manager.connect("health_changed", Callable(self, "_on_health_changed"))
	_on_health_changed(
		int(health_manager.call("get_current_health")),
		int(health_manager.call("get_max_health"))
	)


func _on_health_changed(current_health: int, max_health: int) -> void:
	_apply_health_values(current_health, max_health)


func _apply_health_values(current_health: int, max_health: int) -> void:
	var clamped_max: int = max(1, max_health)
	health_bar.min_value = 0
	health_bar.max_value = clamped_max
	health_bar.value = clampi(current_health, 0, clamped_max)
