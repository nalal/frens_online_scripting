# LEVEL EDITING GUIDE

## Creating a level

To create a level, simply create a new scene and set it as a 3D spatial node 
(the red circle that says 3D on the side fo the GODOT editor) then add another 
3D spatial node under that and name it `Spawn`, this is where players will 
start initially on your map. After that it's just a matter of building your 
level as you see fit.

Once you are ready to play the level, you will need to add it to the level list 
by using the API call `level.add_level()`. It is recommended to include this in 
your mod's `_on_ready` call. In order for the level to be added to the list you 
will need to add the level info into a level object, which can be done as such.

```gdscript
var level_to_add = level.level_data_object.new()
level_to_add.l_name = "Name of your level"
level_to_add.l_path = "path_to_your_level_scene_file"
level.add_level(level_to_add)
```

Once you've added your level it can be set as the start level in the server 
config (you need to use the level name), once connected it will load the level. 
You can look at `game_init.gd` in the project for an example of how to best do 
this.
