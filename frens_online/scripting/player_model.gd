extends Spatial

var model_dir
var model_name
var model_assets = []

var asset_flag = {
	"name":"",
	"active":false
}

class model_asset:
	var asset_id
	var asset_flags = []

func _ready():
	pass

func add_asset(asset):
	var asset_to_add = model_asset.new()
	asset_to_add = asset
	model_assets.push_back(asset_to_add)

func get_assets():
	return model_assets
