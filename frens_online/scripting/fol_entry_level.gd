extends Spatial

const level_name = "Entry Area"
onready var spawn_node = Spatial.new()


func _ready():
	set_spawn_node("Spawn")
	signals.load_complete()
	#level.spawn_ent(enums.ENT_TYPE.PHYS_OBJ, "res://assets/phys_obj.tscn", null, "spawn_phys_0")

#get level name string
func get_level_name():
	return level_name

#sets given node as spawn node
#[set_node] = node path in level tree
func set_spawn_node(set_node):
	spawn_node = get_node(set_node)

#gets spawn node position
func get_spawn_node_pos():
	return spawn_node.get_global_transform()
