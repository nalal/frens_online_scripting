extends Spatial

const level_name = "Terrible Deathmatch Map"
onready var spawn_node = Spatial.new()

onready var is_instanced = false

func _ready():
	set_spawn_node("Spawn")
	signals.load_complete()
	pass

func get_level_name():
	return level_name

#check if level should be instanced for parties
func get_is_level_instanced():
	return is_instanced

func set_spawn_node(set_node):
	spawn_node = get_node(set_node)

func get_spawn_node_pos():
	return spawn_node.get_global_transform()
