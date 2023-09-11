extends CharacterBody3D
class_name Player
## This is the Player's control script and is meant to handle movement and Animation.
##
## This is not meant to actually singal changes to the animator node, rather it should signal changes to the Player animation controller.
@onready var animation_handler: AnimationHandler = $Visuals/AnimationHandler
@onready var camera_handler: CameraHandler = $TPSCameraHandler
@onready var physics_handler: PhysicsHandler = $PhysicsHandler

@onready var aim_ray: RayCast3D = $"TPSCameraHandler/TwistPivot/PitchPivot/Camera Spring Arm/Camera3D/AimRay" ##The raycast used for hitscan weapons
@onready var twist_pivot: Node3D = $TPSCameraHandler/TwistPivot ##A node that is used to rotate the Camera [i]horizontally[/i] around a point
@onready var pitch_pivot: Node3D = $TPSCameraHandler/TwistPivot/PitchPivot ##A node that is used to rotate the Camera [i]vertically[/i] around a point
@onready var visuals: Node3D = $Visuals

@onready var gravity: float = physics_handler.gravity ## A gravity calculated by the [PhysicsHandler]
@onready var jump_velocity: float = physics_handler.jump_velocity ##The inital velocity to be applied when the Jump Button is hit. Calculated by the [PhysicsHandler]
var input:= Vector3.ZERO ## A [Vector3] representing the players input. The y value is not used but is needed for the [member Transform3D.basis] calculations to work.
var running:= false ##A boolean value that is used to specify if the character is meant to be running
var direction: Vector3 ##Is used to define a vector that is the direction in front of the camera.

func _process(delta) -> void:
	animation_handler.update(input, clamp(((rad_to_deg(pitch_pivot.rotation.x))/45), -1, 1), is_on_floor())
	animation_handler.update_move_state(input, running)
	camera_handler.aim_controls()
	
	if camera_handler.aiming and camera_handler.view_centered: ##Has to be run in the player's script to avoid useless errors. Works with or without
		visuals.rotation.y = twist_pivot.rotation.y + PI
	elif camera_handler.view_centered:
		twist_pivot.rotation.y = lerp_angle(twist_pivot.rotation.y, visuals.rotation.y + PI, 0.1) #centers the camera's y rotation to be behind the visuals
		pitch_pivot.rotation.x = lerp_angle(pitch_pivot.rotation.x, 0, 0.15)
func _physics_process(delta) -> void:
	gun_behavior()
	movement(delta)
	move_and_slide()

## Handles modifying the player's location based on keyboard input [br][br]
## Inherits the behavior of [method MainLoop._physics_process] and is passed [param delta]
func movement(delta) -> void:
	input = Vector3(Input.get_axis("move_left","move_right"), 0.0, Input.get_axis("move_up","move_down"))
	if input:
		running = Input.is_action_pressed("run")
		physics_handler.change_speed(running)
		direction = (twist_pivot.basis * input).normalized() 
		velocity = physics_handler.get_velocity(velocity, direction)
		if !camera_handler.aiming: #Handles rotation of the model when appropriate
			var align = visuals.transform.looking_at(visuals.transform.origin - direction)
			visuals.transform = visuals.transform.interpolate_with(align, delta * 10.0)
	elif is_on_floor(): #Is only active when player input stops
		velocity = physics_handler.apply_friction(velocity, delta)
	
	if not is_on_floor(): # applies gravity reguardless of player input
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump") and is_on_floor(): # applies intial jump velocity.
		velocity.y = jump_velocity
		animation_handler.swap_weapon('none')
	if running: # unlockes the camera, signals the animation controller to play the run animation and change the weapon state to none, and modifies movement speed. 
		camera_handler.aiming = false
		animation_handler.swap_weapon('none')

##Preforms a series of checks to see if shooting should occur.
func gun_behavior():
	if not Input.is_action_just_pressed('shoot') or not camera_handler.aiming:
		return
	
	animation_handler.shoot()
	if aim_ray.is_colliding(): #Remember! aimray is on layer 2.
		var target = aim_ray.get_collider()
		target.queue_free()
