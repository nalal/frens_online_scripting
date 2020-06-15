extends KinematicBody

onready var p_f_cam = $fp_cam
onready var p_cam_hitbox = $cam_phys/cam_collision_area
onready var p_cam_buffer = $cam_phys/cam_collision_buffer
onready var p_cam_ray_f = $cam_phys/cam_ray_f
onready var p_cam_reset = get_node("../reset_pos")
onready var p_cam_ray_f_local = $cam_phys/cam_ray_f_local
onready var p_close_cam_area = get_node("../p_close_cam_area")
var cam_rest_post = Vector3()

onready var debug_print = false
onready var debug_colide_b_s = false
onready var debug_colide_b_l = false
onready var debug_colide_f = false

func _ready():
	p_cam_ray_f.set_exclude_parent_body(true)
	p_cam_ray_f.add_exception(p_cam_hitbox)
	p_cam_ray_f.add_exception(p_cam_buffer)

#on physics tic process cam move 
func _physics_process(delta):
	var cam_base = get_global_transform().basis
	var direction = Vector3()
	#if camera must move, do it
	if cam_must_move() && !p_cam_hitbox.overlaps_area(p_close_cam_area):
		print("Cam Must Move")
		direction += cam_base.z
	#if camera must reset, do it
	elif cam_must_reset():
		print("Cam Must Reset")
		direction -= cam_base.z
	#actually move camera
	move_and_slide(direction * 35)

#check if cam must move
func cam_must_move():
	return check_front_buffer() || (p_cam_hitbox.get_overlapping_areas().size() > 2  || p_cam_hitbox.get_overlapping_bodies().size() > 0)

#check if camera needs to return to original pos
func cam_must_reset():
	return cam_check_buffer() && !p_cam_hitbox.overlaps_area(p_cam_reset) && p_cam_hitbox.get_overlapping_areas().size() <= 2 && p_cam_hitbox.get_overlapping_bodies().empty() || p_cam_hitbox.get_overlapping_bodies().empty() && p_cam_hitbox.get_overlapping_areas().size() <= 3 && p_cam_hitbox.overlaps_area(p_close_cam_area)

func cam_check_buffer():
	return ((p_cam_buffer.get_overlapping_areas().size() <= 1 &&  p_cam_buffer.get_overlapping_bodies().size() == 0) || (p_cam_buffer.get_overlapping_areas().size() <= 2 && p_cam_buffer.get_overlapping_bodies().size() == 0 && p_cam_buffer.overlaps_area(p_cam_reset)))

func check_front_buffer():
	return p_cam_ray_f.is_colliding()
