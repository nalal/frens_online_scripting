extends KinematicBody

#this whole thing is a bit of a mess

onready var p_cam_ray_f = $cam_move/cam_phys/cam_ray_f
onready var p_cam_hitbox_z = get_node("../cam_z_area_box")

#cam pos output flag for debugging
var P_CAM_DEBUG_OUTPUT = false

#closest cam can get
var P_CAM_MIN_DISTANCE = 5.5
#furthest cam can get
var P_CAM_MAX_DISTANCE = 25
#speed cam zooms
var P_CAM_MOVE_RATE = 350

func _ready():
	if P_CAM_DEBUG_OUTPUT:
		print(str(p_cam_ray_f.get_global_transform()))
		print(str(p_cam_ray_f.get_global_transform().origin))
		print(str(p_cam_hitbox_z.get_global_transform().origin))
		print(str(p_cam_hitbox_z.get_global_transform()))
		print(str(get_ray_distance()))

#camera zoom input
func _input(event):
	var cam_base = get_global_transform().basis
	if Input.is_action_pressed("move_camera_z_in") && get_ray_distance() > P_CAM_MIN_DISTANCE:
		#move camera forward
		var direction = Vector3()
		direction += cam_base.z
		move_and_slide(direction * P_CAM_MOVE_RATE)
		var raycast_value = p_cam_ray_f.get_cast_to()
		raycast_value.y = -get_ray_distance()
		p_cam_ray_f.set_cast_to(raycast_value)
	elif Input.is_action_pressed("move_camera_z_out") && get_ray_distance() < P_CAM_MAX_DISTANCE:
		#move camera out
		var direction = Vector3()
		direction -= cam_base.z
		move_and_slide(direction * P_CAM_MOVE_RATE)
		var raycast_value = p_cam_ray_f.get_cast_to()
		raycast_value.y = -get_ray_distance()
		p_cam_ray_f.set_cast_to(raycast_value)

func get_ray_distance():
	return p_cam_ray_f.get_global_transform().origin.distance_to(p_cam_hitbox_z.get_global_transform().origin)
	
