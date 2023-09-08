extends AnimationTree
class_name AnimationController
## Is responsible for changing between animation states and blend positions based on calls from the player script
#
## This is used to help simplify and shorten the process of animating player actions from the Player Controller 
## and should be the only script that directly sets properties of the Animation Tree.

var equipped_weapon:= 'none'
var move_state:= -1.0
var running:= false

var top_state: AnimationNodeStateMachinePlayback = self["parameters/playback"]
var weapon_state: AnimationNodeStateMachinePlayback = self["parameters/Weapon/playback"]

func _ready():
	set('parameters/Weapon/Rifle/Fix/add_amount', 0.2)

## [b]Handles changing the active animation states and lerping between blend positions.[/b][br][br]
## [param input] is the players [i]input[/i] variable and is used to control[br]
## [param aim] is a boolean that is passed in order to control whether the player is actively aiming their weapon[br]
## [param look] is a float that sets how much the player should look up or down and ranges from [b]-1[/b] to [b]1[/b]. [br]
## [param on_floor] is passed in from the [method CharacterBody3D.is_on_floor] method.
## [member Player.input]
func update(input, aim: bool, look: float, on_floor: bool): 
	set('parameters/Weaponless/Jump/blend_amount', move_toward(get('parameters/Weaponless/Jump/blend_amount'), not on_floor, .05)) #modifies the jump animation's effect
	if not input:
		move_state = move_toward(move_state, -1.0, .1)
	else:
		move_state= move_toward(move_state, running, .1) #if walking 
	
	match equipped_weapon: ##
		'none':
			set("parameters/Weaponless/walk_state/blend_amount", move_state)
		'rifle':
			set("parameters/Weapon/Rifle/Aim/blend_amount", move_toward(get("parameters/Weapon/Rifle/Aim/blend_amount"), aim, .015))
			set("parameters/Weapon/Rifle/Strafe/blend_position", lerp(get("parameters/Weapon/Rifle/Strafe/blend_position"), Vector2(input.x, input.z), .1))
			set("parameters/Weapon/Rifle/Look/add_amount", look)
			set("parameters/Weapon/Rifle/Lowered/blend_position", move_state)

## changes the 
func swap_weapon(weapon):
	equipped_weapon = weapon
	match equipped_weapon:
		'none':
			top_state.travel('Weaponless')
			set("parameters/Weaponless/walk_state/blend_amount", move_state)
		'rifle':
			top_state.travel('Weapon')
			weapon_state.travel('Rifle')

func shoot():
	set('parameters/Weapon/Rifle/Shoot/request', true)
