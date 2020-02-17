extends Control

# States
enum State {
	IDLE,
	WALKING,
	RUNNING,
	FALLING,
	AIMING,
	SHOOTING,
	VERTICAL_JUMP,
	HORIZONTAL_JUMP,
	GRABBING,
	CLIMBING
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current_state = get_parent().current_state
	var current_speed = get_parent().char_speed
	var current_ground = get_parent().ground
	
	match current_state:
		State.IDLE:
			current_state = "IDLE"
		
		State.WALKING:
			current_state = "WALKING"
		
		State.RUNNING:
			current_state = "RUNNING"
		
		State.FALLING:
			current_state = "FALLING"
		
		State.AIMING:
			current_state = "AIMING"
		
		State.SHOOTING:
			current_state = "SHOOTING"
		
		State.VERTICAL_JUMP:
			current_state = "VERTICAL_JUMP"
		
		State.HORIZONTAL_JUMP:
			current_state = "HORIZONTAL_JUMP"
		
		State.GRABBING:			current_state = "GRABBING"
		
		State.CLIMBING:
			current_state = "CLIMBING"
	
	$txtState.text = str(current_state)
	$txtSpeed.text = str(current_speed)
	$txtOnFloor.text = str(current_ground)