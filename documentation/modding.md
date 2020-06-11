# MODDING GUIDE

## Creating a mod

To create a new mod, navigate to the `mods` folder in the project and 
create a new folder inside of it. Inside this folder is where you will 
put the data for your mod.

![alt text](https://github.com/nalal/frens-online-scripting/raw/indev/documentation/proj_folder.png)

Inside the folder, create a new scene and attach a new script to that 
scene.

![alt text](https://github.com/nalal/frens-online-scripting/raw/indev/documentation/proj_mod.png)

In this example, `test_mod.tscn` will be the object loaded when the mod 
is loaded, which in turn will load `test_mod.gd` and anything under the 
`func ready():` section of that script will be executed. You can use 
this to hook functions from your mod into the signal system load 
models from your mod to the model list or add levels to the level list.

## Exporting your mod

When you want to export your mod, simply go to export and then enter the 
resources tab, under `Export Mode:` select `Export selected resources (and dependancies)` 
then go through the available files and select any files in your mod 
folder.

![alt text](https://github.com/nalal/frens-online-scripting/raw/indev/documentation/files_export.png)

Once you have selected the relevant files, click `Export PCK/Zip` and 
save the file as `your_mod_name.pck` and replace `your_mod_name` with 
the actual name of your mod, avoid using space, it looks awful on a 
filesystem.

![alt text](https://github.com/nalal/frens-online-scripting/raw/indev/documentation/save_mod.png)

After that's done, there's just one last thing to add, and that's the 
mod info config. In the folder you saved your mod to, create a new file 
with the same name as your mod, but instead of the file extension `.pck` 
use `.ini`. The contents of the file should look something like

```
[datapath]
path="test_mod/test_mod.tscn"
name="testmod"
version="v0.0.1"
```

The variable `path` should be where in the mods folder your main scene 
is.

The variable `name` is the name of your mod.

The variable `version` is the version of your mod.

## Installing a mod

To install a mod that you have created, go into the `custom_content` 
folder for Frens Online, in there add a folder for the mod then put both 
the `.pck` and `.ini` for the mod in that folder. When the game starts 
it will automatically load the mod.
