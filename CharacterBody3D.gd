extends CharacterBody3D

@onready var twist_pivot: Node3D = $CameraHandler/TwistPivot #Custom
@onready var visuals: Node3D = $Visuals #Custom
@onready var physics_handler: Node3D = $PhysicsHandler
@onready var GRAVITY: float = physics_handler.gravity
@onready var JUMP_VELOCITY: float = physics_handler.jump_velocity

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (twist_pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity = physics_handler.apply_acceleration(velocity, direction)
		var align = visuals.transform.looking_at(direction - visuals.transform.origin) #Custom
		visuals.transform = visuals.transform.interpolate_with(align, delta * 10.0) #Custom
	else:
		velocity = physics_handler.apply_friction(velocity, delta)
	move_and_slide()
