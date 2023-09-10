extends Node3D
class_name CameraHandler

@onready var twist_pivot: Node3D = $TwistPivot ##Point around which the camera [i]horizontally[/i] rotates
@onready var pitch_pivot: Node3D = $TwistPivot/PitchPivot ##Point around which the camera [i]vertically[/i] rotates
@onready var camera_spring_arm: SpringArm3D = $"TwistPivot/PitchPivot/Camera Spring Arm" ##Prevents camera clipping into walls

var joy_hori_sensitivity:= 0.05  ## Horizontal sensitivity value for stick look 
var joy_vert_sensitivity:= 0.025 ## Vertical sensitivity value for stick look 
var mouse_hori_sensitivity:= 0.001 ## Horizontal sensitivity value for mouse look 
var mouse_vert_sensitivity:= 0.001 ## Vertical sensitivity value for mouse look

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	camera_control(event)

#Separated into own method so a subclass can add checks to input without needing to copy all this code
##Takes input events and rotates pivots based on it.
func camera_control(event): 
	var twist_amount:float
	var pitch_amount:float
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: #if mouse input
		twist_amount = -event.relative.x * mouse_hori_sensitivity
		pitch_amount = -event.relative.y * mouse_vert_sensitivity
	elif event is InputEventJoypadMotion: #if joypad input
		var axis_vector= Vector2(Input.get_axis('look_left','look_right'), Input.get_axis('look_down','look_up')) #Direction of event.
		twist_amount = -axis_vector.x * joy_hori_sensitivity
		pitch_amount = axis_vector.y * joy_vert_sensitivity
	
	twist_pivot.rotate_y(twist_amount) #twist_pivot.
	pitch_pivot.rotate_x(pitch_amount) #pitch_pivot.
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-60), deg_to_rad(30))
