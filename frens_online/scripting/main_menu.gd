extends Control

onready var name_popup = $name_enter_dialog
onready var name_in = $name_enter_dialog/le_name_input
onready var pass_in = $name_enter_dialog/le_pass_input
onready var message_box = $ctb_name_error_message
onready var connection_dialog = $connection_dialog
onready var le_ip = $connection_dialog/le_ip
onready var le_port = $connection_dialog/le_port
onready var wd_credits = $wd_credits
onready var wd_customize = $wd_customize

func _ready():
	wd_customize.show()
	if globals.is_kicked:
		globals.is_kicked = false
		message_box.call_message_box("Disconnected", globals.get_kick_message())

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
				name_popup.hide()
				message_box.call_message_box("ERROR", "Please provide a password.")
			else:
				globals.set_pass(pass_in.text)
				get_tree().change_scene("res://scripting/networking.tscn")
		else:
			name_popup.hide()
			message_box.call_message_box("ERROR", "Name must be less than 25 characters long.")
	else:
		name_popup.hide()
		message_box.call_message_box("ERROR", "Please enter a name.")

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
