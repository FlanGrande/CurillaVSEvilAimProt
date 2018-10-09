extends KinematicBody2D

# camera variables
var cam_target_position = Vector2(0.0, 0.0) #Position the camera is moving to
var cam_max_range = Vector2(46, 46) #Max distance from the character to the camera. Not used for now. Maximum recommended is about 50. Minimum 0.
onready var camera = get_node("camera")

# movement variables
const MAX_SPEED_WALK = Vector2(150, 100) #Character maximum allowed speed when walking
const MAX_SPEED_RUN = Vector2(250, 100) #Character maximum allowed speed when running
var max_speed = MAX_SPEED_WALK #Current max_speed
var char_acceleration = Vector2(20.0, 0.8) #Character acceleration
var char_speed = Vector2(0.0, 0.0) #Current character speed
var right = true #Direction character is facing
var input_x = false #Player is not making any input on x axis
var input_y = false #Player is not making any input on y axis

# aiming system variables
var priest_shoulder #Point of origin from where the aiming system takes the angles
var shoulder_offset = -12
var aiming_vector = Vector2(0, 0) #Vector from the character origin to the mouse 
var angle_to_vector_x_radians = 0
var angle_to_vector_x_degrees = 0
var x_vector = Vector2(1, 0)
var angles_array = [] #Array that contains the keys of the angles_dict variable. Represents the available angles to pick from animations.
var aiming = false #Is character aiming?

#angles from 0 to 360 and animations names to use
#The idea behind this is to compare the keys and use the proper animation.
#E.g. if angle > 85 and angle < 105, use "aim90"
var angles_dict = {
	"0": "aim0",
	"20": "aim30",
	"35": "aim45",
	"55" : "aim60",
	"65" : "aim70",
	"75" : "aim80",
	"85" : "aim90",
	"95" : "aim90",
	"105" : "aim80",
	"115" : "aim70",
	"125" : "aim60",
	"145" : "aim45",
	"160" : "aim30",
	"180" : "aim0",
	"195" : "aim350",
	"205" : "aim340",
	"220" : "aim330",
	"230" : "aim315",
	"250" : "aim300",
	"260": "aim270",
	"280" : "aim270",
	"290": "aim300",
	"310" : "aim315",
	"320" : "aim330",
	"335" : "aim340",
	"345" : "aim350"
}

# mouse variables
var mouse_position = Vector2(0.0, 0.0)

var elapsed_time = 0.0

func _ready():
	change_anim("idle")
	pass

func _process(delta):
	elapsed_time += delta
	move_input(delta)
	
	var motion = char_speed * delta
	move_and_collide(motion)
	pass

#Controls the input in an abstract way
func move_input(delta):
	movement_checks() #Move left or right. Is character running?
	aim_checks() #Aim in 360 degrees.
	camera_checks()
	
	#Max x speed
	if (abs(char_speed.x) > max_speed.x):
		char_speed.x = sign(char_speed.x) * max_speed.x
		
	#If doing nothing, then change animation to idle
	if (is_character_idle()):
		change_anim("idle")

func movement_checks():
	#Check if player is running
	if(Input.is_action_pressed("run")):
		change_anim("run")
		max_speed = MAX_SPEED_RUN
	else:
		change_anim("walk") #Walk anim
		max_speed = MAX_SPEED_WALK
		
	if (Input.is_action_pressed("ui_right")):
		right = true #Looking to right
		input_x = true
		get_node("Sprite").set_flip_h(false) #Looking to right 
		
		if(char_speed.x < 0.0):
			char_speed.x = 0.0
		
		char_speed.x += char_acceleration.x
		
	elif (Input.is_action_pressed("ui_left")):
		right = false
		input_x = true
		get_node("Sprite").set_flip_h(true) #Looking to left
		
		if(char_speed.x > 0.0):
			char_speed.x = 0.0
		
		char_speed.x -= char_acceleration.x
		
	else:
		input_x = false
		char_speed.x = 0.0

func aim_checks():
	if(Input.is_action_pressed("aim")):
		aiming = true
		max_speed = Vector2(0, 100)	#Stop the priest
		mouse_position = get_global_mouse_position()
		priest_shoulder = Vector2(global_position.x, global_position.y + shoulder_offset)
		aiming_vector = mouse_position - priest_shoulder
		angle_to_vector_x_radians = (aiming_vector).normalized()
		angle_to_vector_x_degrees = angle_to_vector_x_radians.angle_to(x_vector) * 180/PI #Convert radians to angles
		angles_array = angles_dict.keys();
		
		if(angle_to_vector_x_degrees < 0): #If angle to X axis is less than 0, add 360 degrees to make it positive
			angle_to_vector_x_degrees = angle_to_vector_x_degrees + 360
		
		if(angle_to_vector_x_degrees < 90 or angle_to_vector_x_degrees > 270):
			right = true #Looking to right
			get_node("Sprite").set_flip_h(false) #Looking to right
		else:
			right = false #Looking to left
			get_node("Sprite").set_flip_h(true) #Looking to left
		
		for i in range(0, angles_dict.size()-1):
			if(angle_to_vector_x_degrees < int(angles_array[i])):
				var angle_to_show = angles_dict[angles_array[i-1]]
				change_anim(angle_to_show)
				break
			else:
				change_anim("aim0")
	else:
		aiming = false

func camera_checks():
	cam_target_position = global_position #Default position if not aiming (follow the character)
	mouse_position = get_global_mouse_position()
	priest_shoulder = Vector2(global_position.x, global_position.y - shoulder_offset)
	aiming_vector = mouse_position - priest_shoulder
	
	if(aiming):
		cam_target_position.x = global_position.x + aiming_vector.x * cam_max_range.x/100
		cam_target_position.y = global_position.y + aiming_vector.y * cam_max_range.y/100
	
	camera.global_position = cam_target_position

func change_anim(newanim):
	#If the animation is new,
	if (newanim != get_node("AnimationPlayer").get_current_animation()):
		get_node("AnimationPlayer").play(newanim) #Change it!

func change_camera_anim(newanim):
	#If the animation is new,
	if (newanim != get_node("AnimationCamera").get_current_animation()):
		get_node("AnimationCamera").play(newanim) #Change it!

func is_character_idle():
	return not input_x and not input_y and not Input.is_action_pressed("aim")