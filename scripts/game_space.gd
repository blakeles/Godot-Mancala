extends Node2D
class_name GameSpace

@export var spawn_area : Vector2i = Vector2i(32,16) # The area in which stones can be placed in

enum SPACE_TYPES {STORE, CIRCLE}

var stones : Array = [] # Stones that are in the store
var type : SPACE_TYPES # The type of this current space

'''
here
- Returns the stones that are here
'''
func here():
	return stones
	
'''
point_in_bounds
- Checks whether the given point is within the area of the sprite

random_point
- Gives a random point in the spawn area
'''
func point_in_bounds(point : Vector2):
	if $'Sprite2D'.get_rect().has_point(to_local(point)): return true
func random_point():
	return to_global(Vector2i(randi_range(-spawn_area.x,spawn_area.x),randi_range(-spawn_area.y,spawn_area.y)))
	
'''
set_label
- Change the text of the label to the given number
'''
func set_label(num : int):
	$'Label'.text = str(num)
	
'''
remove_stone
- Remove stone from array and tell it to move to its new owner
'''
func remove_stone(stone_to_remove : Node, new_owner : GameSpace):
	if stone_to_remove in stones:
		stones.remove_at(stones.find(stone_to_remove))
		stone_to_remove.start_move(new_owner.random_point())
		set_label(stones.size())
	
'''
on_transfer_stone
- Adds stone to this space
'''
func _on_transfer_stone(stone_to_add : Node, target_space : GameSpace):
	if target_space == self && stone_to_add.get_parent() != self: # Don't need to move stone if it already belongs here
		stone_to_add.get_parent().remove_stone(stone_to_add, self)
		stones.append(stone_to_add)
		stone_to_add.reparent(self)
		set_label(stones.size())
	
'''
get_type
- Returns what type of space this is
'''
func get_type():
	return type
