extends Node2D

@export var move_speed : int = 750

var moving : bool = false # If the stone is in transit
var destination : Vector2 # Where the stone should be

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	set_random_colour()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global_position == destination:
		moving = false
	if moving: 
		global_position = global_position.move_toward(destination, delta*move_speed)
	
'''
start_move
- Sets the destination to the given target and tells the stone to start moving
'''
func start_move(target : Vector2):
	destination = target
	moving = true
	
'''
set_random_colour
- Gives the stone a random colour
'''
func set_random_colour():
	modulate = Color(randf(),randf(),randf())
