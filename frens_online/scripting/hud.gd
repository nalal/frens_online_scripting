extends Control

#scripting for hud

onready var h_player_name = ""
onready var h_p_name = $h_p_name_label
onready var h_version = $h_version_info
onready var h_fps = $h_fps

func _ready():
	pass

#set string for player name
#[player_name] = name of player to set box as (string)
func set_player_hud_name(player_name):
	print("Setting player name on hud to '" + player_name + "'")
	h_p_name.text = player_name.capitalize()

func _physics_process(delta):
	h_fps.text = str(Engine.get_frames_per_second()) + " :FPS"

#set version no. on hud
#[version_no] = version number (string)
func set_version_text(version_no):
	h_version.text = version_no
