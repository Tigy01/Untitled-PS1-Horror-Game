@tool
extends CameraHandler

var aiming:= false ## A boolean value that is used for checking if the user is aiming
var view_centered:= false ## A boolean that outlines whether the camera is centered behind the player"s back when aiming

signal changed_weapon(weapon: String)##Allows Remote calls to the [AnimationHandler]

## Handles modifying the player's camera based on whether the aim input is active.
func aim_controls(running, delta) -> void:
	if running: # unlockes the camera, signals the animation controller to play the run animation and change the weapon state to none, and modifies movement speed. 
		aiming = false
		changed_weapon.emit("none")
	if Input.is_action_just_pressed("aim"): #Centers View and changes the joypad's sensativity
		joy_hori_sensitivity = 0.025
		await get_tree().create_timer(0.25).timeout
		view_centered = true
	if Input.is_action_pressed("aim") and not running:
		camera_spring_arm.spring_length = lerp(camera_spring_arm.spring_length, camera_distance/2, 3.125 * delta) #Shortens spring arm to allow the camera to get closer to the head
		camera_spring_arm.position = lerp(camera_spring_arm.position, Vector3(0,0.185,0), 6 * delta) #Moves camera to the over the shoulder position
		changed_weapon.emit("rifle")
		aiming = true
		return
	else:
		joy_hori_sensitivity = 0.05
		camera_spring_arm.spring_length = lerp(camera_spring_arm.spring_length, camera_distance, 3.125 *delta) #Moves camera to the normal position
		camera_spring_arm.position = lerp(camera_spring_arm.position, Vector3.ZERO, 6 * delta)
		aiming = false
	view_centered = false

func _input(event):
	if (aiming and not view_centered):
		return
	camera_control(event)
