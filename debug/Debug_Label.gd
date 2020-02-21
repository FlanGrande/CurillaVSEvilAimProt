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
	var current_mouse_position_x = get_parent().get_local_mouse_position().x
	var current_mouse_position_y = get_parent().get_local_mouse_position().y
	var current_global_mouse_position_x = get_parent().get_global_mouse_position().x
	var current_global_mouse_position_y = get_parent().get_global_mouse_position().y
	var current_cast_position_x = get_parent().get_node("RayCast2DShoot").cast_to.x
	var current_cast_position_y = get_parent().get_node("RayCast2DShoot").cast_to.y
	var current_animation = get_parent().get_node("AnimationPlayer").get_current_animation()
	var aiming_angle = get_parent().angle_to_vector_x_degrees
	
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
		
		State.GRABBING:
			current_state = "GRABBING"
		
		State.CLIMBING:
			current_state = "CLIMBING"
	
	$dbgState.set_debug_value(str(current_state))
	$dbgSpeed.set_debug_value(str(current_speed))
	$dbgOnFloor.set_debug_value(str(current_ground))
	$dbgLocalMousePos.set_debug_value(str(current_mouse_position_x).pad_decimals(2) + ", " + str(current_mouse_position_y).pad_decimals(2))
	$dbgGlobalMousePos.set_debug_value(str(current_global_mouse_position_x).pad_decimals(2) + ", " + str(current_global_mouse_position_y).pad_decimals(2))
	$dbgCastPos.set_debug_value(str(current_cast_position_x).pad_decimals(2) + ", " + str(current_cast_position_y).pad_decimals(2))
	$dbgAnimation.set_debug_value(str(current_animation))
	$dbgAimingAngle.set_debug_value(str(aiming_angle))