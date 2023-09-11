extends Node3D
class_name PhysicsHandler
##A special component meant to do physics calculations on request.

@export_range(0.05, 100, 0.5, "suffix:m/s") var walking_speed:= 3.0 ##Normal speed if running is not actively occuring
@export_range(0.05, 100, 0.5, "suffix:m/s") var running_speed:= 5.0 ##If running is set up this is the run speed
@export_range(0.05, 10, 0.005, "suffix:s") var speed_up_time:= 0.5##The amount of time in seconds it takes for the player to stop.
@export_range(0.05, 10, 0.005, "suffix:s") var slow_time:= 0.125 ##The amount of time in seconds it takes for the player to stop.
@export_range(0.05, 10, 0.005, "suffix:s") var jump_time: float = 0.6 ##The time in seconds that it should take for the Jump to occur
@export_range(0.05, 30, 0.05, "suffix:m") var jump_height: float = 1.45 ##The Height in meters that the jump should peak at

@onready var jump_velocity:= gravity_formula(0.0)##The value that should be added to the velocity when jump is activated
@onready var gravity = -1 * find_slope(gravity_formula)##The gravity that is needed for the jump to complete in the given [b]jump_time[/b]

var acceleration:= Vector3.ZERO
var place_holder:= 0.5
var friction:= Vector3.ZERO
var speed:= 3.0 ##Current movement speed
var recalculate_friction:= true

##finds the derivative(slope) of a given function by sampling two points
func find_slope(my_func: Callable) -> float:
	var y1: float = my_func.call(0)
	var y2: float = my_func.call(1)
	var slope = y2-y1
	return slope

##Returns the output of a formula that is used to find the value of the derivative of a perabola at a given point.
func gravity_formula(x: float) -> float: 
	var y = -1*((4.0*jump_height)*((2.0*x)-jump_time))/pow(jump_time,2.0)
	return y

##Calculates the change in velocity required to simulate friction using [member PhysicsHandler.slow_time]. Should be calculated when input is first released otherwise velocity just approaches zero.
func get_friction(velocity_at_release:Vector3):
	var scaled_slow_time = slow_time
	if velocity_at_release.length() > walking_speed:
		scaled_slow_time = slow_time * running_speed/walking_speed 
	friction.x = abs((-1*velocity_at_release.x)/scaled_slow_time)
	friction.z = abs((-1*velocity_at_release.z)/scaled_slow_time)

##Changes Velocity gradually
func apply_friction(velocity:Vector3, delta: float) -> Vector3:
	var output:= velocity
	output.x = move_toward(velocity.x, 0, friction.x* delta) 
	output.z = move_toward(velocity.z, 0, friction.z* delta)
	return output

##Calculates the change in velocity required to simulate accelerating to a predefined speed.
func apply_acceleration(velocity: Vector3, direction: Vector3, delta:float)-> Vector3:
	var output:=velocity
	output.x = move_toward(velocity.x, direction.x * speed , speed*delta/speed_up_time)
	output.z = move_toward(velocity.z, direction.z * speed , speed*delta/speed_up_time)
	get_friction(velocity)
	return output

##Increases speed based on whether the parameter [param running] == [b]true[/b]
func change_speed(running:bool) -> void:
	if running:
		speed = move_toward(speed, running_speed, 0.5)
	else:
		speed = move_toward(speed, walking_speed, 0.1)
