extends WindowDialog

#the folowing is for the credits window
#	I ask that you please do not modify the credit window contents or scripting
#as it exists to give the owed credit to those helping with the project, all 
#other parts of the project may be modified at will (although I do ask that you
#keep custom content to API calls).

onready var rt_credits = $rt_credits

func _ready():
	pass

func add_credit(credit_name, credit_content):
	rt_credits.text = rt_credits.text + "\n\n" + credit_name + ":\n-" + credit_content

func _on_b_close_pressed():
	self.hide()
	pass # Replace with function body.
