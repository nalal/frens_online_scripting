extends KinematicBody

#puppet script
#code here handles local puppet entities

#puppet variables
#puppet name
var pu_name = "Puppet"
#puppet velocity
var p_velocity = Vector3()
#puppet move speed
var speed = 30
#puppet acceleration rate
var acceleration = 5
#puppet gravity
var gravity = 5

#player entity variables
onready var pu_name_render = get_node("name_box")
onready var pu_collide = $player_collide
export onready var pu_model #= $player_collide/player_model
onready var throw_point = $player_collide/throw_point
export onready var player_model #= $player_collide/player_model
export onready var default_model = load("res://assets/models/hors.tscn")
onready var selected_obj

#puppet init
func _ready():
	#set name above player to player's name
	print("Puppet '" + pu_name + "' loaded.")
	print("Setting Puppet name on name box to '" + pu_name + "'")
	pu_name_render.set_puppet_name(pu_name)
	pu_collide.add_child(default_model.instance())
	pu_model = get_node("player_collide/hors")
	player_model = get_node("player_collide/hors")
	#pu_model.set_scale(Vector3(0.5,0.5,0.5))

#per physics frame check
func _physics_process(delta):
	pass

#set puppet node name from ID, why set_name? becuase I'm lazy and copied the code from set name in player
#[set_name] = name to set node to (string)
func set_puppet_id(set_name):
	get_node(".").set_name(set_name)

#set the name of the pupet
#[name_in] = name to set in puppet entity (string)
func puppet_setname(name_in):
	pu_name = name_in
	pu_name_render.set_puppet_name(pu_name)

#throw object call
#[obj] = object to throw (node)
func throw_obj(throw_val):
	var throw_from = player_model.get_grab_point_pos()
	var to_throw = player_model.get_attached_obj()
	level.spawn_ent(enums.ENT_TYPE.PHYS_OBJ, to_throw.get_asset_path(), throw_from, null, null, to_throw.get_obj_id())
	var loaded_obj = get_node("/root/game/level_buffer/Level/" + to_throw.get_obj_id())
	loaded_obj.throw(throw_val)
	#loaded_obj.set_scale(Vector3(1,1,1))
	player_model.detach_obj()

#grab obj from level
#[obj] = level object to grab (node)
func grab_obj(obj):
	selected_obj = obj
	var grab_obj_ent = level.get_current_level().get_node(obj)
	player_model.attach_obj(grab_obj_ent.get_asset_path(), grab_obj_ent.get_obj_id())
	grab_obj_ent.unload_obj()

#set position for puppet
#[pos] = position to set (transform)
func puppet_setpos(pos):
	var cur_scale = get_scale()
	#set_global_transform(pos)
	pos.y -= gravity
	move_and_slide(pos)
	set_scale(cur_scale)

func puppet_initpos(pos):
	var cur_scale = get_scale()
	if pos != null:
		pu_collide.set_global_transform(pos)
	else:
		pu_collide.set_global_transform(level.get_spawn_node().get_global_transform())
	set_scale(cur_scale)

#get puppet current position
func puppet_getpos():
	return get_global_transform()

#play animation from model
#[anim] = animation name (string)
func play_animation(anim):
	pu_model.play_animation(anim)

#delete puppet from scene
func remove_puppet():
	get_parent().remove_child(self)

func set_puppet_model(model_data):
	for af in model_data["asset_flags"]:
		match af:
			enums.M_ASSET_FLAGS.COLOR:
				pu_model.set_part_color(model_data["asset_id"], model_data["asset_color"])
			enums.M_ASSET_FLAGS.TOGGLE:
				pu_model.set_part_visibility(model_data["asset_id"], model_data["asset_visible"])
