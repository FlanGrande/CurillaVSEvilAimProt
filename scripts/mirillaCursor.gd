extends Node2D

# class member variables go here, for example:
const MOUSE_MIN_X = 0
const MOUSE_MAX_X = 0
const MOUSE_MIN_Y = 0
const MOUSE_MAX_Y = 0
const aim_range = 250

var mouse_position = Vector2(0, 0)
onready var cura = get_parent().get_node("cura2D")

func _ready():	
	position  = cura.position
	
	pass

func _process(delta):
	mouse_position = get_viewport().get_mouse_position()
	position = Vector2(mouse_position)
	
	if(position.distance_to(cura.position) >= aim_range):
		position = cura.position
	
	#MOUSE_MIN_X = cura.position.x - aim_range.x
	#MOUSE_MAX_X = cura.position.x + aim_range.x
	
	#MOUSE_MIN_Y = cura.position.y - aim_range.y
	#MOUSE_MAX_Y = cura.position.y + aim_range.y
	
	#if(position.x < MOUSE_MIN_X):
	#	position.x = MOUSE_MIN_X
	
	#if(position.x > MOUSE_MAX_X):
	#	position.x = MOUSE_MAX_X
	
	#if(position.y < MOUSE_MIN_Y):
	#	position.y = MOUSE_MIN_Y
	
	#if(position.y > MOUSE_MAX_Y):
	#	position.y = MOUSE_MAX_Y
	
	
	
	pass
