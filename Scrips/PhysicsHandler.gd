extends Node3D
class_name PhysicsHandler
##A special component meant to do physics calculations on request.

const acceleration:= 0.5
const running_speed:= 5.0
const walking_speed:= 3.0

##The amount of time in seconds it takes for the player to stop.
@export var slow_time:= 0.125

##The Height in meters that the jump should peak at
@export var jump_height: float = 1.45
##The time in seconds that it should take for the Jump to occur
@export var jump_time: float = 0.6

##The value that should be added to the velocity when jump is activated
@onready var jump_velocity:= gravity_formula(0.0)
##The gravity that is needed for the jump to complete in the given [b]jump_time[/b]
@onready var gravity = find_slope(gravity_formula)

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
	var y = -1*((4.0*h)*((2.0*x)-t))/pow(t,2.0)
	return y

##Calculates the change in velocity required to simulate friction. Goes from the current velocity to zero over the course of [member PhysicsHandler.slow_time]
func get_friction(velocity:Vector3, delta: float) -> Vector3:
	var output:= Vector3.ZERO
	output.x = move_toward(velocity.x, 0, abs((velocity.x/slow_time)* delta)) 
	output.y = velocity.y 
	output.z = move_toward(velocity.z, 0, abs((velocity.z/slow_time)* delta))
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
