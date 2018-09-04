extends KinematicBody2D

# class member variables go here, for example:
var acel = Vector2(20, 0.8) #Acceleration
var vel = Vector2(0.0, 0.0) #Speed
var max_speed = Vector2(150, 100) #Maximum allowed speed
var right = true #Direction we are looking at
var input_x = false #We are not making any input in x
var input_y = false

# mouse variables
var mouse_position = Vector2(0, 0)

var elapsed_time = 0.0

func _ready():
	change_anim("idle")
	pass

func _process(delta):
	elapsed_time += delta
	move_input(delta)
	
	var motion = vel * delta
	move_and_collide(motion)
	pass

#Controls the input in an abstract way
func move_input(delta):
	if (Input.is_action_pressed("ui_right")):
		right = true #Looking to right
		input_x = true
		get_node("Sprite").set_flip_h(false) #Looking to right 
		
		if(Input.is_action_pressed("run")):
			change_anim("run")
			max_speed = Vector2(250, 100)
		else:
			change_anim("walk") #Walk anim
			max_speed = Vector2(150, 100)
		
		if(vel.x < 0):
			vel.x = 0
		
		vel.x += acel.x
	elif (Input.is_action_pressed("ui_left")):
		right = false
		input_x = true
		get_node("Sprite").set_flip_h(true) #Looking to left
		
		if(Input.is_action_pressed("run")):
			change_anim("run")
			max_speed = Vector2(250, 100)
		else:
			change_anim("walk") #Walk anim
			max_speed = Vector2(150, 100)
		
		if(vel.x > 0):
			vel.x = 0
		
		vel.x -= acel.x
	else:
		input_x = false
		vel.x = 0.0
	
	if(Input.is_action_pressed("aim")):
		change_anim("aimForward")
		max_speed = Vector2(0, 100)
		
		mouse_position = get_global_mouse_position()
		var direction = (mouse_position - global_position).normalized()
		var x_vector = Vector2(1, 0)
		var sin_of_angle = sin(direction.angle_to(x_vector))
		var cos_of_angle = cos(direction.angle_to(x_vector))
#		print("SIN: " + str(sin_of_angle))
#		print("COS: " + str(cos_of_angle))
		
		if(sin_of_angle >= 0.0):
			if(sin_of_angle > 0.85):
				change_anim("aimUp")
			else:
				if(sin_of_angle > 0.3):
					change_anim("aimUpForward")
				else:
					change_anim("aimForward")
		else:
			if(sin_of_angle < -0.85):
				change_anim("aimDown")
			else:
				if(sin_of_angle < -0.3):
					change_anim("aimDownForward")
				else:
					change_anim("aimForward")
		
		if(cos_of_angle >= 0):
			right = true #Looking to right
			get_node("Sprite").set_flip_h(false) #Looking to right
		else:
			right = false #Looking to left
			get_node("Sprite").set_flip_h(true) #Looking to left
	
	#Max x speed
	if (abs(vel.x) > max_speed.x):
		vel.x = sign(vel.x) * max_speed.x
		
	#If are doing nothing, then anim is idle
	if (is_character_idle()):
		change_anim("idle")

func change_anim(newanim):
	#If the animation is new,
	if (newanim != get_node("AnimationPlayer").get_current_animation()):
		get_node("AnimationPlayer").play(newanim) #Change it!

func is_character_idle():
	return not input_x and not input_y and not Input.is_action_pressed("aim")
