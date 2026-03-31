extends Node

@export var target_group_name: StringName = &"pausables"
@export var debug_logs: bool = false

var _is_hit_pause_active: bool = false
var _hit_pause_end_time_sec: float = 0.0
var _paused_node_modes: Dictionary = {}


func request_hit_pause(duration_sec: float) -> void:
	if duration_sec <= 0.0:
		return

	if _is_hit_pause_active:
		return

	var now_sec: float = Time.get_ticks_usec() / 1000000.0
	_hit_pause_end_time_sec = now_sec + duration_sec

	_apply_hit_pause_to_group()
	_is_hit_pause_active = true


func _process(_delta: float) -> void:
	if not _is_hit_pause_active:
		return

	var now_sec: float = Time.get_ticks_usec() / 1000000.0
	if now_sec < _hit_pause_end_time_sec:
		return

	_restore_group_after_hit_pause()
	_is_hit_pause_active = false


func _apply_hit_pause_to_group() -> void:
	_paused_node_modes.clear()
	var pausables: Array[Node] = get_tree().get_nodes_in_group(target_group_name)
	var paused_count: int = 0
	for node in pausables:
		if node == null or node == self:
			continue

		var node_id: int = node.get_instance_id()
		_paused_node_modes[node_id] = node.process_mode
		node.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		paused_count += 1

	if debug_logs and paused_count <= 1:
		push_warning("[HitPause] Very few nodes paused (%d). Add gameplay nodes to group '%s' to feel impact." % [paused_count, String(target_group_name)])


func _restore_group_after_hit_pause() -> void:
	for node_id in _paused_node_modes.keys():
		var restored_node: Variant = instance_from_id(int(node_id))
		if not (restored_node is Node):
			continue

		var restored_mode: Variant = _paused_node_modes[node_id]
		if typeof(restored_mode) != TYPE_INT:
			continue

		restored_node.set_deferred("process_mode", int(restored_mode))

	_paused_node_modes.clear()
