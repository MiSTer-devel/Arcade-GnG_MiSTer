---------------------------------------------------------------------------------
-- 
-- Arcade: Ghosts'n Goblins for MiSTer ported by Sorgelig
-- 20 January 2019
-- 
---------------------------------------------------------------------------------
-- JT_GNG FPGA Clone of Ghosts'n Goblins by Jose Tejada (@topapate)
---------------------------------------------------------------------------------
-- 
-- 
-- Keyboard inputs :
--
--   F1         : Start 1 player
--   F2         : Start 2 players
--   F3         : Add Coin
--   SPACE      : Jump
--   CTRL,ALT   : Fire
--   UP,DOWN,LEFT,RIGHT : Movements
--   
-- Joystick inputs:
--   Joypad Button 1    : Jump
--   Joypad Button 2,3  : Fire
--   UP,DOWN,LEFT,RIGHT : Movements
--
-- Note: in continue screen use combo Fire + 1P/2P to continue
--
---------------------------------------------------------------------------------

                                *** Attention ***

ROMs are not included. In order to use this arcade, you need to provide the
correct ROMs.

To simplify the process .mra files are provided in the releases folder, that
specifies the required ROMs with checksums. The ROMs .zip filename refers to the
corresponding file of the M.A.M.E. project.

Please refer to https://github.com/MiSTer-devel/Main_MiSTer/wiki/Arcade-Roms for
information on how to setup and use the environment.

Quickreference for folders and file placement:

/_Arcade/<game name>.mra
/_Arcade/cores/<game rbf>.rbf
/_Arcade/mame/<mame rom>.zip
/_Arcade/hbmame/<hbmame rom>.zip



***** ORIGINAl README (many things are irrelevant for MiSTer port): *****


JT_GNG FPGA Clone of Ghosts'n Goblins by Jose Tejada (@topapate)
================================================================

You can show your appreciation through
    * Patreon: https://patreon.com/topapate
    * Paypal: https://paypal.me/topapate

Yes, you always wanted to have a Ghosts'n Goblins arcade board at home. First you couldn't get it because your parents somehow did not understand you. Then you grow up and your wife doesn't understand you either. Don't worry, MiST is here to the rescue.

What you get with this is an extremely accurate (allegedly 100% accurate) clone of the original hardware. You will notice differences from MAME if you compare. Try resetting it and compare those screens for a start! Original hardware handled sound and graphics in a different way from the emulator. There were delays in CPU bus access and other details that will make the experience different from an emulator. Of course, no pause. Just like the real thing!

I hope you will have as much fun with it as I had it while making it!

Project Structure
=================

This work has two separate parts:

1. A verilog model of the original hardware, replicated from original schematics. This is found in the hdl folder. Some test benches are available in the "ver" (for verification) folder. Data sheets of parts used in the original design are located in the "doc" folder. This is interesting to understand how it worked. It can be used to repair broken boards too.

2. A modern clone written in Verilog. It has been made with the MiST board in mind but the game itself (jtgng_game module) is highly portable. All components used aim to be cycle exact -some even sub-cycle exact- so the recreation is the most similar thing to having the original PCB you can get.

Modules
=======

The FPGA clone uses the following modules:

JT12: For YM2203 sound synthesis. From the same author.
MC6809 from Greg Miller
T80: originally from Daniel Wallner, with edits from Alexey Melnikov (Mister)
hybrid_pwm_sd.v copied from FPGAgen source code. Unknown author

Directory Structure
===================
hdl/        replica of original PCB schematics
ver/        simulation files for original PCB
modules     external files used
doc         documents related to original PCB
rom         script to convert from MAME rom files to the required format
            simulation files expect the rom files here
mist/       MiST board version of Ghosts'n Goblins.
            Latest core version is located in this folder and called core.rbf
mist/hdl    Verilog files of the clone for MiST
mist/doc    documents related to MiST clone or MiST hardware
mist/quartus project to synthesize the clone
mist/ver    simulation files of MiST clone

Clone Structure
===============

The top level module is called jtgng_mist. This is the module that is really dependent on the board. If you want to port jtgng to a different FPGA board you will need to modify this file. Most other files will likely stay the same

The game itself in module jtgng_game. It is written using an arbitrary clock (active on positive edge) and a clock enable signal (switching on the negative edge). From jtgng_game down the hierarchy, everything should be highly portable.

The video output is a 256x256 screen. That is what you get from jtgng_game in a signal format that replicates the original hardware. jtgng_mist instantiates a module called jtgng_vga that converts the image to a standard VGA resolution without losing frame speed.

ROM Generation
==============

Copy your .zip files to the rom folder and use Python to execute the file jtgng.py from a command line. Then copy the .rom file to the SD card with the name JTGNG.rom

SD Card
=======

For MiST copy the file core.rbf to the SD card at the root directory. Copy also the rom you have generated with the name JTGNG.rom. It will get loaded at start.

Extras
======

You can press F12 to bring the OSD menu up. You can turn off music, or sound effects with it. By default, a screen filter makes the screen look closer to an old tube monitor. If you turn it off you will get sharp pixels. Note that if you switch from sharp to soft pixels you will need a couple of seconds to get your eyes used as the brain initially perceives this as an out of focus image compared to the old one.

Sound
=======
Original filter for sound:
    -high pass filter with cut-off freq. at 1.6Hz
    -low pass filter with cut-off freq. at 32.3kHz

Credits
=======

Jose Tejada Gomez. Twitter @topapate
Project is hosted in http://www.github.com/jotego/jt_gng
License: GPL3, you are obligued to publish your code if you use mine

Special thanks to Greg Miller and Alexey Melnikov

