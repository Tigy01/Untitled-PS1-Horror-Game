extends CharacterBody3D
class_name Player
## This is the Player's control script and is meant to handle movement and Animation.
##
## This is not meant to actually singal changes to the animator node, rather it should signal changes to the Player animation controller.

@onready var animate: AnimationController = $"visuals/AnimationTree"
@onready var visuals = $visuals ##A node that is the parent to the Player's [MeshInstance3D](s), [AnimationController], and [Skeleton3D]
@onready var twist_pivot = $TwistPivot ##A node that is used to rotate the Camera [i]horizontally[/i] around a point
@onready var pitch_pivot = $TwistPivot/PitchPivot ##A node that is used to rotate the Camera [i]vertically[/i] around a point
@onready var aim_ray: RayCast3D = $"TwistPivot/PitchPivot/Camera Spring Arm/Camera3D/AimRay" ##The raycast used for hitscan weapons
@onready var camera_spring_arm: SpringArm3D = $"TwistPivot/PitchPivot/Camera Spring Arm" ##Prevents camera clipping into walls
@onready var physics_handler: PhysicsHandler = $PhysicsHandler

## A gravity calculated by the [PhysicsHandler]
@onready var gravity: float = physics_handler.gravity
##The inital velocity to be applied when the Jump Button is hit. Calculated by the [PhysicsHandler]
@onready var jump_velocity: float = physics_handler.jump_velocity

## Horizontal sensitivity value for mouse look 
var mouse_hori_sensitivity:= 0.001
## Vertical sensitivity value for mouse look 
var mouse_vert_sensitivity:= 0.001
## Horizontal sensitivity value for stick look 
var joy_hori_sensitivity:= 0.05
## Vertical sensitivity value for stick look 
var joy_vert_sensitivity:= 0.025

## A [Vector3] representing the players input. The y value is not used but is needed for the [member Transform3D.basis] calculations to work.
var input:= Vector3.ZERO

## A boolean value that is used for checking if the user is aiming
var aim:= false

## A boolean value used for checking if the camera has moved to center behind the character when aiming. 
## Without this the camera can lock on the characters side which is obviously not ideal. 
var view_centered:= false

##A boolean value that is used to specify if the character is meant to be running
var running:= false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta) -> void:
	animate.update(input, aim, clamp(((rad_to_deg(pitch_pivot.rotation.x))/45), -1, 1), is_on_floor(), running)
	aim_handler()

func _physics_process(delta: float) -> void:
	movement(delta)
	if (aim and view_centered) or (not aim): #doesnt engage if aiming but not centered
		var axis_vector= Vector2(Input.get_axis('look_left','look_right'), Input.get_axis('look_down','look_up'))
		twist_pivot.rotate_y(-axis_vector.x * joy_hori_sensitivity) #twist_pivot.
		pitch_pivot.rotate_x(axis_vector.y * joy_vert_sensitivity) #pitch_pivot.
		pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-60), deg_to_rad(30))
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if (aim and view_centered) or (not aim): #doesnt engage if aiming but not centered
			twist_pivot.rotate_y(-event.relative.x * mouse_hori_sensitivity) #twist_pivot.
			pitch_pivot.rotate_x(-event.relative.y * mouse_vert_sensitivity) #pitch_pivot.
			pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-60), deg_to_rad(30))
#			#returns negative of how far the mouse moved (event.relative (VEC2)) since last checked multiplied by sensativity

## Handles modifying the player's location based on keyboard input [br][br]
## Inherits the behavior of [method MainLoop._physics_process] and is passed [param delta]
func movement(delta) -> void:
	input = Vector3(Input.get_axis("move_left","move_right"), 0.0, Input.get_axis("move_up","move_down"))
	if input:
		var direction: Vector3 = twist_pivot.basis * input.normalized() #Makes forward the direction the camera is facing rather than an cardinal direction.
		velocity = physics_handler.get_velocity(velocity, direction)
		if not aim: #Handles rotation of the model when appropriate
			var align = visuals.transform.looking_at(visuals.transform.origin - direction)
			visuals.transform = visuals.transform.interpolate_with(align, delta * 10.0)
		
		if Input.is_action_pressed("run"): # unlockes the camera, signals the animation controller to play the run animation and change the weapon state to none, and modifies movement speed. 
			aim = false
			running = true
			physics_handler.change_speed(running)
			animate.swap_weapon('none')
		else:
			running = false
			physics_handler.change_speed(running)
			
	elif is_on_floor(): #Is only active when player input stops
		velocity = physics_handler.get_friction(velocity, delta)
		
	if not is_on_floor(): # applies gravity
		velocity.y += gravity * delta
	elif Input.is_action_just_pressed("jump") and is_on_floor()  : # applies intial jump velocity.
		velocity.y = jump_velocity

## Handles modifying the player's camera based on whether the aim input is active.
func aim_handler() -> void:
	if Input.is_action_just_pressed("aim"):
		joy_hori_sensitivity = 0.025
		await get_tree().create_timer(0.25).timeout
		view_centered = true
	if Input.is_action_pressed("aim"):
		camera_spring_arm.spring_length = lerp(camera_spring_arm.spring_length, 0.55, 0.05) #Shortens spring arm to allow the camera to get closer to the head
		camera_spring_arm.position = lerp(camera_spring_arm.position, Vector3(0,0.185,0), 0.1) #Moves camera to the over the shoulder position
		if not running: 
			animate.swap_weapon('rifle')
			aim = true
		if view_centered == true: #rotates visuals with the camera
			visuals.rotation.y = twist_pivot.rotation.y + PI
		else:
			twist_pivot.rotation.y = lerp_angle(twist_pivot.rotation.y, visuals.rotation.y + PI, 0.1) #centers the camera's y rotation to be behind the visuals
			pitch_pivot.rotation.x = lerp_angle(pitch_pivot.rotation.x, 0, 0.15)
			
		if Input.is_action_just_pressed('shoot'):
			animate.shoot()
			if aim_ray.is_colliding():
				var target = aim_ray.get_collider()
				target.queue_free()
	else:
		joy_hori_sensitivity = 0.05
		camera_spring_arm.spring_length = lerp(camera_spring_arm.spring_length, 1.0, 0.05) #Moves camera to the normal position
		camera_spring_arm.position = lerp(camera_spring_arm.position, Vector3.ZERO, 0.1)
		view_centered = false
		aim = false
