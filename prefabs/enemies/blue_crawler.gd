extends CharacterBody2D


enum State {
	PATROL,
	CHASE,
	CONFUSED
}

@export_group("Movement")
@export var patrol_speed: float = 34.0
@export var chase_speed: float = 68.0
@export var acceleration: float = 480.0
@export var deceleration: float = 560.0
@export var gravity: float = 980.0
@export var max_fall_speed: float = 620.0
@export var wall_check_distance: float = 10.0
@export var edge_check_forward: float = 8.0
@export var edge_check_depth: float = 20.0
@export var chase_arrive_threshold: float = 4.0

@export_group("Ledge Drop")
@export var ledge_drop_player_forward_threshold: float = 12.0
@export var ledge_drop_forward_check_distance: float = 12.0
@export var ledge_drop_max_height: float = 48.0

@export_group("Patrol Random")
@export var patrol_random_action_interval_min: float = 1.1
@export var patrol_random_action_interval_max: float = 2.4
@export var patrol_random_turn_chance: float = 0.28
@export var patrol_random_jump_chance: float = 0.16
@export var patrol_random_jump_velocity: float = -155.0
@export var patrol_random_jump_cooldown: float = 1.25

@export_group("Perception")
@export var vision_ray_origin_offset: Vector2 = Vector2(0.0, -4.0)
@export var lose_sight_grace_time: float = 0.25

@export_group("Chase Jump")
@export var chase_jump_velocity: float = -250.0
@export var chase_jump_player_above_threshold: float = 16.0
@export var chase_jump_cooldown: float = 0.55
@export var chase_stuck_timeout: float = 2.0
@export var chase_stuck_required_height_gain: float = 14.0
@export var chase_failed_jump_same_ground_distance: float = 8.0
@export var chase_failed_jump_ignore_detection_time: float = 1.2

@export_group("Confused")
@export var confused_duration: float = 2.2
@export var confused_turn_interval: float = 0.55
@export var confused_jump_enabled: bool = true
@export var confused_jump_delay: float = 0.65
@export var confused_jump_velocity: float = -170.0

const SOLID_LAYER_MASK: int = 1
const PLAYER_BODY_LAYER_MASK: int = 64

@onready var anim: AnimatedSprite2D = $"anim"
@onready var vision_cone: Area2D = $"vision_cone"
@onready var wall_check: RayCast2D = $"wall_check"

var current_state: State = State.PATROL
var facing_direction: int = -1
var lose_sight_timer: float = 0.0
var confused_timer: float = 0.0
var confused_turn_timer: float = 0.0
var confused_jump_timer: float = 0.0
var has_confused_jumped: bool = false
var target_player: CharacterBody2D = null
var base_vision_cone_scale: Vector2 = Vector2.ONE
var base_wall_check_target_position: Vector2 = Vector2.ZERO
var chase_jump_cooldown_timer: float = 0.0
var chase_vertical_attempt_active: bool = false
var chase_vertical_attempt_timer: float = 0.0
var chase_vertical_attempt_start_y: float = 0.0
var ignore_player_detection_timer: float = 0.0
var patrol_random_action_timer: float = 0.0
var patrol_random_jump_cooldown_timer: float = 0.0
var chase_jump_in_progress: bool = false
var chase_jump_left_ground: bool = false
var chase_jump_start_ground_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	base_vision_cone_scale = vision_cone.scale
	base_wall_check_target_position = wall_check.target_position
	_set_facing_direction(facing_direction)
	_reset_patrol_random_action_timer()
	_set_state(State.PATROL)


func _physics_process(delta: float) -> void:
	if target_player != null and not is_instance_valid(target_player):
		target_player = null

	ignore_player_detection_timer = maxf(0.0, ignore_player_detection_timer - delta)
	patrol_random_jump_cooldown_timer = maxf(0.0, patrol_random_jump_cooldown_timer - delta)
	chase_jump_cooldown_timer = maxf(0.0, chase_jump_cooldown_timer - delta)
	_apply_gravity(delta)

	var visible_player: CharacterBody2D = null
	if current_state == State.CHASE:
		if target_player == null:
			visible_player = _find_visible_player_with_los()
			if visible_player != null:
				target_player = visible_player

		if target_player != null and _has_line_of_sight_to(target_player):
			lose_sight_timer = lose_sight_grace_time
		else:
			lose_sight_timer = maxf(0.0, lose_sight_timer - delta)
			if lose_sight_timer <= 0.0:
				target_player = null
				_set_state(State.CONFUSED)
	else:
		if ignore_player_detection_timer <= 0.0:
			visible_player = _find_visible_player_with_los()
			if visible_player != null:
				target_player = visible_player
				lose_sight_timer = lose_sight_grace_time
				_set_state(State.CHASE)
			else:
				_clear_chase_vertical_attempt()
		else:
			_clear_chase_vertical_attempt()

	match current_state:
		State.PATROL:
			_process_patrol(delta)
		State.CHASE:
			_process_chase(delta)
		State.CONFUSED:
			_process_confused(delta)

	move_and_slide()
	_update_chase_jump_landing()
	if current_state == State.PATROL and is_on_floor() and is_on_wall():
		_flip_direction()
	_update_animation()


func _set_state(next_state: State) -> void:
	if current_state == next_state:
		return

	current_state = next_state
	match current_state:
		State.PATROL:
			_clear_chase_vertical_attempt()
			_clear_chase_jump_progress()
			wall_check.enabled = false
			_reset_patrol_random_action_timer()
			confused_timer = 0.0
			confused_turn_timer = 0.0
			confused_jump_timer = 0.0
			has_confused_jumped = false
		State.CHASE:
			_clear_chase_vertical_attempt()
			_clear_chase_jump_progress()
			wall_check.enabled = true
			confused_timer = 0.0
			confused_turn_timer = 0.0
			confused_jump_timer = 0.0
			has_confused_jumped = false
		State.CONFUSED:
			_clear_chase_vertical_attempt()
			_clear_chase_jump_progress()
			wall_check.enabled = false
			confused_timer = maxf(0.1, confused_duration)
			confused_turn_timer = maxf(0.05, confused_turn_interval)
			confused_jump_timer = maxf(0.0, confused_jump_delay)
			has_confused_jumped = false


func _process_patrol(delta: float) -> void:
	if is_on_floor():
		var front_blocked: bool = _is_front_blocked(facing_direction)
		var no_ground_ahead: bool = not _has_ground_ahead(facing_direction)
		if front_blocked:
			_flip_direction()
		elif no_ground_ahead and not _should_allow_patrol_ledge_drop():
			_flip_direction()

	_update_patrol_random_behavior(delta)

	var target_speed: float = patrol_speed * float(facing_direction)
	_apply_horizontal_speed(target_speed, delta)


func _process_chase(delta: float) -> void:
	if target_player == null:
		_clear_chase_vertical_attempt()
		_apply_horizontal_speed(0.0, delta)
		return

	var delta_x: float = target_player.global_position.x - global_position.x
	var player_is_above: bool = target_player.global_position.y < (global_position.y - chase_jump_player_above_threshold)
	if absf(delta_x) > 0.01:
		_set_facing_direction(1 if delta_x > 0.0 else -1)

	var target_speed: float = 0.0
	if absf(delta_x) > chase_arrive_threshold:
		target_speed = chase_speed * float(facing_direction)

	if player_is_above:
		_try_chase_jump(player_is_above)
		if _update_chase_vertical_attempt(delta):
			_apply_horizontal_speed(0.0, delta)
			return
	else:
		_clear_chase_vertical_attempt()

	if not player_is_above and is_on_floor() and target_speed != 0.0:
		var front_blocked: bool = _is_front_blocked(facing_direction)
		var no_ground_ahead: bool = not _has_ground_ahead(facing_direction)
		if front_blocked:
			target_speed = 0.0
		elif no_ground_ahead and not _should_allow_ledge_drop(delta_x):
			target_speed = 0.0

	_apply_horizontal_speed(target_speed, delta)


func _process_confused(delta: float) -> void:
	confused_timer = maxf(0.0, confused_timer - delta)
	confused_turn_timer = maxf(0.0, confused_turn_timer - delta)

	if confused_turn_timer <= 0.0:
		confused_turn_timer = maxf(0.05, confused_turn_interval)
		_flip_direction()

	if confused_jump_enabled and not has_confused_jumped:
		confused_jump_timer = maxf(0.0, confused_jump_timer - delta)
		if confused_jump_timer <= 0.0 and is_on_floor():
			velocity.y = confused_jump_velocity
			has_confused_jumped = true

	_apply_horizontal_speed(0.0, delta)

	if confused_timer <= 0.0:
		_set_state(State.PATROL)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + (gravity * delta), max_fall_speed)
	elif velocity.y > 0.0:
		velocity.y = 0.0


func _apply_horizontal_speed(target_speed: float, delta: float) -> void:
	var speed_step: float = acceleration if absf(target_speed) > 0.01 else deceleration
	velocity.x = move_toward(velocity.x, target_speed, speed_step * delta)


func _try_chase_jump(player_is_above: bool) -> void:
	if not player_is_above:
		return
	if not is_on_floor():
		return
	if chase_jump_cooldown_timer > 0.0:
		return
	if not _is_jump_wall_detected():
		return

	velocity.y = chase_jump_velocity
	chase_jump_cooldown_timer = maxf(0.0, chase_jump_cooldown)
	chase_jump_in_progress = true
	chase_jump_left_ground = false
	chase_jump_start_ground_position = global_position
	if not chase_vertical_attempt_active:
		chase_vertical_attempt_active = true
		chase_vertical_attempt_timer = maxf(0.1, chase_stuck_timeout)
		chase_vertical_attempt_start_y = global_position.y


func _update_chase_vertical_attempt(delta: float) -> bool:
	if not chase_vertical_attempt_active:
		return false

	var climbed_height: float = chase_vertical_attempt_start_y - global_position.y
	if climbed_height >= chase_stuck_required_height_gain:
		_clear_chase_vertical_attempt()
		return false

	chase_vertical_attempt_timer = maxf(0.0, chase_vertical_attempt_timer - delta)
	if chase_vertical_attempt_timer > 0.0:
		return false

	_lose_interest_to_patrol()
	return true


func _clear_chase_vertical_attempt() -> void:
	chase_vertical_attempt_active = false
	chase_vertical_attempt_timer = 0.0
	chase_vertical_attempt_start_y = global_position.y


func _clear_chase_jump_progress() -> void:
	chase_jump_in_progress = false
	chase_jump_left_ground = false
	chase_jump_start_ground_position = global_position


func _lose_interest_to_patrol() -> void:
	target_player = null
	lose_sight_timer = 0.0
	ignore_player_detection_timer = maxf(0.0, chase_failed_jump_ignore_detection_time)
	_clear_chase_vertical_attempt()
	_set_state(State.PATROL)


func _update_chase_jump_landing() -> void:
	if not chase_jump_in_progress:
		return

	if not is_on_floor():
		chase_jump_left_ground = true
		return

	if not chase_jump_left_ground:
		return

	var horizontal_landing_distance: float = absf(global_position.x - chase_jump_start_ground_position.x)
	var landed_on_same_ground_x: bool = horizontal_landing_distance <= chase_failed_jump_same_ground_distance
	_clear_chase_jump_progress()
	if landed_on_same_ground_x:
		_lose_interest_to_patrol()


func _is_jump_wall_detected() -> bool:
	if not wall_check.enabled:
		wall_check.enabled = true
	wall_check.force_raycast_update()
	return wall_check.is_colliding()


func _should_allow_ledge_drop(delta_x: float) -> bool:
	if target_player == null:
		return false

	var player_forward_distance: float = delta_x * float(facing_direction)
	if player_forward_distance < ledge_drop_player_forward_threshold:
		return false

	return _has_landing_within_ledge_drop_height(facing_direction)


func _should_allow_patrol_ledge_drop() -> bool:
	return _has_landing_within_ledge_drop_height(facing_direction)


func _has_landing_within_ledge_drop_height(direction: int) -> bool:
	var origin: Vector2 = global_position + Vector2(float(direction) * ledge_drop_forward_check_distance, 6.0)
	var target: Vector2 = origin + Vector2(0.0, maxf(1.0, ledge_drop_max_height))
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(origin, target)
	query.exclude = [self]
	query.collision_mask = SOLID_LAYER_MASK
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _update_patrol_random_behavior(delta: float) -> void:
	patrol_random_action_timer = maxf(0.0, patrol_random_action_timer - delta)
	if patrol_random_action_timer > 0.0:
		return

	_reset_patrol_random_action_timer()
	if not is_on_floor():
		return

	var turn_chance: float = clampf(patrol_random_turn_chance, 0.0, 1.0)
	var jump_chance: float = clampf(patrol_random_jump_chance, 0.0, 1.0)
	var roll: float = randf()
	if roll <= turn_chance:
		_flip_direction()
		return

	if roll <= (turn_chance + jump_chance):
		if patrol_random_jump_cooldown_timer <= 0.0 and _has_ground_ahead(facing_direction):
			velocity.y = patrol_random_jump_velocity
			patrol_random_jump_cooldown_timer = maxf(0.0, patrol_random_jump_cooldown)


func _reset_patrol_random_action_timer() -> void:
	var min_interval: float = maxf(0.1, patrol_random_action_interval_min)
	var max_interval: float = maxf(min_interval, patrol_random_action_interval_max)
	patrol_random_action_timer = randf_range(min_interval, max_interval)


func _flip_direction() -> void:
	_set_facing_direction(-facing_direction)


func _set_facing_direction(direction: int) -> void:
	if direction == 0:
		return

	facing_direction = -1 if direction < 0 else 1
	anim.flip_h = facing_direction < 0
	vision_cone.scale = Vector2(absf(base_vision_cone_scale.x) * float(facing_direction), base_vision_cone_scale.y)
	var ray_distance: float = absf(base_wall_check_target_position.x)
	wall_check.target_position = Vector2(ray_distance * float(facing_direction), base_wall_check_target_position.y)


func _update_animation() -> void:
	var target_animation: StringName = &"default"
	if current_state == State.CONFUSED and anim.sprite_frames != null and anim.sprite_frames.has_animation(&"hide"):
		target_animation = &"hide"

	if anim.animation != target_animation:
		anim.play(target_animation)

	var run_reference: float = maxf(chase_speed, 1.0)
	if target_animation == &"default":
		anim.speed_scale = clampf(absf(velocity.x) / run_reference, 0.75, 1.4)
	else:
		anim.speed_scale = 1.0


func _find_visible_player_with_los() -> CharacterBody2D:
	var bodies: Array[Node2D] = vision_cone.get_overlapping_bodies()
	for body in bodies:
		if not _is_player_body(body):
			continue
		var player_body: CharacterBody2D = body as CharacterBody2D
		if player_body == null:
			continue
		if _has_line_of_sight_to(player_body):
			return player_body
	return null


func _is_player_body(body: Node2D) -> bool:
	if body == null:
		return false
	if body.is_in_group("player"):
		return true
	if body is PhysicsBody2D:
		var physics_body: PhysicsBody2D = body as PhysicsBody2D
		return (physics_body.collision_layer & PLAYER_BODY_LAYER_MASK) != 0
	return false


func _has_line_of_sight_to(player_body: CharacterBody2D) -> bool:
	if player_body == null:
		return false

	var from_point: Vector2 = global_position + vision_ray_origin_offset
	var to_point: Vector2 = player_body.global_position
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(from_point, to_point)
	query.exclude = [self]
	query.collision_mask = SOLID_LAYER_MASK | PLAYER_BODY_LAYER_MASK
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return false

	var collider: Object = hit.get("collider", null)
	return collider == player_body


func _is_front_blocked(direction: int) -> bool:
	var origin: Vector2 = global_position + Vector2(0.0, -1.0)
	var target: Vector2 = origin + Vector2(float(direction) * wall_check_distance, 0.0)
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(origin, target)
	query.exclude = [self]
	query.collision_mask = SOLID_LAYER_MASK
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _has_ground_ahead(direction: int) -> bool:
	if not is_on_floor():
		return true

	var origin: Vector2 = global_position + Vector2(float(direction) * edge_check_forward, 6.0)
	var target: Vector2 = origin + Vector2(0.0, edge_check_depth)
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(origin, target)
	query.exclude = [self]
	query.collision_mask = SOLID_LAYER_MASK
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _on_vision_cone_body_entered(body: Node2D) -> void:
	if ignore_player_detection_timer > 0.0:
		return
	if not _is_player_body(body):
		return

	var player_body: CharacterBody2D = body as CharacterBody2D
	if player_body == null:
		return

	if _has_line_of_sight_to(player_body):
		target_player = player_body
		lose_sight_timer = lose_sight_grace_time
		_set_state(State.CHASE)


func _on_vision_cone_body_exited(body: Node2D) -> void:
	if body == target_player and current_state != State.CHASE:
		lose_sight_timer = minf(lose_sight_timer, 0.05)
