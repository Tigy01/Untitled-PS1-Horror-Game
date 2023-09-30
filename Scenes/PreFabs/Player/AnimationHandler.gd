class_name AnimationHandler
extends AnimationTree
## Is responsible for changing between animation states and blend positions based on calls from the player script
#
## This is used to help simplify and shorten the process of animating player actions from the Player Controller 
## and should be the only script that directly sets properties of the Animation Tree.

var _equipped_weapon:= "none" ##String value representing which is the currently equipped weapon
var _move_state:= -1.0 ## A value with a range from zero to 1 which controls movement animations
var _time_delta: float

@onready var _top_state_machine: AnimationNodeStateMachinePlayback = self["parameters/playback"] ##The topmost state machine that controls switching between weapon animations and weaponless animations
@onready var _weapon_state_machine: AnimationNodeStateMachinePlayback = self["parameters/Weapon/playback"] ##Handles transitioning between weapon animations

func animation_ready(walk_speed: float, run_speed: float):
	set("parameters/Weapon/Rifle/Fix/add_amount", 0.2)
	set("parameters/Weaponless/WalkScale/scale", walk_speed/1.8)
	set("parameters/Weaponless/RunScale/scale", run_speed/3.0)

func _process(delta):
	_time_delta = delta

func shoot():
	set("parameters/Weapon/Rifle/Shoot/request", true)

##Changes the weapon who's animation should be playing.
##[param weapon] is taken from the [Player] 
func swap_weapon(weapon):
	_equipped_weapon = weapon
	match _equipped_weapon:
		"none":
			_top_state_machine.travel("Weaponless")
			set("parameters/Weaponless/walk_state/blend_amount", _move_state)
		"rifle":
			_top_state_machine.travel("Weapon")
			_weapon_state_machine.travel("Rifle")

##Requests the [b]Shoot[/b] OneShot to play
## [b]Handles changing the active animation states and lerping between blend positions.[/b][br][br]
## [param input] is the [member Player.input] variable and is used to control[br]
## [param aim] is a boolean that is passed in order to control whether the player is actively aiming their weapon[br]
## [param look] is a float that sets how much the player should look up or down and ranges from [b]-1[/b] to [b]1[/b]. [br]
## [param on_floor] is passed in from the [method CharacterBody3D.is_on_floor] method.
func update(input, look: float, on_floor: bool): 
	var aim  = Input.is_action_pressed("aim")
	var jump_blend = move_toward(get("parameters/Weaponless/Jump/blend_amount"), not on_floor, 5.0 * _time_delta)
	set("parameters/Weaponless/Jump/blend_amount", jump_blend) 
	match _equipped_weapon: ##
		"none":
			set("parameters/Weaponless/walk_state/blend_amount", _move_state)
		"rifle":
			set("parameters/Weapon/Rifle/Aim/blend_amount", 
					move_toward(get("parameters/Weapon/Rifle/Aim/blend_amount"), 
					aim, 5.0 * _time_delta))
			set("parameters/Weapon/Rifle/Strafe/blend_position", 
					lerp(get("parameters/Weapon/Rifle/Strafe/blend_position"), 
					Vector2(input.x, input.y), 6.25 * _time_delta))
			set("parameters/Weapon/Rifle/Look/add_amount", look)
			set("parameters/Weapon/Rifle/Lowered/blend_position", _move_state)

##Alters movestate to go between walking, running, and stopped.
func update_move_state(input, running):
	if input:
		_move_state= move_toward(_move_state, running, 6.25 * _time_delta) #if walking running = 0. If running running = 1
	else:
		_move_state = move_toward(_move_state, -1.0, 6.25 * _time_delta)
