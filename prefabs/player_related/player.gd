extends CharacterBody2D

@export_group("Run")
@export var max_run_speed: float = 145.0
@export var ground_acceleration: float = 1200.0
@export var ground_deceleration: float = 1450.0
@export var air_acceleration: float = 900.0
@export var air_deceleration: float = 700.0

@export_group("Dash")
@export var dash_speed: float = 220.0
@export var dash_duration: float = 0.12

@export_group("Jump Feel")
@export var jump_velocity: float = -340.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12
@export var rise_gravity: float = 980.0
@export var apex_gravity: float = 730.0
@export var fall_gravity: float = 1900.0
@export var apex_velocity_threshold: float = 50.0
@export var jump_release_multiplier: float = 0.45
@export var max_fall_speed: float = 620.0

@export_group("Squash")
@export var air_stretch_strength: float = 0.12
@export var jump_squash_strength: float = 0.11
@export var jump_squash_time: float = 0.08
@export var land_squash_strength: float = 0.18
@export var land_squash_time: float = 0.1
@export var land_squash_min_speed: float = 170.0
@export var squash_recovery_speed: float = 16.0

@export_group("Gun Feel")
@export var gun_shot_animation_time: float = 0.11
@export var gun_attack_cooldown: float = 0.5
@export var gun_recoil_distance: float = 4.0
@export var gun_recoil_lift: float = 1.4
@export var gun_recoil_stretch_x: float = 0.16
@export var gun_recoil_squash_y: float = 0.12
@export var gun_recoil_tilt_degrees: float = 8.0
@export var gun_player_recoil_offset_x: float = 1.6
@export var gun_player_recoil_squash: float = 0.04

@export_group("Gun Push Recoil")
@export var gun_push_recoil_horizontal: float = 120.0
@export var gun_push_recoil_down_shot_boost: float = 250.0
@export var gun_push_recoil_up_shot_drop: float = 70.0

@export_group("Air Jump")
@export var max_air_jumps: int = 0
@export var down_shot_bonus_air_jumps: int = 1

@export_group("Sword Pogo")
@export var sword_pogo_bounce_speed: float = 400.0
@export var sword_pogo_target_below_margin: float = 4.0
@export var sword_pogo_debug_logs: bool = false

@export_group("Hit Pause")
@export var sword_hit_pause_duration: float = 0.05

@export_group("Sword Hit FX")
@export var sword_hit_fx_pool_size: int = 5

@export_group("Gun Ammo")
@export var gun_magazine_size: int = 8
@export var gun_reload_time: float = 1.0

const ACTION_LEFT: StringName = &"left"
const ACTION_RIGHT: StringName = &"right"
const ACTION_UP: StringName = &"up"
const ACTION_DOWN: StringName = &"down"
const ACTION_JUMP: StringName = &"jump"
const ACTION_ATTACK: StringName = &"attack"
const ACTION_SWITCH_WEAPON: StringName = &"switch_weapon"
const ACTION_DASH: StringName = &"dash"
const BULLET_SCENE: PackedScene = preload("res://prefabs/player_related/bullet.tscn")
const SWORD_HIT_FX_SCENE: PackedScene = preload("res://prefabs/fx/sword_hit.tscn")

enum WeaponMode {
	SWORD,
	GUN
}

@onready var anim_sprite: AnimatedSprite2D = $"animsprite2D"
@onready var weapon_pivot: Node2D = $"pivot"
@onready var weapon_sprite: AnimatedSprite2D = $"pivot/weapon"
@onready var sword_hitbox: Area2D = $"pivot/weapon/sword_hitbox"
@onready var gun_sprite: Sprite2D = $"pivot/gun"
@onready var gun_emission: CPUParticles2D = $"pivot/gun/emission"
@onready var bullet_spawn_marker: Marker2D = $"pivot/gun/bullet_spawns_here"
@onready var expression_sprite: Sprite2D = $"pivot/gun/expression"

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var jump_squash_timer: float = 0.0
var land_squash_timer: float = 0.0
var last_vertical_speed: float = 0.0
var base_sprite_scale: Vector2 = Vector2.ONE
var base_anim_sprite_position: Vector2 = Vector2.ZERO
var base_weapon_scale_x: float = 1.0
var base_weapon_position_x: float = 0.0
var base_gun_scale_x: float = 1.0
var base_gun_position_x: float = 0.0
var base_gun_scale_y: float = 1.0
var base_gun_position_y: float = 0.0
var base_gun_rotation_degrees: float = 0.0
var is_attacking: bool = false
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var can_air_dash: bool = true
var facing_sign: int = 1
var queued_facing_sign: int = 1
var current_weapon_mode: WeaponMode = WeaponMode.SWORD
var gun_shot_timer: float = 0.0
var gun_attack_cooldown_timer: float = 0.0
var gun_bullet_pool: Array[CharacterBody2D] = []
var gun_available_bullets: Array[CharacterBody2D] = []
var gun_ammo_in_magazine: int = 0
var gun_reload_timer: float = 0.0
var is_gun_reloading: bool = false
var is_gun_pool_initialized: bool = false
var attack_pitch_sign: int = 0
var last_gun_shot_direction: Vector2 = Vector2.RIGHT
var remaining_air_jumps: int = 0
var pending_recoil_velocity_add: Vector2 = Vector2.ZERO
var pending_recoil_min_upward_speed: float = 0.0
var sword_pogo_consumed_this_attack: bool = false
var sword_hit_pause_consumed_this_attack: bool = false
var sword_hit_fx_pool: Array[CPUParticles2D] = []
var sword_hit_fx_available: Array[CPUParticles2D] = []
var is_sword_hit_fx_pool_initialized: bool = false


func _ready() -> void:
	base_sprite_scale = anim_sprite.scale
	base_anim_sprite_position = anim_sprite.position
	base_weapon_scale_x = absf(weapon_sprite.scale.x)
	base_weapon_position_x = weapon_sprite.position.x
	base_gun_scale_x = absf(gun_sprite.scale.x)
	base_gun_position_x = gun_sprite.position.x
	base_gun_scale_y = gun_sprite.scale.y
	base_gun_position_y = gun_sprite.position.y
	base_gun_rotation_degrees = gun_sprite.rotation_degrees
	facing_sign = -1 if anim_sprite.flip_h else 1
	queued_facing_sign = facing_sign
	current_weapon_mode = WeaponMode.GUN if gun_sprite.visible and not weapon_sprite.visible else WeaponMode.SWORD
	_apply_facing()
	_update_attack_pitch_from_input()
	_apply_attack_pivot_rotation()
	_apply_weapon_mode_visibility()
	_apply_gun_feedback_visuals()
	_apply_player_gun_recoil_visuals()
	_set_sword_hitbox_active(false)
	_update_expression_visibility()
	remaining_air_jumps = max(0, max_air_jumps)
	call_deferred("_initialize_gun_bullet_pool")
	call_deferred("_initialize_sword_hit_fx_pool")


func _physics_process(delta: float) -> void:
	var was_on_floor: bool = is_on_floor()
	var horizontal_input: float = _get_horizontal_input()

	_update_timers(delta, was_on_floor)
	_buffer_jump_input()
	_try_start_dash(was_on_floor)
	_apply_gun_feedback_visuals()
	_apply_player_gun_recoil_visuals()

	if is_dashing:
		_process_dash_movement(delta, was_on_floor)
		return

	_try_switch_weapon()
	_update_facing(horizontal_input)
	_update_attack_pitch_from_input()
	_try_start_attack()
	_apply_horizontal_movement(horizontal_input, delta, was_on_floor)
	_apply_gravity(delta, was_on_floor)
	_consume_buffered_jump_if_possible(was_on_floor)
	_apply_variable_jump_cut()
	_apply_pending_recoil_velocity()

	last_vertical_speed = velocity.y
	move_and_slide()

	_handle_landing_squash(was_on_floor)
	_update_animation()
	_update_squash(delta)


func _update_timers(delta: float, on_floor: bool) -> void:
	if on_floor:
		coyote_timer = coyote_time
		remaining_air_jumps = max(0, max_air_jumps)
		can_air_dash = true
	else:
		coyote_timer = maxf(0.0, coyote_timer - delta)

	jump_buffer_timer = maxf(0.0, jump_buffer_timer - delta)
	jump_squash_timer = maxf(0.0, jump_squash_timer - delta)
	land_squash_timer = maxf(0.0, land_squash_timer - delta)
	gun_shot_timer = maxf(0.0, gun_shot_timer - delta)
	gun_attack_cooldown_timer = maxf(0.0, gun_attack_cooldown_timer - delta)
	if is_gun_reloading:
		gun_reload_timer = maxf(0.0, gun_reload_timer - delta)
		if gun_reload_timer <= 0.0:
			_finish_gun_reload()


func _buffer_jump_input() -> void:
	if Input.is_action_just_pressed(ACTION_JUMP):
		jump_buffer_timer = jump_buffer_time


func _try_start_dash(on_floor: bool) -> void:
	if not Input.is_action_just_pressed(ACTION_DASH):
		return

	if is_dashing or is_attacking:
		return

	if not on_floor and not can_air_dash:
		return

	var requested_direction: Vector2 = _get_dash_direction()
	if requested_direction == Vector2.ZERO:
		return

	_start_dash(requested_direction, on_floor)


func _start_dash(requested_direction: Vector2, on_floor: bool) -> void:
	is_dashing = true
	dash_timer = maxf(0.0, dash_duration)
	dash_direction = requested_direction.normalized()
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	pending_recoil_velocity_add = Vector2.ZERO
	pending_recoil_min_upward_speed = 0.0

	if not on_floor:
		can_air_dash = false

	if dash_direction.x < 0.0:
		queued_facing_sign = -1
	elif dash_direction.x > 0.0:
		queued_facing_sign = 1

	if facing_sign != queued_facing_sign:
		facing_sign = queued_facing_sign
		_apply_facing()

	velocity = dash_direction * dash_speed


func _process_dash_movement(delta: float, was_on_floor: bool) -> void:
	dash_timer = maxf(0.0, dash_timer - delta)
	velocity = dash_direction * dash_speed
	last_vertical_speed = velocity.y
	move_and_slide()

	if dash_timer <= 0.0:
		_finish_dash()

	_handle_landing_squash(was_on_floor)
	_update_animation()
	_update_squash(delta)


func _finish_dash() -> void:
	is_dashing = false
	dash_timer = 0.0
	velocity = Vector2.ZERO
	pending_recoil_velocity_add = Vector2.ZERO
	pending_recoil_min_upward_speed = 0.0


func _get_dash_direction() -> Vector2:
	var horizontal_sign: int = facing_sign
	var horizontal_axis: float = Input.get_axis(ACTION_LEFT, ACTION_RIGHT)
	if horizontal_axis < 0.0:
		horizontal_sign = -1
	elif horizontal_axis > 0.0:
		horizontal_sign = 1

	var vertical_sign: int = 0
	var up_pressed: bool = Input.is_action_pressed(ACTION_UP)
	var down_pressed: bool = Input.is_action_pressed(ACTION_DOWN)
	if up_pressed and not down_pressed:
		vertical_sign = -1
	elif down_pressed and not up_pressed:
		vertical_sign = 1

	return Vector2(float(horizontal_sign), float(vertical_sign)).normalized()


func _consume_buffered_jump_if_possible(on_floor: bool) -> void:
	if jump_buffer_timer <= 0.0:
		return

	if on_floor or coyote_timer > 0.0:
		_start_jump()
		return

	if remaining_air_jumps > 0:
		remaining_air_jumps -= 1
		_start_jump()


func _start_jump() -> void:
	velocity.y = jump_velocity
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	jump_squash_timer = jump_squash_time


func _apply_horizontal_movement(input_axis: float, delta: float, on_floor: bool) -> void:
	var acceleration: float = ground_acceleration if on_floor else air_acceleration
	var deceleration: float = ground_deceleration if on_floor else air_deceleration
	var target_speed: float = input_axis * max_run_speed

	if absf(input_axis) > 0.0:
		velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)


func _apply_gravity(delta: float, on_floor: bool) -> void:
	if on_floor and velocity.y > 0.0:
		velocity.y = 0.0
		return

	if not on_floor:
		velocity.y += _get_current_gravity() * delta
		velocity.y = minf(velocity.y, max_fall_speed)


func _get_current_gravity() -> float:
	if velocity.y < 0.0:
		if absf(velocity.y) <= apex_velocity_threshold and Input.is_action_pressed(ACTION_JUMP):
			return apex_gravity
		return rise_gravity
	return fall_gravity


func _apply_variable_jump_cut() -> void:
	if velocity.y < 0.0 and Input.is_action_just_released(ACTION_JUMP):
		velocity.y *= jump_release_multiplier


func _get_horizontal_input() -> float:
	return Input.get_axis(ACTION_LEFT, ACTION_RIGHT)


func _update_facing(horizontal_input: float) -> void:
	if horizontal_input < 0.0:
		queued_facing_sign = -1
	elif horizontal_input > 0.0:
		queued_facing_sign = 1

	if not is_attacking and facing_sign != queued_facing_sign:
		facing_sign = queued_facing_sign
		_apply_facing()


func _apply_facing() -> void:
	anim_sprite.flip_h = facing_sign < 0
	weapon_sprite.scale.x = -base_weapon_scale_x if facing_sign < 0 else base_weapon_scale_x
	weapon_sprite.position.x = -base_weapon_position_x if facing_sign < 0 else base_weapon_position_x
	_apply_attack_pivot_rotation()
	_apply_gun_feedback_visuals()


func _try_switch_weapon() -> void:
	if is_attacking or not Input.is_action_just_pressed(ACTION_SWITCH_WEAPON):
		return

	current_weapon_mode = WeaponMode.GUN if current_weapon_mode == WeaponMode.SWORD else WeaponMode.SWORD
	_apply_weapon_mode_visibility()


func _apply_weapon_mode_visibility() -> void:
	var using_sword: bool = current_weapon_mode == WeaponMode.SWORD
	weapon_sprite.visible = using_sword
	gun_sprite.visible = not using_sword

	if using_sword:
		gun_emission.emitting = false
		gun_shot_timer = 0.0
		_apply_gun_feedback_visuals()
		_apply_player_gun_recoil_visuals()
	else:
		_set_sword_hitbox_active(false)


func _try_start_attack() -> void:
	if not Input.is_action_just_pressed(ACTION_ATTACK):
		return

	_update_attack_pitch_from_input(true)

	if current_weapon_mode == WeaponMode.GUN:
		_try_fire_gun()
		return

	if is_attacking:
		return

	is_attacking = true
	sword_pogo_consumed_this_attack = false
	sword_hit_pause_consumed_this_attack = false
	_set_sword_hitbox_active(true)
	weapon_sprite.frame = 0
	weapon_sprite.frame_progress = 0.0
	weapon_sprite.play(&"slash")


func _try_fire_gun() -> void:
	if not is_gun_pool_initialized:
		return

	if is_gun_reloading or gun_attack_cooldown_timer > 0.0:
		return

	if gun_ammo_in_magazine <= 0:
		_start_gun_reload()
		return

	var pooled_bullet: CharacterBody2D = _take_pooled_bullet()
	if pooled_bullet == null:
		return

	gun_attack_cooldown_timer = maxf(0.0, gun_attack_cooldown)
	gun_shot_timer = gun_shot_animation_time
	gun_ammo_in_magazine -= 1
	var shot_direction: Vector2 = _get_attack_direction()
	last_gun_shot_direction = shot_direction
	_queue_gun_push_recoil(shot_direction)
	pooled_bullet.call("activate", bullet_spawn_marker.global_position, shot_direction, self)

	gun_emission.emitting = false
	gun_emission.restart()
	gun_emission.emitting = true
	_apply_gun_feedback_visuals()
	_apply_player_gun_recoil_visuals()

	if gun_ammo_in_magazine <= 0:
		_start_gun_reload()


func _initialize_gun_bullet_pool() -> void:
	for pooled_bullet in gun_bullet_pool:
		if pooled_bullet != null:
			pooled_bullet.queue_free()

	gun_bullet_pool.clear()
	gun_available_bullets.clear()
	gun_ammo_in_magazine = max(0, gun_magazine_size)
	is_gun_reloading = false
	gun_reload_timer = 0.0
	gun_attack_cooldown_timer = 0.0
	is_gun_pool_initialized = false
	_update_expression_visibility()

	if gun_magazine_size <= 0:
		is_gun_pool_initialized = true
		return

	var pool_parent: Node = get_parent() if get_parent() != null else self
	for index in range(gun_magazine_size):
		var bullet_instance: Node = BULLET_SCENE.instantiate()
		if not (bullet_instance is CharacterBody2D):
			bullet_instance.queue_free()
			continue

		var pooled_bullet: CharacterBody2D = bullet_instance
		pool_parent.add_child(pooled_bullet)
		pooled_bullet.connect("returned_to_pool", Callable(self, "_on_pooled_bullet_returned"))
		gun_bullet_pool.append(pooled_bullet)
		gun_available_bullets.append(pooled_bullet)

	is_gun_pool_initialized = true


func _take_pooled_bullet() -> CharacterBody2D:
	if gun_available_bullets.is_empty():
		return null

	var last_index: int = gun_available_bullets.size() - 1
	var pooled_bullet: CharacterBody2D = gun_available_bullets[last_index]
	gun_available_bullets.remove_at(last_index)
	return pooled_bullet


func _on_pooled_bullet_returned(pooled_bullet: CharacterBody2D) -> void:
	if not gun_bullet_pool.has(pooled_bullet):
		return

	if not gun_available_bullets.has(pooled_bullet):
		gun_available_bullets.append(pooled_bullet)


func _initialize_sword_hit_fx_pool() -> void:
	for pooled_fx in sword_hit_fx_pool:
		if pooled_fx != null:
			pooled_fx.queue_free()

	sword_hit_fx_pool.clear()
	sword_hit_fx_available.clear()
	is_sword_hit_fx_pool_initialized = false

	if sword_hit_fx_pool_size <= 0:
		is_sword_hit_fx_pool_initialized = true
		return

	var pool_parent: Node = get_parent() if get_parent() != null else self
	for index in range(sword_hit_fx_pool_size):
		var fx_instance: Node = SWORD_HIT_FX_SCENE.instantiate()
		if not (fx_instance is CPUParticles2D):
			fx_instance.queue_free()
			continue

		var pooled_fx: CPUParticles2D = fx_instance
		pool_parent.add_child(pooled_fx)
		pooled_fx.visible = false
		pooled_fx.emitting = false
		pooled_fx.finished.connect(Callable(self, "_on_sword_hit_fx_finished").bind(pooled_fx))
		sword_hit_fx_pool.append(pooled_fx)
		sword_hit_fx_available.append(pooled_fx)

	is_sword_hit_fx_pool_initialized = true


func _take_sword_hit_fx() -> CPUParticles2D:
	if not sword_hit_fx_available.is_empty():
		var last_index: int = sword_hit_fx_available.size() - 1
		var pooled_fx: CPUParticles2D = sword_hit_fx_available[last_index]
		sword_hit_fx_available.remove_at(last_index)
		return pooled_fx

	if sword_hit_fx_pool.is_empty():
		return null

	# Reuse one active FX instead of instantiating at runtime.
	return sword_hit_fx_pool[0]


func _play_sword_hit_fx(hit_position: Vector2) -> void:
	if not is_sword_hit_fx_pool_initialized:
		return

	var pooled_fx: CPUParticles2D = _take_sword_hit_fx()
	if pooled_fx == null:
		return

	pooled_fx.global_position = hit_position
	pooled_fx.visible = true
	pooled_fx.emitting = false
	pooled_fx.restart()
	pooled_fx.emitting = true


func _on_sword_hit_fx_finished(pooled_fx: CPUParticles2D) -> void:
	if pooled_fx == null:
		return

	pooled_fx.emitting = false
	pooled_fx.visible = false
	if not sword_hit_fx_available.has(pooled_fx):
		sword_hit_fx_available.append(pooled_fx)


func _request_hit_pause() -> void:
	if sword_hit_pause_duration <= 0.0:
		return

	if not has_node("/root/HitPauseManager"):
		return

	var hit_pause_manager: Node = get_node("/root/HitPauseManager")
	if hit_pause_manager.has_method("request_hit_pause"):
		hit_pause_manager.call("request_hit_pause", sword_hit_pause_duration)


func _start_gun_reload() -> void:
	if not is_gun_pool_initialized:
		return

	if is_gun_reloading:
		return

	is_gun_reloading = true
	gun_reload_timer = maxf(0.0, gun_reload_time)
	gun_attack_cooldown_timer = 0.0
	_recall_all_bullets_to_pool()
	_update_expression_visibility()


func _finish_gun_reload() -> void:
	is_gun_reloading = false
	gun_reload_timer = 0.0
	gun_ammo_in_magazine = max(0, gun_magazine_size)
	_recall_all_bullets_to_pool()
	_update_expression_visibility()


func _recall_all_bullets_to_pool() -> void:
	gun_available_bullets.clear()
	for pooled_bullet in gun_bullet_pool:
		if pooled_bullet == null:
			continue

		pooled_bullet.call("reset_to_pool")
		gun_available_bullets.append(pooled_bullet)


func _update_expression_visibility() -> void:
	if expression_sprite == null:
		return

	var should_show: bool = is_gun_reloading
	expression_sprite.visible = should_show
	expression_sprite.set_process(should_show)


func _set_sword_hitbox_active(active: bool) -> void:
	sword_hitbox.monitoring = active
	sword_hitbox.monitorable = active


func _queue_gun_push_recoil(shot_direction: Vector2) -> void:
	var normalized_direction: Vector2 = shot_direction.normalized()
	if normalized_direction == Vector2.ZERO:
		normalized_direction = Vector2(float(facing_sign), 0.0)

	if absf(normalized_direction.y) > 0.5:
		if normalized_direction.y > 0.0:
			pending_recoil_min_upward_speed = maxf(pending_recoil_min_upward_speed, gun_push_recoil_down_shot_boost)
			remaining_air_jumps = max(remaining_air_jumps, max(0, down_shot_bonus_air_jumps))
		else:
			pending_recoil_velocity_add.y += gun_push_recoil_up_shot_drop
		return

	pending_recoil_velocity_add.x += -normalized_direction.x * gun_push_recoil_horizontal


func _apply_pending_recoil_velocity() -> void:
	if pending_recoil_velocity_add == Vector2.ZERO:
		if pending_recoil_min_upward_speed <= 0.0:
			return

	velocity += pending_recoil_velocity_add
	if pending_recoil_min_upward_speed > 0.0:
		velocity.y = minf(velocity.y, -pending_recoil_min_upward_speed)
	velocity.y = minf(velocity.y, max_fall_speed)
	pending_recoil_velocity_add = Vector2.ZERO
	pending_recoil_min_upward_speed = 0.0


func _update_attack_pitch_from_input(force: bool = false) -> void:
	if is_attacking and not force:
		return

	if Input.is_action_pressed(ACTION_UP):
		attack_pitch_sign = -1
	elif Input.is_action_pressed(ACTION_DOWN):
		attack_pitch_sign = 1
	else:
		attack_pitch_sign = 0

	_apply_attack_pivot_rotation()


func _apply_attack_pivot_rotation() -> void:
	weapon_pivot.rotation_degrees = float(attack_pitch_sign * facing_sign) * 90.0


func _get_attack_direction() -> Vector2:
	if attack_pitch_sign < 0:
		return Vector2.UP
	if attack_pitch_sign > 0:
		return Vector2.DOWN
	return Vector2(float(facing_sign), 0.0)


func _get_gun_shot_strength() -> float:
	if gun_shot_timer <= 0.0 or gun_shot_animation_time <= 0.0:
		return 0.0

	var shot_time_ratio: float = clampf(1.0 - (gun_shot_timer / gun_shot_animation_time), 0.0, 1.0)
	return sin(shot_time_ratio * PI)


func _apply_gun_feedback_visuals() -> void:
	var shot_strength: float = _get_gun_shot_strength()
	var facing_direction: float = float(facing_sign)
	var facing_position_x: float = -base_gun_position_x if facing_sign < 0 else base_gun_position_x
	var facing_scale_x: float = -base_gun_scale_x if facing_sign < 0 else base_gun_scale_x

	gun_sprite.position.x = facing_position_x - (facing_direction * gun_recoil_distance * shot_strength)
	gun_sprite.position.y = base_gun_position_y - (gun_recoil_lift * shot_strength)
	gun_sprite.scale.x = facing_scale_x * (1.0 + (gun_recoil_stretch_x * shot_strength))
	gun_sprite.scale.y = base_gun_scale_y * (1.0 - (gun_recoil_squash_y * shot_strength))
	gun_sprite.rotation_degrees = base_gun_rotation_degrees - (facing_direction * gun_recoil_tilt_degrees * shot_strength)


func _apply_player_gun_recoil_visuals() -> void:
	if current_weapon_mode != WeaponMode.GUN:
		anim_sprite.position = base_anim_sprite_position
		return

	var shot_strength: float = _get_gun_shot_strength()
	var recoil_offset: Vector2 = -last_gun_shot_direction * gun_player_recoil_offset_x * shot_strength
	anim_sprite.position = base_anim_sprite_position + recoil_offset


func _update_animation() -> void:
	if not is_on_floor():
		_play_animation_if_needed(&"jump")
	elif absf(velocity.x) > 8.0:
		_play_animation_if_needed(&"walk")
	else:
		_play_animation_if_needed(&"idle")


func _play_animation_if_needed(animation_name: StringName) -> void:
	if anim_sprite.animation != animation_name:
		anim_sprite.play(animation_name)


func _handle_landing_squash(was_on_floor: bool) -> void:
	if not was_on_floor and is_on_floor() and last_vertical_speed > land_squash_min_speed:
		land_squash_timer = land_squash_time


func _update_squash(delta: float) -> void:
	var target_scale: Vector2 = base_sprite_scale

	if not is_on_floor():
		var speed_ratio: float = clampf(absf(velocity.y) / max_fall_speed, 0.0, 1.0)
		if velocity.y < 0.0:
			target_scale *= Vector2(1.0 - (air_stretch_strength * 0.6 * speed_ratio), 1.0 + (air_stretch_strength * speed_ratio))
		else:
			target_scale *= Vector2(1.0 + (air_stretch_strength * speed_ratio), 1.0 - (air_stretch_strength * speed_ratio))

	if jump_squash_timer > 0.0 and jump_squash_time > 0.0:
		var jump_ratio: float = jump_squash_timer / jump_squash_time
		target_scale *= Vector2(1.0 - (jump_squash_strength * jump_ratio), 1.0 + (jump_squash_strength * jump_ratio))

	if land_squash_timer > 0.0 and land_squash_time > 0.0:
		var land_ratio: float = land_squash_timer / land_squash_time
		target_scale *= Vector2(1.0 + (land_squash_strength * land_ratio), 1.0 - (land_squash_strength * land_ratio))

	if current_weapon_mode == WeaponMode.GUN and gun_shot_timer > 0.0:
		var gun_shot_strength: float = _get_gun_shot_strength()
		target_scale *= Vector2(1.0 - (gun_player_recoil_squash * gun_shot_strength), 1.0 + (gun_player_recoil_squash * gun_shot_strength))

	anim_sprite.scale = anim_sprite.scale.lerp(target_scale, minf(1.0, squash_recovery_speed * delta))


func _on_weapon_slash_animation_finished() -> void:
	if not is_attacking:
		return

	is_attacking = false
	sword_pogo_consumed_this_attack = false
	sword_hit_pause_consumed_this_attack = false
	_set_sword_hitbox_active(false)
	_update_attack_pitch_from_input()
	if facing_sign != queued_facing_sign:
		facing_sign = queued_facing_sign
		_apply_facing()


func _on_hurtbox_body_entered(body: Node2D) -> void:
	# for now do nothing.
	pass # Replace with function body.


func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	if body == null:
		if sword_pogo_debug_logs:
			print("[Pogo] Ignored: null body")
		return

	if not is_attacking:
		if sword_pogo_debug_logs:
			print("[Pogo] Ignored: not attacking")
		return

	_play_sword_hit_fx(sword_hitbox.global_position)
	if not sword_hit_pause_consumed_this_attack:
		_request_hit_pause()
		sword_hit_pause_consumed_this_attack = true

	if sword_pogo_consumed_this_attack:
		if sword_pogo_debug_logs:
			print("[Pogo] Ignored: already consumed this slash")
		return

	if attack_pitch_sign <= 0:
		if sword_pogo_debug_logs:
			print("[Pogo] Ignored: slash is not downward")
		return

	# TileMap body origins are often scene-origin based, so use hitbox position for below-player validation.
	if sword_hitbox.global_position.y <= (global_position.y + sword_pogo_target_below_margin):
		if sword_pogo_debug_logs:
			print("[Pogo] Ignored: sword hitbox is not below player enough")
		return

	pending_recoil_min_upward_speed = maxf(pending_recoil_min_upward_speed, absf(sword_pogo_bounce_speed))
	sword_pogo_consumed_this_attack = true
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	remaining_air_jumps = max(remaining_air_jumps, max(0, max_air_jumps))
	if sword_pogo_debug_logs:
		print("[Pogo] Triggered on body=", body.name, " attack_pitch_sign=", attack_pitch_sign, " hitbox_y=", sword_hitbox.global_position.y, " player_y=", global_position.y, " queued_upward_speed=", pending_recoil_min_upward_speed)
