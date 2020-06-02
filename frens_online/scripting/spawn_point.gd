extends Spatial

#this is a spawn entity, it is used as a reference to spawn objects at
#link this into your level and change the node name, use that node name to spawn objects

onready var visual_aid = $visual_aid

var spawn_point_id = ""
var auto_gen_id = false

func _ready():
	#hide visual aid when the game is running
	visual_aid.hide()
	if auto_gen_id:
		pass
	pass

#sets programatic ID for spawn node
#[id] = spawn node id (string)
func set_id(id):
	spawn_point_id = id

#get spawn node position
func get_pos():
	return get_global_transform()
