extends Node3D
class_name CameraHandler

@onready var twist_pivot = $TwistPivot ##Point around which the camera [i]horizontally[/i] rotates
@onready var pitch_pivot = $TwistPivot/PitchPivot ##Point around which the camera [i]vertically[/i] rotates
@onready var camera_spring_arm = $"TwistPivot/PitchPivot/Camera Spring Arm" ##Prevents camera clipping into walls

var joy_hori_sensitivity:= 0.05  ## Horizontal sensitivity value for stick look 
var joy_vert_sensitivity:= 0.025 ## Vertical sensitivity value for stick look 
var mouse_hori_sensitivity:= 0.001 ## Horizontal sensitivity value for mouse look 
var mouse_vert_sensitivity:= 0.001 ## Vertical sensitivity value for mouse look
var aim:= false ## A boolean value that is used for checking if the user is aiming
var view_centered:= false ## A boolean that outlines whether the camera is centered behind the player's back when aiming

signal change_weapon(weapon: String)##Allows Remote calls to the [AnimationHandler]

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## Handles modifying the player's camera based on whether the aim input is active.
func update() -> void:
	if (aim and view_centered) or (!aim): #doesnt engage if aiming but not centered
		var axis_vector= Vector2(Input.get_axis('look_left','look_right'), Input.get_axis('look_down','look_up'))
		twist_pivot.rotate_y(-axis_vector.x * joy_hori_sensitivity) #twist_pivot.
		pitch_pivot.rotate_x(axis_vector.y * joy_vert_sensitivity) #pitch_pivot.
		pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-60), deg_to_rad(30))

	if Input.is_action_just_pressed("aim"): #Centers View and changes the joypad's sensativity
		joy_hori_sensitivity = 0.025
		await get_tree().create_timer(0.25).timeout
		view_centered = true
	
	if Input.is_action_pressed("aim") and not Input.is_action_pressed("run"):
		camera_spring_arm.spring_length = lerp(camera_spring_arm.spring_length, 0.55, 0.05) #Shortens spring arm to allow the camera to get closer to the head
		camera_spring_arm.position = lerp(camera_spring_arm.position, Vector3(0,0.185,0), 0.1) #Moves camera to the over the shoulder position
		change_weapon.emit('rifle')
		aim = true
	else:
		joy_hori_sensitivity = 0.05
		camera_spring_arm.spring_length = lerp(camera_spring_arm.spring_length, 1.0, 0.05) #Moves camera to the normal position
		camera_spring_arm.position = lerp(camera_spring_arm.position, Vector3.ZERO, 0.1)
		view_centered = false
		aim = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if (aim and view_centered) or (not aim): #doesnt engage if aiming but not centered
			twist_pivot.rotate_y(-event.relative.x * mouse_hori_sensitivity) #twist_pivot.
			pitch_pivot.rotate_x(-event.relative.y * mouse_vert_sensitivity) #pitch_pivot.
			pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-60), deg_to_rad(30))
#			#returns negative of how far the mouse moved (event.relative (VEC2)) since last checked multiplied by sensativity
