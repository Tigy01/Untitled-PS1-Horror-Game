extends Node3D
class_name PhysicsHandler
##A special component meant to do physics calculations on request.
##################################################################
@export_group("Moving")
@export_subgroup("Walk")
@export_range(0.05, 100, 0.1, "suffix:m/s") var walking_speed:= 3.0 ##Normal speed if running is not actively occuring
@export_range(0.05, 10, 0.005, "suffix:s") var speed_up_time:= 0.135##The amount of time in seconds it takes for the player to stop.
@export_range(0.05, 10, 0.005, "suffix:s") var slow_time:= 0.125 ##The amount of time in seconds it takes for the player to stop.

@export_subgroup("Run")
@export var use_run:= false ##Enables running calculations.
@export_range(0.05, 100, 0.1, "suffix:m/s") var running_speed:= 5.0 ##If running is set up this is the run speed
var running:=false ##A boolean value that is used to specify if the character is meant to be running
var speed:= 3.0 ##Current movement speed
var acceleration:= Vector3.ZERO ##Acceleration when speeding up
var friction:= Vector3.ZERO ##Acceleration when slowing to a stop
var recalculate_friction:= true ##A boolean value that is used to specify if friction needs to be calculated again
##################################################################
@export_group("Jump")
@export var simple_jump:=true ##Disable this for control over peak and fall times.
@export_range(0.05, 10, 0.005, "suffix:s") var time_to_jump: float = 0.6: ##The time in seconds that it should take for the Jump to occur
	set(val):
			jump_time = val / 2
@export_range(0.05, 30, 0.05, "suffix:m") var jump_height: float = 1.45 ##The Height in meters that the jump should peak at
@export_subgroup("Complex Jump")
##The time in seconds it takes to get to the [member jump_height] of the jump
@export_range(0.05, 10, 0.005, "suffix:s") var time_to_peak: float = 0.3: 
	set(val):
		peak_time = val * 2
##The time in seconds it takes to get to the ground from the peak
@export_range(0.05, 10, 0.005, "suffix:s") var time_to_ground: float = 0.45:
	set(val):
		fall_time = val * 2
var jump_time = time_to_jump/2
var peak_time = time_to_peak *2 ##Needs to be used because of quirks with godots set_get
var fall_time = time_to_ground *2 ##Needs to be used because of quirks with godots set_get
var jump_velocity:float##The value that should be added to the velocity when jump is activated
##################################################################
@onready var gravity:float= abs(find_slope(other_gravity_formula, jump_time)) ##The gravity that is needed for the jump to complete in the given [member jump_time]
@onready var peak_gravity:float= abs(find_slope(gravity_formula, peak_time)) ##The gravity that is needed for the jump to complete in the given [member peak_time]
@onready var fall_gravity:float= abs(find_slope(gravity_formula, fall_time))##The gravity that is needed for the jump to complete in the given fall_time

##Calculates the change in velocity required to simulate accelerating to a predefined speed.
func apply_acceleration(velocity: Vector3, direction: Vector3, delta:float)-> Vector3:
	if use_run:
		running = Input.is_action_pressed("run")
		change_speed()
	var output:=velocity
	output.x = move_toward(velocity.x, direction.x * speed , speed*delta/speed_up_time)
	output.z = move_toward(velocity.z, direction.z * speed , speed*delta/speed_up_time)
	get_friction(velocity)
	return output

##Changes velocity gradually to reach zero.
func apply_friction(velocity:Vector3, delta: float) -> Vector3:
	running = false
	var output:= velocity
	output.x = move_toward(velocity.x, 0, friction.x* delta) 
	output.z = move_toward(velocity.z, 0, friction.z* delta)
	return output

##Increases speed based on whether the parameter [param running] == [b]true[/b]
func change_speed() -> void:
	if running:
		speed = move_toward(speed, running_speed, 0.5)
	else:
		speed = move_toward(speed, walking_speed, 0.1)

##finds the derivative(slope) of a given linear function by sampling two points
func find_slope(my_func: Callable, time_interval) -> float:
	var y1: float = my_func.call(0, time_interval)
	var y2: float = my_func.call(1, time_interval)
	var slope = y2-y1
	return slope

func other_gravity_formula(x: float, time_interval: float):
	var y = ((-jump_height)*((2.0*x) - (2.0*time_interval)))/pow(time_interval,2.0)

##Returns the output of a formula that is used to find the value of the derivative of a perabola at a given point.
func gravity_formula(x: float, time_interval: float) -> float: 
	var y = -1*((4.0*jump_height)*((2.0*x)-time_interval))/pow(time_interval,2.0)
	return y

##Calculates the change in velocity required to simulate friction using [member slow_time]. 
##Should be calculated when input is first released otherwise velocity just approaches zero.
func get_friction(velocity_at_release:Vector3):
	var scaled_slow_time = slow_time
	if velocity_at_release.length() > walking_speed:
		scaled_slow_time = slow_time * running_speed/walking_speed 
	friction.x = abs((-1*velocity_at_release.x)/scaled_slow_time)
	friction.z = abs((-1*velocity_at_release.z)/scaled_slow_time)

##Appropriate Gravity based on [member Player.velocity] and [member simple_jump]
func get_gravity(y_velocity) ->float:
	if simple_jump:
		return gravity
	return peak_gravity if y_velocity>0 else fall_gravity #from zero to peak 

##Initial velocity of gravity function
func get_jump_velocity() ->float: 
	return other_gravity_formula(0.0, jump_time) if simple_jump else gravity_formula(0.0, peak_time)
