extends Node2D

var my_circles : Array = [] # The circles on my side of the board
var my_store : GameSpace # The store that belongs to me
var my_turn : bool = false # If it is my turn
var playing : bool = false # If I am currently playing

signal start_play

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	get_parent().ai_played.connect(_on_ai_played)
	var my_spaces = get_tree().get_nodes_in_group("Player2Circles")
	my_store = my_spaces.pop_front()
	my_circles = my_spaces
		
'''
_on_game_board_switch_turn
- If AI's side is in play, start play
'''
func _on_game_board_switch_turn(circle : GameSpace):
	await get_tree().create_timer(1).timeout
	if circle == my_circles[0]:
		my_turn = my_circles[0].active
		commence_turn()
	
'''
commence_turn
- Try playing, prioritises playing to store > to capture > random play
'''
func commence_turn():
	await get_tree().create_timer(1).timeout
	if !playing && my_turn:
		playing = true
		if await !try_store():
			if await !try_capture():
				await try_random()

'''
try_store
- See if any play is possible that ends in the last stone being in a store
- Prioritises circles closer to the store
'''
func try_store():
	var circles_size := my_circles.size()
	for i in range(circles_size-1,-1,-1): # Go back from the top circle
		var this_circle = my_circles[i]
		if (this_circle.here().size() + i) == 6: 
			start_play.emit(this_circle, my_store)
			return true

'''
try_capture
- Sees if it is possible to make a play that results in a capture
- Unable to see too far ahead, cannot purposefully make captures that loop over the entire board
'''
func try_capture():
	var target_circles := []
	for circle in my_circles:
		if circle.here().size() == 0:
			target_circles.append(circle)
	if target_circles:
		for circle in my_circles:
			if circle in target_circles: continue
			for target in target_circles:
				if (my_circles.find(circle) + circle.here().size()) == my_circles.find(target):
					start_play.emit(circle, my_store)
					return true

'''
try_random
- Plays a random circle if possible
'''
func try_random():
	var circles_to_choose_from := []
	var chosen_circle : GameSpace
	for circle in my_circles: 
		if circle.here().size() > 0: 
			circles_to_choose_from.append(circle)
	if circles_to_choose_from.size() < 1: 
		return false
	elif circles_to_choose_from.size() == 1:
		chosen_circle = circles_to_choose_from[0]
	else:
		chosen_circle = circles_to_choose_from.pick_random()
	start_play.emit(chosen_circle, my_store)
	return true
	
'''
_on_ai_played
- Signal confirmation that the last play made by the AI has been completed
'''
func _on_ai_played():
	playing = false
	commence_turn()
