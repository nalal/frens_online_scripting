extends Control

onready var name_popup = $name_enter_dialog
onready var name_in = $name_enter_dialog/le_name_input
onready var pass_in = $name_enter_dialog/le_pass_input
onready var message_box = $ctb_name_error_message
onready var connection_dialog = $connection_dialog
onready var le_ip = $connection_dialog/le_ip
onready var le_port = $connection_dialog/le_port
onready var wd_credits = $wd_credits
onready var l_menu_flavor_text = $l_menu_flavor_text
onready var l_error_name = $name_enter_dialog/l_error
const menu_text = [
	"A melting pot of tolerance.",
	"WE'RE ALL GONNA MAKE IT BROS",
	"Twilight sparkle is best pony",
	"7 bit signed ascii is retarded...",
	"*crack* ALRIGHT, so...",
	"Shoutout to Hoodie",
	"/)",
	"THREE MONTHS OF WINTER COOLNESS",
	"Powerd by several horses",
	"GET AMPED",
	"P U T  Y O U R  A S S  I N  T H E  A I R",
	"Louder!",
	"Phew!",
	"Go to bed, seth",
	"IWTCIRD",
	">when mom finds the jar",
	"Put me in the cap",
	"ZOOMED WORDS",
	">no hooves",
	"Fucking glimmershits...",
	"The ride never ends.",
	"Spikefags are pathetic",
	"Take me to the gay bathhouse",
	"2D women are not important",
	"You gotta try some of this bomb ass tea, man",
	"If it's anthro, it gets the b&thro",
	"FUCK camera collision",
	"'With a car, you can go anywhere you want' he said out loud",
	"Wojak is just rageface 2.0 and posting wojak makes you look bad",
	"Griffons did this...",
	"DANCE ON ME BALLS, CAT FUCKING A HANDBAG",
	"You were real good son, maybe even the best",
	"So wait, what actually happened in September?",
	"You may call it fake, but this is real magic",
	"See /app/ for updates",
	"Don't forget, you're here forever!",
	"Hey guys, I left in 2016 but now I'm back, what'd I miss?",
	">season 3 is cannon",
	">implying",
	">tfw shadowbanned on derpibooru",
	"I'll die with the herd",
	"I am the last painted pony",
	"Hello fren",
	"Though stirups may rust, reins turn to dust, dreamers never break down!",
	"You aight, anon, you aight.",
	"Your waifu's shit",
	"What would the cutie mark of somepony who's talent is arguing even look like?",
	"(USER WAS BANNED FOR THIS POST)",
	"The kirin is offering you a drink",
	"This, but with nyx",
	"h e h"
]

func _ready():
	var res = globals.get_res()
	#_set_size(Vector2(res[0],res[1]))
	get_tree().set_screen_stretch(1, 1, Vector2(res[0],res[1]), globals.settingsConfig.get_value("graphics", "ui_scale"))
	if globals.is_kicked:
		globals.is_kicked = false
		message_box.call_message_box("Disconnected", globals.get_kick_message())
	randomize()
	l_menu_flavor_text.text = menu_text[rand_range(0,menu_text.size())]
	menu_text

#When play pressed, ask for name
func _on_Play_pressed():
	le_ip.text = ""
	le_port.text = ""
	connection_dialog.popup()

#When options pressed, open options
func _on_Button_pressed():
	get_tree().change_scene("res://levels/options.tscn")

#When name entered, check if name is empty, if not go to next level, if so popup error message
func _on_b_enter_name_pressed():
	#check if name is empty
	if name_in.text:
		if name_in.text.length() <= 25:
			globals.set_name(name_in.text)
			if pass_in.text.length() <= 0:
				#name_popup.hide()
				l_error_name.text = "Invalid password"
			else:
				globals.set_pass(pass_in.text)
				l_error_name.text = ""
				get_tree().change_scene("res://scripting/networking.tscn")
		else:
			#name_popup.hide()
			l_error_name.text = "Name too long"
	else:
		#name_popup.hide()
		l_error_name.text = "No name"

#Offline mode button, does nothing atm
func _on_b_local_pressed():
	message_box.call_message_box("NOTE", "This doesn't do anything yet.")
	pass # Replace with function body.

#When IP is given, check if IP/PORT sections are empty, if so give default port and local loopback
func _on_b_enter_ip_pressed():
	var ip_good
	var port_good
	if le_ip.text.length() == 0:
		globals.set_server_ip("127.0.0.1")
		ip_good = true
	elif le_ip.text.is_valid_ip_address():
		globals.set_server_ip(le_ip.text)
		ip_good = true
	else:
		message_box.call_message_box("ERROR", "Invalid IP")
	if ip_good:
		if le_port.text.length() == 0:
			globals.set_server_port(25565)
			port_good = true
		elif int(le_port.text) > 0 && int(le_port.text) < 65535:
			globals.set_server_port(int(le_port.text))
			port_good = true
		else:
			message_box.call_message_box("ERROR", "Invalid PORT")
	if ip_good && port_good:
		name_popup.popup()
		connection_dialog.hide()


func _on_b_credits_pressed():
	wd_credits.show()
	pass # Replace with function body.


func _on_b_customize_pressed():
	var customize_menu = load("res://assets/wd_customize.tscn").instance()
	add_child(customize_menu)
	get_node(customize_menu.get_name()).show()
