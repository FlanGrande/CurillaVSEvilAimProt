extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var gravity = Vector2(0, 500)
var acel = Vector2(20, 0.8) #Acceleration
var vel = Vector2(0.0, 0.0) #Speed
var max_speed = Vector2(150, 100) #Maximum allowed speed
var speedY = 100
var brake = 5.0 #Allows smooth brake
var brakelim = brake * 1.01 #Delete residual speed of brake
var right = true #Direction we are looking at
var input_x = false #We are not making any input in x

var elapsed_time = 0.0


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	change_anim("idle")
	pass

func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	elapsed_time += delta
	pass


func change_anim(newanim):
	#If the animation is new,
	if (newanim != get_node("AnimationPlayer").get_current_animation()):
		get_node("AnimationPlayer").play(newanim) #Change it!
