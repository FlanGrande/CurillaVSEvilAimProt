extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var mirilla
var elapsed_time = 0
var x = 0
var y = 0
var pos
var offset_x = 0
var acceleration_rate_x = 16
var speed_x = 8

var offset_y = 200
var acceleration_rate_y = 8
var speed_y = 3

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pos = get_transform()
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	elapsed_time += delta
	x = acceleration_rate_x * sin(elapsed_time * speed_x + offset_x)
	y = acceleration_rate_y * cos(elapsed_time * speed_y + offset_y)
	pos = Vector2(x,  y)
	move_and_collide(pos)
	print(pos)
	pass
