extends Spatial

var obj_id
var is_synced = false
var can_be_grabbed = true
onready var placeholder_model = $rb_phys_obj/model
onready var placeholder_collision = $rb_phys_obj/cs_phys_obj
onready var phys_obj_node = $rb_phys_obj
var set_collider
var asset_path
var ent_type = enums.ENT_TYPE.PHYS_OBJ

#on object load, do this
func _ready():
	set_collider = placeholder_collision

#set if object can be picked up
#[grab_bool] = if object can be picked up (bool)
func set_grab(grab_bool):
	match grab_bool:
		false:
			can_be_grabbed = false
		true:
			can_be_grabbed = true

#return if the object can be picked up
func can_grab():
	return can_be_grabbed

#get type of object
func get_ent_type():
	return ent_type

#self terminate object
func unload_obj():
	get_parent().remove_child(self)

#set if obj is synced
#[bool_in] = is object synced (bool)
func set_is_synced(bool_in):
	is_synced = bool_in
	match bool_in:
		true:
			randomize()
			set_node_id(randi())

#manually set the position of the object
#[pos] = where to place/scale the object (translation)
func set_pos(pos):
	set_global_transform(pos)

#set the ID of the object
#[id] = ID to set (string)
func set_id(id):
	obj_id = id
	self.set_name(id)

#apply force to object
#[vel] = linear velocity to apply to object (Vector3)
func throw(vel):
	phys_obj_node.apply_impulse(Vector3(0,0,0),vel)

#get object ID
func get_obj_id():
	return obj_id

#check if object is synced
func get_is_synced():
	return is_synced

#get phys obj global position
func get_pos():
	return phys_obj_node.get_global_transform()

#get path of entity asset
func get_asset_path():
	return asset_path

#set path to entity asset
#[path] = path to asset (string)
func set_asset_path(path):
	asset_path = path

#get current lin velocity
func get_obj_velocity():
	return phys_obj_node.get_linear_velocity()

#send phys obj position to server
func send_data():
	if is_synced:
		var network = globals.get_networking_node()
		network.send_data()

#turn off collision for obj
func disable_collision():
	set_collider.set_disabled(true)
	phys_obj_node.set_mode(1)

#load collision data for entity from path
#[collision_path] = path to collision data entity
func load_collision(collision_path):
	placeholder_collision.disabled(true)
	phys_obj_node.add_child(get_node(collision_path))

#load model for entity from path
#[model_path] = path to model entity (string)
func load_model(model_path):
	placeholder_model.hide()
	add_child(model_path)

#set ID of obj in name
#[id] = ID to add to name (int)
func set_node_id(id):
	self.set_name("phys_obj_id_" + str(id))
