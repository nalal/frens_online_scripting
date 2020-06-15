extends KinematicBody

#player script
#code here handles local player entity

#player variables
#is cam lock enabled
var p_cam_lock = false
#player name
var p_name = "Player"
#player velocity
var p_velocity = Vector3()
#mouse sensitivity
var mouse_sense = 0.3
#camera variables
var cam_x = 0
var cam_obj_x = 0
#player move speed
var speed = 30
#player acceleration rate
var acceleration = 5
#player gravity
var gravity = 1
#speed of player jump/fly up
var p_jump_speed = 100
#is player flying
var p_flying = false
#is player currently using manual rotation input
var p_move_manual = false
#is player currently using manual cam rotation
var p_cam_manual = false
#game version
var g_version = globals.get_release_build() + globals.get_game_version()
#object click distance
var ray_dist = 100
#how hard a player can throw
var throw_power = 100

var obj_is_held = false

var can_attach = true

var force_fp = false

#chat lock
onready var is_player_chatting = false
onready var show_fps = true
#player entity variables
#todo: clean pointless vars and label with comments
export onready var player_model #= $player_collide/player_model
onready var p_cam = $player_collide/cam_rotate/head
onready var p_jump_area = $player_collide/p_jump_area
onready var p_collide = $player_collide
onready var p_cam_obj = $player_collide/cam_rotate
onready var p_cam_obj_reset = $player_collide/cam_rotate/cam_reset
onready var p_name_render = $name_box/Control/player_name
onready var p_name_box = $player_collide/name_box
onready var h_p_info = $hud
onready var p_ray_f = $player_collide/cam_rotate/head/cam_zoom/cam_move/cam_phys/cam_ray_f
onready var h_chat_message = $hud/pa_chat/le_chat
onready var h_chat_box = $hud/pa_chat/rtl_chat
onready var game = globals.get_networking_node()
onready var pause_menu = $pause_menu
onready var p_cam_lens = $player_collide/cam_rotate/head/cam_zoom/cam_move/cam_phys/tp_cam
onready var p_cam_r = $player_collide/cam_rotate/head/cam_zoom/cam_move/cam_phys/tp_cam/r_cam
onready var throw_point = $player_collide/throw_point
onready var p_close_cam_area = $player_collide/cam_rotate/head/cam_zoom/p_close_cam_area
onready var fp_cam = $player_collide/cam_rotate/head/cam_zoom/cam_move/fp_cam
export onready var default_model = load("res://assets/models/hors.tscn")
var render_dist


#player init
func _ready():
	set_global_transform(get_node("/root/game/level_buffer/Level").get_spawn_node_pos())
	p_name = globals.get_name()
	#catch for oversized player name, will be useful later
	if p_name.length() > 30:
		print("Player name '" + p_name + "' is greater than max name size")
	print("Player '" + p_name + "' loaded.")
	#set name above player to player's name
	p_collide.add_child(default_model.instance())
	p_name_render.set_player_name(p_name)
	#set player name in UI
	h_p_info.set_player_hud_name(p_name)
	h_p_info.set_version_text(g_version)
	p_ray_f.add_exception(p_name_box)
	p_ray_f.add_exception(p_close_cam_area)
	p_cam_lens.set_zfar(globals.get_render_distance())
	fp_cam.set_zfar(globals.get_render_distance())
	player_model = p_collide.get_node("hors")
	var move = player_model.get_translation()
	move.y = move.y + -1.0
	player_model.set_translation(move)
	
	set_scale(globals.get_p_scale())
	set_fog_vals(p_cam_lens.get_environment())
	set_fog_vals(fp_cam.get_environment())

func set_player_color(part, color):
	player_model.set_part_color(part, color)

func set_player_visibility(part, vis):
	player_model.set_part_visibility(part, vis)

func set_fog_vals(env):
	env.set_fog_enabled(true)
	env.set_fog_color("#a6a8aa")
	env.set_fog_depth_begin(globals.get_render_distance() - 50)
	env.set_fog_depth_end(globals.get_render_distance())
	env.set_background(3)
	env.set_bg_color("#a6a8aa")

var selected_obj

func is_mouse_overlapping_obj(pos):
	selected_obj = null
	var targ_o = p_cam_lens.project_ray_origin(pos)
	var targ_n = p_cam_lens.project_ray_normal(pos)
	var proj_from = targ_o
	var proj_to = targ_o + targ_n * ray_dist
	var space_state = get_world().get_direct_space_state()
	selected_obj = space_state.intersect_ray(proj_from, proj_to, [self], 4)
	if selected_obj.size() <= 0:
		return false
	else:
		return true

#input catching
func _input(event):
	if Input.is_action_just_pressed("move_cam_press") && is_mouse_overlapping_obj(event.position):
		if selected_obj.collider.get_parent().get_ent_type() == enums.ENT_TYPE.PHYS_OBJ:
			attach_obj(selected_obj.collider)
		print("Object '" + str(selected_obj.collider) + "' clicked.")
	else:
		if Input.is_action_pressed("move_cam_press") || Input.is_action_pressed("move_free_cam_press"):
			if Input.is_action_pressed("move_cam_press") && !p_cam_manual:
				p_move_manual = true
			elif Input.is_action_pressed("move_free_cam_press") && !p_move_manual:
				p_cam_manual = true
		else:
			if !p_cam_lock:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			p_cam_manual = false
			p_move_manual = false
	if !is_player_chatting:
		#rotate character and camera
		if event is InputEventMouseMotion && (p_move_manual || p_cam_lock):
			#globals.get_mouse_cap().cap_mouse()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			p_collide.rotate_y(deg2rad(-event.relative.x * mouse_sense))
			var cam_x_delta = event.relative.y * mouse_sense
			if cam_x_delta + cam_x > -50 && cam_x_delta + cam_x < 50:
				p_cam.rotate_x(deg2rad(cam_x_delta))
				cam_x += cam_x_delta
		#rotate only camera
		elif event is InputEventMouseMotion && p_cam_manual && !p_cam_lock:
			#globals.get_mouse_cap().cap_mouse()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			p_cam_obj.rotate_y(deg2rad(-event.relative.x * mouse_sense))
			var cam_x_delta = event.relative.y * mouse_sense
			if cam_x_delta + cam_x > -30 && cam_x_delta + cam_x < 50:
				p_cam.rotate_x(deg2rad(cam_x_delta))
				cam_x += cam_x_delta
		#reset camera position
		if Input.is_action_pressed("move_reset_cam") && !Input.is_action_pressed("move_free_cam_press"):
			p_cam_obj.set_rotation(p_cam_obj_reset.get_rotation())
		#lock camera
		if Input.is_action_just_pressed("move_camera_lock"):
			p_cam_lock = !p_cam_lock
		if Input.is_action_just_pressed("action_boop"):
			print("BOOP!")
			play_animation("boop")
			game.send_anim_to_server("boop")
		if Input.is_action_just_pressed("menu_ingame_open"):
			pause_menu.load_menu()
		if Input.is_action_just_pressed("action_throw"):
			match obj_is_held:
				false:
					print("No object is held")
				true:
					throw_obj()
					obj_is_held = false
	if Input.is_action_just_pressed("chat_enter"):
		if !is_player_chatting:
			h_chat_message.set_editable(true)
			h_chat_message.grab_focus()
			is_player_chatting = true
		elif is_player_chatting:
			h_chat_message.set_editable(false)
			is_player_chatting = false
			var message = h_chat_message.text
			h_chat_message.text = ""
			send_message(message)

#attach object to player
func attach_obj(obj):
	match can_attach:
		true:
			var to_pos = player_model.get_grab_point_pos()
			player_model.attach_obj(obj.get_parent().get_asset_path(), obj.get_parent().get_obj_id())
			game.send_obj_pickup(obj.get_parent().get_obj_id())
			obj.get_parent().unload_obj()
			obj_is_held = true
		false:
			print("Not attaching object" + str(obj) + " because the code for it is borked.")
			pass

#when object is thrown, do this
#[obj] = object to throw (node)
func throw_obj():
	var throw_from = throw_point.get_global_transform()
	var to_throw = player_model.get_attached_obj()
	level.spawn_ent(enums.ENT_TYPE.PHYS_OBJ, to_throw.get_asset_path(), throw_from, null, null, to_throw.get_obj_id())
	var loaded_obj = get_node("/root/game/level_buffer/Level/" + to_throw.get_obj_id())
	#loaded_obj.set_global_rotation(p_collide.get_global_rotation())
	var direction = Vector3()
	var head_base = p_collide.get_global_transform().basis
	direction += head_base.z
	direction = direction.normalized()
	var throw_val = Vector3()
	throw_val = throw_val.linear_interpolate(direction * throw_power, 1.0)
	throw_val.y += throw_power / 10
	loaded_obj.throw(throw_val)
	game.send_throw_obj(throw_val)
	player_model.detach_obj()

#load message from network handler
#[message] = message from server to print to textbox
func load_message(message):
	h_chat_box.text = h_chat_box.text + "\n" + message

#send message to network handler
#[message] = message to send to server
func send_message(message):
	print("Sending '" + message + "' to server.")
	game.send_message(message)

#per physics frame check
func _physics_process(delta):
	if p_close_cam_area.get_overlapping_areas().size() > 1:
		force_fp = true
	else:
		force_fp = false
	if force_fp && !fp_cam.is_current():
		fp_cam.make_current()
	elif !force_fp && fp_cam.is_current():
		p_cam_lens.make_current()
	var head_base = p_collide.get_global_transform().basis
	var direction = Vector3()
	if !is_player_chatting:
		#strafe movement, check to see if player is already strafing
		if !Input.is_action_pressed("move_left") || !Input.is_action_pressed("move_right"):
			if Input.is_action_pressed("move_left"):
				direction += head_base.x
			elif Input.is_action_pressed("move_right"):
				direction -= head_base.x
		#forward/backward movement, check to see if player is already moving
		if !Input.is_action_pressed("move_back") || !Input.is_action_pressed("move_forward"):
			if Input.is_action_pressed("move_back"):
				direction -= head_base.z
			elif Input.is_action_pressed("move_forward"):
				direction += head_base.z
		#toggle flying
		if Input.is_action_just_pressed("move_fly"):
			p_flying = !p_flying
		direction = direction.normalized()
		p_velocity = p_velocity.linear_interpolate(direction * speed, acceleration * delta)
		#catch rotation input, done here to make cam movement more smooth

		#jump command, checks for flying, if flying does not apply gravity
		if !p_flying:
			if Input.is_action_just_pressed("move_jump") && p_jump_area.get_overlapping_bodies().size() > 0:
				p_velocity.y = p_jump_speed
			else:
				p_velocity.y -= gravity
		else:
			if Input.is_action_pressed("move_crouch"):
				p_velocity.y = -p_jump_speed
			elif Input.is_action_pressed("move_jump"):
				p_velocity.y = p_jump_speed
		#check if camera lock is engaged, if not, free mouse
		if !p_cam_lock && !p_cam_manual && !p_move_manual:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		p_velocity = move_and_slide(p_velocity)
		game.send_player_move(p_velocity)

#set player name for entity
#[name_in] = player entity name
func player_setname(name_in):
	p_name = name_in

#play animation from model
#[anim] = animation name (string)
func play_animation(anim):
	player_model.play_animation(anim)

func get_player_gpos():
	var send_pos = p_collide.get_global_transform()
	#send_pos.translate = Vector3(0,0,0)
	return send_pos

#get global transform values for player
func get_player_pos():
	return p_velocity
