extends RigidBody2D
@export var impulse_strength: float = 500.0  # Increased from 200
@export var random_force_interval: float = 10.0
@export var random_force_strength: float = 300.0  # Increased from 150
var time_since_last_force: float = 0.0
const LETTER_SIZE: float = 50.0

func _ready():
	linear_damp = 0.0
	angular_damp = 0.0
	gravity_scale = 0.0
	
	if physics_material_override == null:
		physics_material_override = PhysicsMaterial.new()
		physics_material_override.friction = 0.0
		physics_material_override.bounce = 1.0
	
	var direction := Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized()
	apply_impulse(direction * impulse_strength)
	
	angular_velocity = randf_range(-3.0, 3.0)  # Increased rotation speed

func _physics_process(delta):
	time_since_last_force += delta
	if time_since_last_force >= random_force_interval:
		time_since_last_force = 0.0
		var random_direction := Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		).normalized()
		apply_impulse(random_direction * random_force_strength)
	
	var screen_size = get_viewport_rect().size
	
	if global_position.x < LETTER_SIZE:
		global_position.x = LETTER_SIZE
		linear_velocity.x = abs(linear_velocity.x)
	elif global_position.x > screen_size.x - LETTER_SIZE:
		global_position.x = screen_size.x - LETTER_SIZE
		linear_velocity.x = -abs(linear_velocity.x)
	
	if global_position.y < LETTER_SIZE:
		global_position.y = LETTER_SIZE
		linear_velocity.y = abs(linear_velocity.y)
	elif global_position.y > screen_size.y - LETTER_SIZE:
		global_position.y = screen_size.y - LETTER_SIZE
		linear_velocity.y = -abs(linear_velocity.y)
