# Commander X16 VERA split screen
A demo using Interrupts from the VERA chip at particular scanlines, to make a 'split-screen' effect.

The screen splits at two locations (3 sections). The second section is animated using the Horizontal scale register.

## Requirements
You need to install [Python 3](https://www.python.org/downloads/) (any version will do) to generate the sine table for the animation

## Building
Use the `make` command in the project directory to build the whole project. An output file `vera.prg` will be placed in the `build` directory.

## Running
Run `make run` command to launch the ROM in the x16 emulator.
Once you are in the program, you can press 'q' (and Enter) to quit the program back to the BASIC prompt.