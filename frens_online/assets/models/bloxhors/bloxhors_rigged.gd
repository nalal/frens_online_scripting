extends "res://scripting/player_model.gd"



onready var anim_player = $AnimationPlayer
onready var grab_point = $m_head/mouth_node

export var vari = 0

var body_parts = {
	"Tail":["tail"],
	"Body":["Armature/Skeleton/body", "wings", "horn"],
	"Mane":["mane"],
	"Wings":["wings"],
	"Horn":["horn"],
	"Eyes":["eyes_forfront"]
}

var anims = {
	"boop":"Action"
}

var tog_nodes = []

func _ready():
	var asset_to_add = model_asset.new()
	asset_to_add.asset_id = "Body"
	asset_to_add.asset_flags.push_back(enums.M_ASSET_FLAGS.COLOR)
	add_asset(asset_to_add)
	var mane_to_add = model_asset.new()
	mane_to_add.asset_id = "Mane"
	mane_to_add.asset_flags.push_back(enums.M_ASSET_FLAGS.COLOR)
	add_asset(mane_to_add)
	var wings_to_add = model_asset.new()
	wings_to_add.asset_id = "Wings"
	wings_to_add.asset_flags.push_back(enums.M_ASSET_FLAGS.TOGGLE)
	add_asset(wings_to_add)
	var tail_to_add = model_asset.new()
	tail_to_add.asset_id = "Tail"
	tail_to_add.asset_flags.push_back(enums.M_ASSET_FLAGS.COLOR)
	add_asset(tail_to_add)
	var horn_to_add = model_asset.new()
	horn_to_add.asset_id = "Horn"
	horn_to_add.asset_flags.push_back(enums.M_ASSET_FLAGS.TOGGLE)
	add_asset(horn_to_add)
	var eyes_to_add = model_asset.new()
	eyes_to_add.asset_id = "Eyes"
	eyes_to_add.asset_flags.push_back(enums.M_ASSET_FLAGS.COLOR)
	add_asset(eyes_to_add)
	var s_scale = get_scale()
	s_scale = s_scale + globals.get_p_scale()
	s_scale.y = s_scale.y / 2
	s_scale = s_scale * 2
	set_scale(s_scale)
	var translate = get_translation()
	translate.y = translate.y + -0.9
	set_translation(translate)

func get_parts():
	return body_parts

func get_part(part):
	return get_node(body_parts[part])

func play_animation(anim):
	anim_player.play(anims["boop"])


func set_part_color(part, color):
	for bp in body_parts[part]:
		var change_part = get_node(bp)
		var mesh = SpatialMaterial.new()
		#change_part.get_mesh().surface_get_material(0)
		#print(change_part.get_mesh().surface_get_material(0))
		mesh.set_albedo(color)
		change_part.material_override = mesh
		#change_part.get_mesh().surface_set_material(0, mesh)

func set_part_visibility(part, vis):
	for bp in body_parts[part]:
		var change_part = get_node(bp)
		change_part.set_visible(vis)
	return

func get_part_visibility(part):
	var is_visible = get_node((body_parts[part])[0]).is_visible()
	return is_visible

func get_part_color(part):
	var color
	for bp in body_parts[part]:
		var change_part = get_node(bp)
		var mesh = change_part.get_material_override()
		vari = mesh
		if mesh == null:
			mesh = change_part.get_mesh().surface_get_material(0)

		color = mesh.get_albedo()
	return color

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
