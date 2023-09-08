extends Node2D
class_name PhysicsHandler
##A special component meant to do physics calculations on request.

const acceleration:= 0.5
const running_speed:= 5.0
const walking_speed:= 3.0

##The amount of time in seconds it takes for the player to stop.
@export var slow_time:= 0.15


##The Height in meters that the jump should peak at
@export var JumpHeight: float = 1.35
##The time in seconds that it should take for the Jump to occur
@export var JumpTime: float = 0.5

##The value that should be added to the velocity when jump is activated
@onready var jumpVelocity:= gravity_formula(0.0)
##The gravity that is needed for the jump to complete in the given [b]JumpTime[/b]
@onready var gravity = find_gravity()

##Current movement speed
var speed:= 3.0

##finds the slope between x= 0 and x=1 for the gravity formula AKA the derivative of the gravity formula
func find_gravity() -> float:
	var x1: float =0.0
	var x2: float = 1.0
	var y1: float = gravity_formula(x1)
	var y2: float = gravity_formula(x2)
	var slope = (y2-y1)/(x2-x1)
	return slope

##Returns the output of a formula that is used to find the value of the derivative of a perabola at a given point.
func gravity_formula(x: float) -> float:
	var h= JumpHeight
	var t= JumpTime
	var y = -1*((4.0*h)*((2.0*x)-t))/pow(t,2.0)
	return y

func get_gravity() -> float:
	return gravity

##Calculates the change in velocity required to simulate friction. Goes from the current velocity to zero over the course of [member PhysicsHandler.slow_time]
func get_friction(velocity:Vector3, delta: float) -> Vector3:
	var output = Vector3(move_toward(velocity.x, 0, abs((velocity.x/slow_time)* delta)), velocity.y, move_toward(velocity.z, 0, abs((velocity.z/slow_time)* delta)))
	return output

##Calculates the change in velocity required to simulate accelerating to a predefined speed.
func get_velocity(velocity: Vector3, direction: Vector3)-> Vector3:
	var output:=velocity
	output.x = move_toward(velocity.x, direction.x * speed , acceleration) 
	output.z = move_toward(velocity.z, direction.z * speed , acceleration)
	return output

func change_speed(running:bool) -> float:
	if running:
		speed = move_toward(speed, running_speed, acceleration)
	else:
		speed = move_toward(speed, walking_speed, 0.1)
	return speed
