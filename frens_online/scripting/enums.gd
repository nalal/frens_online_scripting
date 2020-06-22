extends Node

enum PACKETS {NAME_PACKET, MESSAGE_PACKET, POS_PACKET, REQUEST_TICK_PACKET}
enum ENT_TYPE {PHYS_OBJ}
enum ERR_TYPE {ERR_NOT_FOUND}
enum M_ASSET_FLAGS {COLOR, TOGGLE, SELECTION}
enum MOVE_TYPE {FORWARD, BACKWARD, LEFT, RIGHT}

func _ready():
	print("\n[==GLOBAL ENUMS LOADED==]")
	pass
