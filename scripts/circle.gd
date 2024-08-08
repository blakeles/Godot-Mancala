extends GameSpace

@onready var stone_scene = preload("res://scenes/stone.tscn")

@export var highlighted : Color = Color(1,1,1) # What colour the circle is when it's its turn
@export var default : Color # The default colour of the circle

var active : bool = false # If circle can be played
var paused : bool = false # If game is paused
var last_modulate : Color # Used to visualise switch between highlighted and non-highlighted state

signal circle_clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	type = SPACE_TYPES.CIRCLE
	owner.transfer_stone.connect(_on_transfer_stone)
	owner.game_start.connect(_on_game_start)
	owner.switch_turn.connect(_on_turn_switch)
	owner.play_pause.connect(_on_pause)
	owner.play_unpause.connect(_on_unpause)

func _input(event):
	if active && !paused:
		if event.is_action_pressed("click"):
			if $'Sprite2D'.get_rect().has_point(to_local(event.position)):
				circle_clicked.emit(self)
				
'''
_on_game_start
- Add initial stones to circle
'''
func _on_game_start(stone_amount : int):
	for i in stone_amount:
		var stone = stone_scene.instantiate()
		add_child(stone)
		stone.global_position = random_point()
		stones.append(stone)
	set_label(stones.size())
	
'''
_on_turn_switch
- Switch active state of the circle
'''
func _on_turn_switch(target : GameSpace):
	if target == self:
		active = !active
		if active && !paused: $'Sprite2D'.self_modulate = highlighted
	
func _on_pause():
	paused = true
	$'Sprite2D'.self_modulate = default
func _on_unpause():
	paused = false
	if active: $'Sprite2D'.self_modulate = highlighted
