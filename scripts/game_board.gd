extends Node2D

@export var stones_per_circle : int # How many circles should strat in each circle
@export var store_1 : GameSpace # Store for player 1
@export var store_2 : GameSpace # Store for player 2

signal game_start
signal game_over
signal switch_turn
signal play_pause
signal play_unpause
signal transfer_stone
signal ai_played

var circles_0 : Array # Every circle
# Circle arrays for each player
var circles_1 : Array
var circles_2 : Array

var ai_playing : bool = false # If the AI is playing

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	start_game()

'''
start_game
- Initialise the circle arrays
- Decide which side starts
- Tell circles to spawn stones
'''
func start_game():
	if get_node_or_null("AI"): # Check whether the AI is in this scene
		ai_playing = true
		$'AI'.start_play.connect(_on_ai_play)
	# Initialise circle arrays
	circles_1 = get_circles_from_group("Player1Circles")
	circles_0.append_array(circles_1)
	circles_2 = get_circles_from_group("Player2Circles")
	circles_0.append_array(circles_2)
	# Decide which side starts and then start
	if randf() < 0.5: switch_turn_for(circles_1)
	else: switch_turn_for(circles_2)
	game_start.emit(stones_per_circle)
		
'''
switch_turn_for
- Switch turn for the given circles
'''
func switch_turn_for(to_switch : Array):
	for space in to_switch:
		switch_turn.emit(space)
			
'''
get_circles_from_group
- Returns the circles from the group given
'''
func get_circles_from_group(group_name : String):
	var group_circles = []
	var group_nodes = get_tree().get_nodes_in_group(group_name)
	for circle in group_nodes:
		if circle.get_type() == GameSpace.SPACE_TYPES.CIRCLE:
			group_circles.append(circle)
			circle.circle_clicked.connect(_on_circle_clicked)
	return group_circles
	
'''
check_circles
- Check if the circles given are all empty
'''
func check_circles(side_circles : Array):
	for circle in side_circles:
		if circle.here(): return false
	return true
	
'''
handle_game_over
- Moves stones from the non empty side to that side's store
'''
func handle_game_over(non_empty_side : Array):
	var stones_to_move: Array = []
	var store : GameSpace
	if non_empty_side == circles_1: store = store_1
	else: store = store_2
	for circle in non_empty_side:
		stones_to_move.append_array(circle.here().duplicate())
	for stone in stones_to_move:
		transfer_stone.emit(stone, store)
	game_over.emit()
	
'''
_on_circle_clicked
- Handle click event
'''
func _on_circle_clicked(circle : GameSpace):
	if ai_playing && circle in circles_2: return
	if circle.here():
		var side_store : GameSpace
		if circle in circles_1: side_store = store_1
		else: side_store = store_2
		play(circle, side_store)

'''
play
- Pause players from playing
- Perform the necessary steps in play
- Unpause
'''
func play(circle : GameSpace, store : GameSpace):
	play_pause.emit()
	var final_stone : Node = await handle_move_stones(circle, store)
	if final_stone: await handle_final_stone_placed(final_stone, store)
	if check_circles(circles_1): handle_game_over(circles_2)
	elif check_circles(circles_2): handle_game_over(circles_1)
	play_unpause.emit()
		
'''
handle_final_stone_placed
- Final stone in store already handled when doing initial move
- This just performs the necessary checks and actions if the final stone lands in a circle
'''
func handle_final_stone_placed(final_stone : Node, store : GameSpace):
	var side_circles : Array
	if store.get_parent().name == "Player 1": side_circles = circles_1
	else: side_circles = circles_2
	var final_space : GameSpace = final_stone.get_parent()
	if final_space.get_type() == GameSpace.SPACE_TYPES.CIRCLE: # If final stone lands in a circle
		switch_turn_for(circles_0)
		if final_space.here().size() == 1 && final_space in side_circles:
			var opposing_stones = get_opposing_circle(final_space).here().duplicate()
			if opposing_stones:
				await get_tree().create_timer(0.2).timeout
				transfer_stone.emit(final_stone, store)
				for stone in opposing_stones:
					transfer_stone.emit(stone, store)

'''
handle_move_stones
- Deposit the stones around the board in the correct spaces
'''
func handle_move_stones(start_circle : GameSpace, store : GameSpace):
	var stones_to_move : Array = start_circle.here().duplicate()
	var index := circles_0.find(start_circle) + 1
	
	# Find distance to store depending on which side start_circle is in
	var distance_to_store : int = circles_1.find(start_circle)
	if distance_to_store >= 0: distance_to_store = 5 - distance_to_store
	else: distance_to_store = 5 - circles_2.find(start_circle)
	
	while stones_to_move.size() > 0:
		var stone = stones_to_move.pop_front()
		var space : GameSpace
		if distance_to_store == 0: # If stone should be put in store
			space = store
			distance_to_store = 12
		else:
			if index == circles_0.size(): index = 0 # Reset index on loop of circles
			space = circles_0[index]
			index += 1
			distance_to_store -= 1
		transfer_stone.emit(stone, space)
		if stones_to_move.size() == 0: return stone # Return the final stone placed
		await get_tree().create_timer(0.2).timeout 
	
'''
get_opposing_circle
- Returns the circle that is on the opposing side of the circle given
'''
func get_opposing_circle(circle : GameSpace):
	for i in range(0,6):
		if circles_1[i] == circle: return circles_2[5-i]
		elif circles_2[i] == circle: return circles_1[5-i]

'''
_on_ai_play
- Performs the play the AI chose
'''
func _on_ai_play(circle : GameSpace, ai_store : GameSpace):
	await play(circle, ai_store)
	ai_played.emit()
