extends ColorRect

@onready var animator:= $AnimationPlayer
@onready var resume_button: Button = find_child("Resume_Button")
@onready var quit_button: Button = find_child("quit_Button")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	resume_button.pressed.connect(unpause)

func _unhandled_input(_event: InputEvent) -> void: #executes if an input does not interact with any node. EG a click that does not press any button will fire a gun
	if Input.is_action_just_pressed("Pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause()

func _on_quit_button_button_down():
	get_tree().paused = false
	get_tree().quit()

func pause():
	resume_button.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	animator.play("Pause")
	get_tree().paused = true

func unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animator.play("Unpause")
	get_tree().paused = false
