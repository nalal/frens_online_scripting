# Frens Online Scripting

This repo contains all project data for **Frens Online** (working title).

## Building

To build the project, simply import the respective project into GODOT and export
 for your chosen platform, keep in mind that currently we are only supporting 
**windows** and **linux** directly though you are welcome to attempt building 
for other platforms.

## Modding

Any custom content created on top of the project should be exported as a `.pck`. 
When compiling your mod, please make certain you are using the correct version 
of GODOT, currently the project is being built with GODOT `v3.2.1` though we try 
our best to stay up to date with engine updates.

In order to build a mod, one should use signals and API calls to hook their 
content into the game, any custom scripting/assets should be stored in a new 
folder under the `custom` DIR in the project and when exporting it should be 
exported as a patch built on top of the latest release version of the project.
