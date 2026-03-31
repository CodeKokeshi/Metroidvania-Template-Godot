extends Sprite2D

@export var bob_amplitude: float = 1.2
@export var bob_speed: float = 0.55
@export var squeeze_amount: float = 0.045
@export var squeeze_speed: float = 0.42
@export var recovery_speed: float = 8.0

var base_position: Vector2 = Vector2.ZERO
var base_scale: Vector2 = Vector2.ONE
var animation_time: float = 0.0


func _ready() -> void:
	base_position = position
	base_scale = scale


func _process(delta: float) -> void:
	if not visible:
		animation_time = 0.0
		position = position.lerp(base_position, minf(1.0, recovery_speed * delta))
		scale = scale.lerp(base_scale, minf(1.0, recovery_speed * delta))
		return

	animation_time += delta
	var bob_offset: float = sin(animation_time * TAU * bob_speed) * bob_amplitude
	var squeeze_wave: float = sin((animation_time * TAU * squeeze_speed) + (PI * 0.5))
	var squeeze_factor: float = squeeze_wave * squeeze_amount

	position.x = base_position.x
	position.y = base_position.y + bob_offset
	scale.x = base_scale.x * (1.0 + squeeze_factor)
	scale.y = base_scale.y * (1.0 - (squeeze_factor * 0.85))
