extends KinematicBody2D

signal priest_shoot

onready var jump_timer = get_node("jump_timer")

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

var current_state = State.FALLING

# general variables
onready var window = get_tree().get_root();
var spawn = Vector2(320, 480);

# camera variables
var cam_target_position = Vector2(0.0, 0.0) #Position the camera is moving to
var cam_max_range = Vector2(46, 46) #Max distance from the character to the camera. Not used for now. Maximum recommended is about 50. Minimum 0.
onready var camera = get_node("camera")

# animation_variables
const MAX_ANIMATION_PLAYBACK_SPEED = 1.3
const MIN_ANIMATION_PLAYBACK_SPEED = 0.7
var playback_speed_increment = 1.01
var playback_animation_speed = 1.3

# movement variables // Experiment with values, A LOT
const MAX_SPEED_WALK = 60 #Character maximum allowed speed when walking
const MAX_SPEED_RUN = 300 #Character maximum allowed speed when running
const MAX_SPEED_HORIZONTAL_JUMP = Vector2(200, 400) #Character maximum allowed speed when jumping horizontally
const MAX_SPEED_VERTICAL_JUMP = Vector2(0, 500) #Character maximum allowed speed when jumping while standing still
var max_speed = Vector2(MAX_SPEED_WALK, 500) #Current max_speed
var target_speed = 0 #speed will change speed gradually towards this value
var char_acceleration = Vector2(6.2, 4.0) #Character x movement and gravity
var char_deceleration = Vector2(1, 12) #Character x movement and gravity
#var char_jump_acceleration = Vector2(200, 700) #Character acceleration
var horizontal_jump_speed = Vector2(50, 250)
var vertical_jump_speed = 300
var char_speed = Vector2(0.0, 0.0) #Current character speed
var right = true #Direction character is facing
var input_x = false #Player is not making any input on x axis
var input_y = false #Player is not making any input on y axis

# aiming system variables
var priest_shoulder #Point of origin from where the aiming system takes the angles. A sweet spot between shoulders and head, probably.
var shoulder_offset = -30
var aiming_vector = Vector2(0, 0) #Vector from the character origin to the mouse 
var angle_to_vector_x_radians = 0
var angle_to_vector_x_degrees = 0
var x_vector = Vector2(1, 0)
var angles_array = [] #Array that contains the keys of the angles_dict variable. Represents the available angles to pick from animations.
var aiming_arm_offset_when_flip_h = -4

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
	"205" : "aim350",
	"220" : "aim330",
	"230" : "aim315",
	"250" : "aim300",
	"260": "aim270",
	"280" : "aim270",
	"290": "aim300",
	"310" : "aim315",
	"320" : "aim330",
	"335" : "aim350",
	"345" : "aim350"
}

#shooting variables
onready var particles_shoot = get_node("Particles_shoot")

# mouse variables
var mouse_position = Vector2(0.0, 0.0)

var elapsed_time = 0.0

func _ready():
	#change_anim("idle")
	change_state(State.FALLING)
	pass

func _process(delta):
	handle_input()
	update()
	after_update()
	
	print(current_state)
	
	elapsed_time += delta
	
	var motion = char_speed
	#print(motion)
	move_and_slide(motion, Vector2(0, -1))
	
	if(position.y > window.size.y):
		respawn()
	
	pass

func handle_input():
	match current_state:
		State.IDLE:
			#movement_checks()
			
			if _flan_is_on_floor() and Input.is_action_just_pressed("ui_up"): #Up was pressed
				change_state(State.VERTICAL_JUMP)
				vertical_jump()
			
			if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
				move()
				walk()
		
		State.WALKING:
			move()
			walk()
			
			if _flan_is_on_floor() and Input.is_action_just_pressed("ui_up"): #Up was pressed
				change_state(State.VERTICAL_JUMP)
				vertical_jump()
			
			if Input.is_action_pressed("run"):
				run()
		
		State.RUNNING:
			move()
			
			if Input.is_action_pressed("run"):
				run()
			
			if(Input.is_action_just_pressed("ui_up")): #Up was pressed
				change_state(State.HORIZONTAL_JUMP)
				horizontal_jump()
		
		State.FALLING:
			air_checks()
			pass
		
		State.AIMING:
			if(Input.is_action_just_pressed("shoot")): #Up was pressed
				emit_signal("priest_shoot")
			#	change_state(State.SHOOTING)
		
		State.SHOOTING:
			#shoot()
			pass
		
		State.VERTICAL_JUMP:
			air_checks()
			pass
		
		State.HORIZONTAL_JUMP:
			air_checks()
			pass

func update():
	match(current_state):
		State.IDLE:
			change_anim("idle")
			air_checks()
			
			if(abs(char_speed.x) > 0.0):
				change_state(State.WALKING)
			
			if(Input.is_action_pressed("aim")):
				change_state(State.AIMING)
		
		State.WALKING:
			change_anim("walk")
			
			if abs(char_speed.x) == 0.0:
				change_state(State.IDLE)
				
			if abs(char_speed.x) > MAX_SPEED_WALK:
				change_state(State.RUNNING)
			
			if Input.is_action_pressed("aim"):
				change_state(State.AIMING)
			
			air_checks()
			decelerate()
		
		State.RUNNING:
			air_checks()
			
			if abs(char_speed.x) <= MAX_SPEED_WALK:
				change_state(State.WALKING)
			elif Input.is_action_pressed("run"):
				change_anim("run")
			
			if(Input.is_action_pressed("aim")):
				change_state(State.AIMING)
			
			decelerate()
		
		State.FALLING:
			change_anim("falling")
			
			if _flan_is_on_floor() and char_speed.y == 0.0:
				change_state(State.IDLE)
		
		State.AIMING:
			air_checks()
			aim_checks()
			
			#change_anim("aim0")
			if(not Input.is_action_pressed("aim")):
				change_state(State.IDLE)
		
		State.SHOOTING:
			#change_anim("aim0")
			pass
		
		State.VERTICAL_JUMP:
			if char_speed.y > 0:
				change_state(State.FALLING)
		
		State.HORIZONTAL_JUMP:
			if char_speed.y > 0:
				change_state(State.FALLING)

func after_update():
	resolve_look_direction()
	
	#Max x speed
	if (abs(char_speed.x) > max_speed.x):
		change_char_x_speed(sign(char_speed.x) * max_speed.x)
	
	#Max y speed
	if (abs(char_speed.y) > max_speed.y):
		char_speed.y = sign(char_speed.y) * max_speed.y
	
	#Max playback_animation_speed
	if playback_animation_speed > MAX_ANIMATION_PLAYBACK_SPEED:
		change_anim_speed(MAX_ANIMATION_PLAYBACK_SPEED)
	
	if playback_animation_speed < MIN_ANIMATION_PLAYBACK_SPEED:
		change_anim_speed(MIN_ANIMATION_PLAYBACK_SPEED)
	
	if is_character_idle():
		change_state(State.IDLE)

func move():
	if Input.is_action_pressed("ui_right"):
		change_char_x_speed(char_speed.x + char_acceleration.x)
		input_x = true
	elif Input.is_action_pressed("ui_left"):
		change_char_x_speed(char_speed.x - char_acceleration.x)
		input_x = true
	else:
		input_x = false

func walk():
	#playback_animation_speed = playback_animation_speed * playback_speed_increment
	#change_anim_speed(playback_animation_speed)
	max_speed.x = MAX_SPEED_WALK

func run():
	#change_anim_speed(MIN_ANIMATION_PLAYBACK_SPEED)
	playback_animation_speed = playback_animation_speed * playback_speed_increment
	change_anim_speed(playback_animation_speed)
	max_speed.x = MAX_SPEED_RUN
	#get_node("AnimationPlayer").get_current_animation()

func vertical_jump():
	#If not running, do vertical jump. This is a Prince of Persia style jump that initiates climbing.
	#change_anim("horizontal_jump")
	max_speed = Vector2(0,  MAX_SPEED_VERTICAL_JUMP.y)
	char_speed.y = -1 * vertical_jump_speed
	jump_timer.start()
	char_speed.x = 0

func horizontal_jump():
	#If running, do horizontal jump. It should be useful to move across ledges, avoid traps, or climb to far ledges.
	
	#if (Input.is_action_pressed("ui_right") or (Input.is_action_pressed("ui_left"))):
	change_anim("horizontal_jump")
	char_speed.x = char_speed.x * 1.3
	change_anim_speed(1.6)
	max_speed = MAX_SPEED_HORIZONTAL_JUMP
	#char_speed.x = sign(char_speed.x) * char_speed.x
	char_speed.y = -1 * horizontal_jump_speed.y
	jump_timer.start()

func shoot():
	particles_shoot.emitting = true

func _flan_is_on_floor():
	return test_move(get_transform(), Vector2(0, 1))

func movement_checks():
	pass
#	if current_state != State.JUMPING and current_state == State.FALLING or not input_x:
#		if right:
#			char_speed.x -= char_acceleration.x
#			if(char_speed.x < 0): char_speed.x = 0
#		else:
#			char_speed.x += char_acceleration.x
#			if(char_speed.x > 0): char_speed.x = 0
#
#		playback_animation_speed /= playback_speed_increment
	

func air_checks():
	char_speed.y += char_acceleration.y
	
	#if(jumping):
		#char_speed.x = sign(char_speed.x) * (abs(char_speed.x) * abs(char_speed.x))
	
	if(test_move(get_transform(), Vector2(1, 0)) or test_move(get_transform(), Vector2(-1, 0)) and char_speed.y > 0):
		change_char_x_speed(0)
	
	if(test_move(get_transform(), Vector2(0, 1))):
	#if(is_on_floor()):
		#change_state(State.IDLE)
		char_speed.y = 0

func aim_checks():
	change_state(State.AIMING)
	change_char_x_speed(0) #Stop the priest
	mouse_position = get_global_mouse_position()
	priest_shoulder = Vector2(global_position.x, global_position.y + shoulder_offset)
	aiming_vector = mouse_position - priest_shoulder
	angle_to_vector_x_radians = (aiming_vector).normalized()
	angle_to_vector_x_degrees = angle_to_vector_x_radians.angle_to(x_vector) * 180/PI #Convert radians to angles
	angles_array = angles_dict.keys()
	
	if(angle_to_vector_x_degrees < 0): #If angle to X axis is less than 0, add 360 degrees to make it positive
		angle_to_vector_x_degrees = angle_to_vector_x_degrees + 360
	
	#print(angle_to_vector_x_degrees)
	
	var angle_to_show = "aim0"
	
	for i in range(0, angles_dict.size()):
		if(angle_to_vector_x_degrees < int(angles_array[i])):
			angle_to_show = angles_dict[angles_array[i - 1]]
			break
	
	change_anim(angle_to_show)

func camera_checks():
	cam_target_position = global_position #Default position if not aiming (follow the character)
	mouse_position = get_global_mouse_position()
	priest_shoulder = Vector2(global_position.x, global_position.y - shoulder_offset)
	aiming_vector = mouse_position - priest_shoulder
	
	if(current_state == State.AIMING):
		cam_target_position.x = global_position.x + aiming_vector.x * cam_max_range.x/100
		cam_target_position.y = global_position.y + aiming_vector.y * cam_max_range.y/100
	
	camera.global_position = cam_target_position

func invert_shooting_particles():
	particles_shoot.position = Vector2(particles_shoot.position.x * -1 + aiming_arm_offset_when_flip_h, particles_shoot.position.y)
	particles_shoot.rotation = particles_shoot.rotation * -1 - 180 * PI/180	#convert 180 degrees to radians

#This function sets a new target speed and gradually changes towards that value.
func change_char_x_speed(newspeed):
	target_speed = newspeed
	
	if char_speed.x < target_speed:
		char_speed.x += char_acceleration.x
	elif char_speed.x > target_speed:
		char_speed.x -= char_acceleration.x
	
	pass

func change_state(state):
	current_state = state

func change_anim(newanim):
	#print(newanim)
	#If the animation is new,
	if (newanim != get_node("AnimationPlayer").get_current_animation()):
		#print(newanim)
		get_node("AnimationPlayer").play(newanim) #Change it!

func change_anim_speed(newanimspeed):
	playback_animation_speed = newanimspeed
	get_node("AnimationPlayer").playback_speed = newanimspeed #Change it!

func is_character_idle():
	return not input_x and not input_y and current_state != State.AIMING and current_state != State.FALLING and current_state != State.VERTICAL_JUMP and current_state != State.HORIZONTAL_JUMP and char_speed.x == 0 and char_speed.y == 0 and current_state != State.SHOOTING

#Figures out which way to look. Left or Right.
func resolve_look_direction():
	if char_speed.x > 0.0:
		look_to_the_right(true)
	elif char_speed.x < 0.0:
		look_to_the_right(false)
	
	if current_state == State.AIMING:
		if(angle_to_vector_x_degrees < 90 or angle_to_vector_x_degrees > 270):
			look_to_the_right(true)
		else:
			invert_shooting_particles()
			look_to_the_right(false)

#Flips the character to the right, if true.
func look_to_the_right(enabled):
	right = enabled
	get_node("Sprite").set_flip_h(not enabled)
	get_node("aiming_arm").set_flip_h(not enabled)

func decelerate():
	if current_state != State.HORIZONTAL_JUMP and current_state != State.VERTICAL_JUMP and current_state == State.FALLING or not input_x:
		if right:
			char_speed.x -= char_acceleration.x
			if(char_speed.x < 0): char_speed.x = 0
		else:
			char_speed.x += char_acceleration.x
			if(char_speed.x > 0): char_speed.x = 0
		
		playback_animation_speed /= playback_speed_increment

func respawn():
	position = spawn

func _on_ClimbCollider_body_entered(body):
	if body.is_in_group("areaTrepar"):
		print("areaTrepar body entered")
		if current_state == State.GRABBING:
			position.y = body.global_position.y - get_node("CollisionShape2D").shape.extents.y
			char_speed.y = 0
			#Climbing
	pass # Replace with function body.


func _on_cura2D_priest_shoot():
	shoot()
