extends Node3D
class_name PhysicsHandler
##A special component meant to do physics calculations on request.



@export var walking_speed:= 3.0 ##Normal speed if running is not actively occuring
@export var running_speed:= 5.0 ##If running is set up this is the run speed
@export var speed_up_time:= 0.0
@export_range(0.05, 10, 0.005, "suffix:s") var slow_time:= 0.125 ##The amount of time in seconds it takes for the player to stop.
@export var jump_time: float = 0.6 ##The time in seconds that it should take for the Jump to occur
@export var jump_height: float = 1.45 ##The Height in meters that the jump should peak at

##The value that should be added to the velocity when jump is activated
@onready var jump_velocity:= gravity_formula(0.0)
##The gravity that is needed for the jump to complete in the given [b]jump_time[/b]
@onready var gravity = -1 * find_slope(gravity_formula)

var acceleration:= 0.5
var friction:= 0.0
##Current movement speed
var speed:= 3.0

##finds the derivative(slope) of a given function by sampling two points
func find_slope(my_func: Callable) -> float:
	var y1: float = my_func.call(0)
	var y2: float = my_func.call(1)
	var slope = y2-y1
	return slope

##Returns the output of a formula that is used to find the value of the derivative of a perabola at a given point.
func gravity_formula(x: float) -> float: 
	var h= jump_height
	var t= jump_time
	var y = -1*((4.0*jump_height)*((2.0*x)-jump_time))/pow(jump_time,2.0)
	return y

##Changes Velocity gradually
func apply_friction(velocity:Vector3, delta: float):
	var output: Vector3
	output.x = move_toward(velocity.x, 0, abs((friction)* delta)) 
	output.y = velocity.y 
	output.z = move_toward(velocity.z, 0, abs((friction)* delta))
	return output

##Calculates the change in velocity required to simulate friction using [member PhysicsHandler.slow_time]. Should be calculated when input is first released otherwise velocity just approaches zero.
func get_friction(velocity_at_release:Vector3) -> Vector3:
	var output:Vector3
	output.x = -1*velocity_at_release.x/slow_time
	output.z = -1*velocity_at_release.z/slow_time
	return output

func get_acceleration(velocity):
	var output:Vector3 = speed-velocity/speed_up_time
	return output

##Calculates the change in velocity required to simulate accelerating to a predefined speed.
func get_velocity(velocity: Vector3, direction: Vector3)-> Vector3:
	var output:=velocity
	output.x = move_toward(velocity.x, direction.x * speed , acceleration)
	output.z = move_toward(velocity.z, direction.z * speed , acceleration)
	return output

##Increases speed based on whether the parameter [param running] == [b]true[/b]
func change_speed(running:bool) -> float:
	if running:
		speed = move_toward(speed, running_speed, acceleration)
	else:
		speed = move_toward(speed, walking_speed, 0.1)
	return speed
