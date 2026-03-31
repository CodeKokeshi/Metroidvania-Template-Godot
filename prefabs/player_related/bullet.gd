extends CharacterBody2D

signal returned_to_pool(bullet: CharacterBody2D)

@export var bullet_speed: float = 420.0
@export var max_lifetime: float = 2.0

@onready var bullet_sprite: Sprite2D = $"sprite"
@onready var collision_shape: CollisionShape2D = $"bodyshape"
@onready var impact_emission: CPUParticles2D = $"emission"

var is_active: bool = false
var lifetime_timer: float = 0.0
var direction: Vector2 = Vector2.RIGHT
var shooter_body: PhysicsBody2D = null


func _ready() -> void:
	reset_to_pool()


func activate(spawn_position: Vector2, shoot_direction: Vector2, owner_body: PhysicsBody2D) -> void:
	global_position = spawn_position
	direction = shoot_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	lifetime_timer = max_lifetime
	is_active = true
	velocity = direction * bullet_speed
	rotation = direction.angle()

	if shooter_body != null:
		remove_collision_exception_with(shooter_body)
	shooter_body = owner_body
	if shooter_body != null:
		add_collision_exception_with(shooter_body)

	if bullet_sprite != null:
		bullet_sprite.visible = true
	if collision_shape != null:
		collision_shape.set_deferred("disabled", false)
	if impact_emission != null:
		impact_emission.emitting = false


func reset_to_pool() -> void:
	is_active = false
	lifetime_timer = 0.0
	direction = Vector2.RIGHT
	velocity = Vector2.ZERO
	if bullet_sprite != null:
		bullet_sprite.visible = false
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)

	if shooter_body != null:
		remove_collision_exception_with(shooter_body)
		shooter_body = null

	if impact_emission != null:
		impact_emission.emitting = false


func _physics_process(delta: float) -> void:
	if not is_active:
		return

	lifetime_timer = maxf(0.0, lifetime_timer - delta)
	if lifetime_timer <= 0.0:
		_return_to_pool()
		return

	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision != null:
		_impact_and_return_to_pool()


func _impact_and_return_to_pool() -> void:
	is_active = false
	velocity = Vector2.ZERO
	if bullet_sprite != null:
		bullet_sprite.visible = false
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)
	if impact_emission != null:
		impact_emission.restart()
		impact_emission.emitting = true
	returned_to_pool.emit(self)


func _return_to_pool() -> void:
	reset_to_pool()
	returned_to_pool.emit(self)
