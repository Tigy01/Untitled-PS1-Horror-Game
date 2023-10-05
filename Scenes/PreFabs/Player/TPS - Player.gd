class_name Player
extends CharacterBody3D
## This is the Player's control script and is meant to handle movement and Animation.
##
## This is not meant to actually singal changes to the animator node, rather it should signal changes to the Player animation controller.

var input:= Vector2.ZERO ## A [Vector3] representing the players input. The y value is not used but is needed for the [member Transform3D.basis] calculations to work.

@onready var animation_handler: AnimationHandler = $Visuals/AnimationHandler
@onready var camera_handler: CameraHandler = $TPSCameraHandler
@onready var physics_handler: PhysicsHandler = $PhysicsHandler

@onready var aim_ray: RayCast3D = $"TPSCameraHandler/TwistPivot/PitchPivot/Camera Spring Arm/Camera3D/AimRay" ## The raycast used for hitscan weapons
@onready var twist_pivot: Node3D = $TPSCameraHandler/TwistPivot ## A node that is used to rotate the Camera [i]horizontally[/i] around a point
@onready var pitch_pivot: Node3D = $TPSCameraHandler/TwistPivot/PitchPivot ## A node that is used to rotate the Camera [i]vertically[/i] around a point
@onready var visuals: Node3D = $Visuals
@onready var interaction_body = $InteractionBody

func _ready():
	animation_handler.animation_ready(physics_handler.walking_speed, physics_handler.running_speed)

func _process(delta) -> void:
	animation_handler.update(input, clamp((rad_to_deg(pitch_pivot.rotation.x) / 45), -1, 1), is_on_floor())
	animation_handler.update_move_state(input, physics_handler.running)
	camera_handler.aim_controls(physics_handler.running, delta)
	if camera_handler.aiming and camera_handler.view_centered: ## Has to be run in the player's script to avoid useless errors. Works with or without
		visuals.rotation.y = twist_pivot.rotation.y + PI # Rotates visuals to face the where the camera is.
	elif camera_handler.aiming:
		twist_pivot.rotation.y = lerp_angle(twist_pivot.rotation.y, visuals.rotation.y + PI, 6.0 * delta) # Centers the camera's y rotation to be behind the visuals
		pitch_pivot.rotation.x = lerp_angle(pitch_pivot.rotation.x, 0, 9.0 * delta)
		camera_handler.center_view()

func _physics_process(delta) -> void:
	_gun_behavior()
	_movement(delta)

## Preforms a series of checks to see if shooting should occur.
func _gun_behavior() -> void:
	if not Input.is_action_just_pressed("shoot") or not camera_handler.aiming:
		return
	animation_handler.shoot()
	if aim_ray.is_colliding(): # Remember! aimray is on layer 2.
		var target = aim_ray.get_collider()
		target.queue_free()

## Handles modifying the player's location based on keyboard input [br][br]
## Inherits the behavior of [method MainLoop._physics_process] and is passed [param delta]
func _movement(delta) -> void:
	if not is_on_floor(): # Applies gravity reguardless of player input
		velocity = physics_handler.get_gravity(velocity, delta)
	elif Input.is_action_just_pressed("jump"): # Applies intial jump velocity.
		velocity.y = physics_handler.get_jump_velocity()
		animation_handler.swap_weapon("none")
	input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (twist_pivot.basis * Vector3(input.x, 0, input.y)).normalized() # Motified
	if direction: 
		velocity = physics_handler.apply_acceleration(velocity, direction, delta)
		if !camera_handler.aiming:
			var align = visuals.transform.looking_at(visuals.transform.origin - direction)
			visuals.transform = visuals.transform.interpolate_with(align, delta * 10.0)
	elif is_on_floor(): #Is only active when player input stops
		velocity = physics_handler.apply_friction(velocity, delta)
	move_and_slide()
