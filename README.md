# Realistic-Atmosphere-Godot-and-UE4
A realistic atmosphere material for both the Godot game engine and Unreal Engine 4

The Unreal version is succeeded by [This guide](https://github.com/Dimev/shadertoy-to-unreal-engine)
I'll still try and answer issues here, but if you want a more up to date version, then follow the guide.

For Godot, it should be possible to simply copy-paste most of the function from shadertoy into the shader, and adding any missing parameters.

![planet_1](images/planet_1.png)
![planet_3](images/planet_3.png)
(more in the images folder)

Showcase videos for [godot](https://youtu.be/mKg426Q8iwM) and [ue4](https://youtu.be/2If8QCHxWA4)

There's also a [shadertoy version](https://www.shadertoy.com/view/wlBXWK).
The repo for that is [here](https://github.com/Dimev/atmosphere-shader).
Guide for converting shadertoy shaders to unreal is [here](https://github.com/Dimev/shadertoy-to-unreal-engine/edit/main/README.md)

This resporitory provides code for adding realistic admospheres to godot and unreal engine 4.
The size, color and intensity can all be tuned.

For unreal engine 4, a project including all needed assets is given (for version 4.22.3), as well as a plugin, by @gbeniola 
For godot, a standalone shader file is given, as well as a demo project

### usage
The UE4 and Godot versions are used a bit differently, so I've created a seperate guide for them, both of which are here:
[Godot](usage/godot.md) and [UE4](usage/ue4.md)

The shadertoy verion of this atmosphere can be found [here](https://www.shadertoy.com/view/wlBXWK), also by me.

The code is based on the [implementation by scratchapixel](https://www.scratchapixel.com/lessons/procedural-generation-virtual-worlds/simulating-sky), with a few modifications to make it work from space, and to make it look nicer

### license
The assets are shared under the MIT license, more detail in the LICENSE file.

If you use this in a game or other software, I'm fine with being credited with "Atmosphere by Dimas Leenman, Shared under the MIT license" somewhere in the credits.
