extends CharacterBody3D
##This is a minimal character controller using my basic components
##
##Abilities: movement with running, acceleration, friction, jump, and gravity

@onready var physics_handler: Node3D = $PhysicsHandler #custom
@onready var twist_pivot: Node3D = $CameraHandler/TwistPivot #Custom
@onready var visuals: Node3D = $Visuals #Custom

@onready var GRAVITY: float = physics_handler.gravity #motified
@onready var JUMP_VELOCITY: float = physics_handler.jump_velocity #motified

var running:= false #custom

func _physics_process(delta: float) -> void:
	if not is_on_floor(): # Add the gravity.
		velocity.y -= GRAVITY * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor(): # Handle Jump.
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (twist_pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() #motified
	if direction:
		running= Input.is_action_pressed("run") #custom
		physics_handler.change_speed(running) #custom
		velocity = physics_handler.apply_acceleration(velocity, direction, delta) #motified
		var align = visuals.transform.looking_at(direction - visuals.transform.origin) #Custom
		visuals.transform = visuals.transform.interpolate_with(align, delta * 10.0) #Custom
	else:
		velocity = physics_handler.apply_friction(velocity, delta) #motified
	move_and_slide()
