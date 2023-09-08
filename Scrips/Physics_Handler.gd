extends Node2D

##The Height in meters that the jump should peak at
@export var JumpHeight: float = 1.35
##The time in seconds that it should take for the Jump to occur
@export var JumpTime: float = 0.5

##The value that should be added to the velocity when jump is activated
@onready var jumpVelocity:= gravityFormula(0.0)
##The gravity that is needed for the jump to complete in the given [b]JumpTime[/b]
@onready var gravity = findGravity()

##finds the slope between x= 0 and x=1 for the gravity formula AKA the derivative of the gravity formula
func findGravity() -> float:
	var x1: float =0.0
	var x2: float = 1.0
	var y1: float = gravityFormula(x1)
	var y2: float = gravityFormula(x2)
	var slope = (y2-y1)/(x2-x1)
	return slope

##Returns the output of a formula that is used to find the value of the derivative of a perabola at a given point.
func gravityFormula(x: float) -> float:
	var h= JumpHeight
	var t= JumpTime
	var y = -1*((4.0*h)*((2.0*x)-t))/pow(t,2.0)
	return y
