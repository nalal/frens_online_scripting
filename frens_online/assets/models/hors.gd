extends "res://scripting/player_model.gd"



onready var anim_player = $AnimationPlayer
onready var grab_point = $m_head/mouth_node

var body_parts = {
	"Tail":"m_tail",
	"Body":"m_body",
	"Head":"m_head",
	"Neck":"m_neck"
}

var tog_nodes = []

func _ready():
	var asset_to_add = model_asset.new()
	asset_to_add.asset_id = "Body"
	asset_to_add.asset_flags.push_back(enums.M_ASSET_FLAGS.COLOR)
	add_asset(asset_to_add)

func get_part(part):
	return get_node(body_parts[part])

func play_animation(anim):
	anim_player.play("boop")
	pass

func add_to_toggleable_nodes(model_node):
	tog_nodes.push_back(model_node.node_id)

func get_grab_point_pos():
	return grab_point.get_global_transform()

func attach_obj(obj_path, obj_id):
	var obj = load(obj_path).instance()
	obj.set_asset_path(obj_path)
	obj.set_id(obj_id)
	grab_point.add_child(obj)
	var attached_obj = grab_point.get_child(0)
	attached_obj.disable_collision()
	attached_obj.global_scale(Vector3(1,1,1))

func detach_obj():
	get_attached_obj().get_parent().remove_child(get_attached_obj())

func get_attached_obj():
	return grab_point.get_child(0)

func get_toggleable_nodes():
	var nodes = "nothing here yet"
	return nodes
