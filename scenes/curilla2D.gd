extends KinematicBody2D

# class member variables go here, for example:
var acel = Vector2(20, 0.8) #Acceleration
var vel = Vector2(0.0, 0.0) #Speed
var max_speed = Vector2(150, 100) #Maximum allowed speed
var right = true #Direction we are looking at
var input_x = false #We are not making any input in x
var input_y = false

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
		get_node("Sprite").set_flip_h(false)  #Looking to right 
		
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
		
		if (Input.is_action_pressed("ui_up")):
			input_y = true
			change_anim("aimUp")
			
			if(Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
				change_anim("aimUpForward")
		
		if (Input.is_action_pressed("ui_down")):
			input_y = true
			change_anim("aimDown")
			
			if(Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
				change_anim("aimDownForward")
		
	
	#Max x speed
	if (abs(vel.x) > max_speed.x):
		vel.x = sign(vel.x) * max_speed.x
		
	#If are doing nothing, then anim is idle
	if (not input_x and not input_y):
		change_anim("idle")

func change_anim(newanim):
	#If the animation is new,
	if (newanim != get_node("AnimationPlayer").get_current_animation()):
		get_node("AnimationPlayer").play(newanim) #Change it!