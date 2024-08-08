extends GameSpace

func _ready():
	type = SPACE_TYPES.STORE
	owner.transfer_stone.connect(_on_transfer_stone)
	
func remove_stone(stone_to_remove : Node, new_owner : GameSpace):
	return false # Store should not be able to remove stone
