extends Node

onready var httpr_request = $httpr_request
var http_debug = false

func _ready():
	print("\n[==HTTP HANDLER STARTED==]")
	httpr_request.connect("request_completed", self, "_http_request_completed")

#Download file from link to file_name
#[link] = URL to get file from
#[file_name] = Name to save file as
func download(link, file_name):
	print("Starting download.")
	print("LINK: " + link)
	print("TO: " + file_name)
	httpr_request.set_download_file(file_name)
	var error = httpr_request.request(link)
	if error != OK:
		print("HTTP_HANDLER: download request failed.")
		print("URL: " + link)
		print("FILE_NAME: " + file_name)
		print("ERROR:\n" + str(error))
		return false
	return true

func _http_request_completed(result, response_code, headers, body):
	match http_debug:
		true:
			print(str(result))
			print(str(response_code))
			print(str(headers))
			print(str(body))
