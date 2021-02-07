
Master Makefile for Arduino projects
====================================

This is a very simple main makefile to use with GNU Make utility for compiling
Your Arduino projects without the Arduino IDE. Using this file does not affect
the way Arduino project is written, so it may be used in parallel with Arduino
IDE.

There are also some more complete (and more complex) make systems for Arduino, such as
[Arduino-Makefile](https://github.com/sudar/Arduino-Makefile). You may find it
better fit to Your needs. Also there are plugins for VS Code IDE to work with
Arduino.

Current makefile is a reworked version of the file that was written by Alan
Burlison at 2011.
You can see it on [his site](http://bleaklow.com/2010/06/04/a_makefile_for_arduino_sketches.html).

You can use current makefile with no limitations.
I would be grateful if You help me to improve this makefile.

Some people have already created modifications of this file. So You can find
them in the Internet by searching words "arduino makefile master", if You
interested.

What is this all needed for
---------------------------

Original Arduino IDE is easy to use for beginners, but after some time people
realize that its functionality is poor. They would prefer to code for Arduino
with another IDEs or advanced textual editors, such as Eclipse IDE, Notepad++,
or Vim. This makefile can help You to more easily set up Your favorite
environment to code for Arduino.

Another case is when Arduino IDE installed with system's package manager is a
littlebit buggy and needs to many efforts to make it work properly. This
makefile is usually very easy to install.

Although in fact, You maybe don't need this makefile under Windows: many Windows
users prefer to use Arduino IDE, and there is VSCode IDE which already has
plugins to work with Arduino.


Note about Operating Systems
----------------------------

Original file was created mainly to work on Solaris OS, and here it is reworked
to work best under Linux. This readme file is also mostly Linux-oriented.

I did not make any efforts to get it work for Windows,
but I beleave this would not be very hard. If You want to use this makefile
under Windows, You will definitely need MinGW and maybe make some changes in
makefile. You can help to add full support for Windows, if You wish.

Basic setup
-----------

### 1. Install Arduino IDE

At first, You will need to install Arduino IDE - its components always needed to
compile arduino projects.

On Linux, You can install it from native repositories for Your system, using
default package manager.
For any system, You can download an archive and unpack it into
some folder for standalone applications. In Linux it's usually /opt folder. See
[more instructions and links at Arduino site](https://playground.arduino.cc/Learning/Linux/)

### 2. Copy the makefile into Your projects folder

Then You have these options:

- If You do not plan to make changes in this makefile and use GIT for committing
  that changes, You can simply create file "Makefile.master" at the root folder
  of Your Arduino projects (sketches) and copy contents of the makefile into it.
- If You don't like ".master" extension, maybe because it confuses Your textual
  editor or IDE, do like in previous case but name this master-makefile in
  another way, maybe just "Makefile" or "Makefile-master".
- If You plan to change this makefile and use GIT to commit changes or want to
  get the file in the easiest way, clone this repository into the root of Your
  Arduino projects (by default, on Linux it is `~/sketches`). For example, go
  into that folder and do

```bash
git clone https://github.com/alexandersolovyov/arduino-makefile.git
```

This will be the main Makefile for all of Your Arduino projects. Each project
will have its own, more simple makefile. This main makefile must be included to
the end of each project-specific makefile.

### 3. Edit the makefile to fit Your environment

Change global configuration variables in the main Makefile (downloaded from this
github repo) accordingly to where You installed Arduino IDE, what version it
has, what programmer hardware You are using. Here are these variables:

- **ARD_REV** - arduino software revision (or version), e.g. 0017, 0018. When
  You launch arduino IDE, there is usually a version number in a window header
  of the program. Elsewise it can be found by choosing "Help -> About" in the
  menu or program's window. The version number may be given "as is" or with
  dots - for example, if it looks like "1.0.6" it will be 0106.
- **ARD_HOME** - installation directory of the Arduino software. If it is
  installed on Linux by native package manager, it usually will be
  `/usr/share/arduino` (if not, try command `whereis arduino` and search
  inside folders that it gives). Other possible place is `/opt/arduino`.
  In the description of another variables, `$(ARD_HOME)` is the value of
  `ARD_HOME` variable, and it will expand to arduino installation directory path
  when `make` executes this master-Makefile and project-specific Makefile.
- **ARD_BIN** - path to a folder where compiler binaries resides. If Arduino IDE
  is installed globaly on Linux, usually it will be `/usr/bin` folder. Elsewise
  it may be inside `$(ARD_HOME)/hardware/tools/avr-gcc` folder.
- **AVRDUDE** - location of avrdude executable. For native-installed Arduino it is
  usually `/usr/bin/avrdude`, elsewise it may be
  `$(ARD_HOME)/hardware/tools/avrdude`.
- **AVRDUDE_CONF** - location of avrdude configuration file. If You don't want
  avrdude to use some special settings, look for default configuration file and
  write here path to it. For "native-installed" arduino the file is usually
  `/etc/avrdude/avrdude.conf`, in other case it may be
  `$(ARD_HOME)/hardware/tools/avrdude.conf`, If You want to configure avrdude
  with Your own configuration file - copy the default configuration file to the
  root of Your Arduino projects (sketches) or elsewhere, change it for Your
  needs and assign path to it to this `AVRDUDE_CONF` variable.
- **PROGRAMMER** - type of programmer hardware You are using - for avrdude
  programmer. Set to "arduino" to program arduino via on-board USB and
  bootloader.  If You need to use another arduino as a programmer, it will
  usually be "stk500v1".  Use command `avrdude -c?` to see full list of
  programmers, or see man page for avrdude.
- **MON_SPEED** - serial monitor speed - baudrate at which serial port will work
  when `make monitor` command  opens terminal window to monitor port's output.
- **EXTRA_FLAGS** - any extra flags that should be passed to the compilers (both
  C and C++). This variable can be omitted.

### 4. Add Your user to serial port users group

Under Linux, You may have problems when using a serial port to program Arduino
board or when trying to monitor port's output. To prevent this, add Your user
account to the group that has access to computer's serial ports.

At first, You need to know what port Your programmer or Arduino board is using.
To do that, just connect the device to USB and call

```bash
dmesg | grep tty
```

and You will see what serial device was connected and what dev file coresponds
to it. Usually it's in the last output line. If You are using "real" serial
port imbuilt into the computer, try to use same command but it may be trickier
to detect what port You are need (try to google how to do it). Oftenly it is
`/dev/ttyS0` or `/dev/ttyS1`.

Then see the owner group of the file for this port. Use command

```bash
ls -l /dev/ttyUSB0
```

where `/dev/ttyUSB0` must be substituted with right file name.
In output, this group name usually goes after the "root" word ("root" is the
owner user name). it is oftenly named "dialout".

Then add Your user to this group:

```bash
sudo usermod -a -G dialout username
```

where "dialout" must be substituted with right name of the group and
"username" - with the name of Your user.

After changing the group You need to reboot the computer or exit and enter into
the system.

Setup Arduino project
----------------------

To use the master Makefile, just add a new file with name `Makefile` into Your
project along with a sketch file (*.ino). This file must contain such
information - for example:

```Makefile
BOARD = mega
PORT = /dev/ttyUSB0
INC_DIRS = ../common
LIB_DIRS = $(ARD_HOME)/libraries/SPI ../libraries/Task ../libraries/VirtualWire

include ../arduino-makefile/Makefile
```

Last line must contain a relative or absolute path to the main Makefile after
the kewyord `include`. Above it the folowing settings variables must be given.

- **BOARD** - Arduino board type. You may get the list of available board names
  in the `boards.txt` file (usually located at
  `$(ARD_HOME)/hardware/arduino/boards.txt`). Use shell command
  `cat boards.txt | grep name` to retreive right name. See the first word of
  each output line, before first dot - that will be the right word to set up
  this variable. For example, to select Arduino nano with ATMega328, see the
  line `nano328.name=Arduino Nano w/ ATmega328`. The right value for a variable
  will be `nano328`
- **PORT** - serial port (or USB-serial). How to determine the right port - see
  above, last subsection of "Basic setup" section. On Linux, for devices
  connected via USB it is usually `/dev/ttyUSB0`, for devices connected via
  hardware serial (COM) port - `/dev/ttyS0`. On Solaris it usually will be one
  of files located under `/dev/term` directory.
- **INC_DIRS** - list of directories containing common or additional header files.
  It's useful if You want to store something in a C++ header file that
  is common for few projects. This variable should be optional but for now You
  must to set it to some existant folder (You may create it specially). 
- **LIB_DIRS** - *full* list of directories containing library sources,
  separated by spaces.  here must be paths to ALL libraries:
  - libraries inside Your sketches folder - by the standard for the Arduino IDE
    they are located in "libraries" folder under sketches root folder. This
    means that if You want to add some external library, You must:
    - Go into that folder (for example `~/sketches/libraries`);
    - Copy external library there or clone it from Github (or other GIT repo);
    - Add this path to this library to the variable, for example:
      `LIB_DIRS = ../libraries/arduino-mcp2515/`.
  - Libraries that are shipped with Arduino, used by Your project and by
    additional libraries connected to it (from `../libraries` folder).
    That means that You need to analyze Your project and every file of included
    libraries and see what Arduino "standard" libraries are included there, or
    just try to compile and look up on errors about missing header files. Then
    You must:
    - Search for Arduino standard libraries location. Usually it is under
      `$(ARD_HOME)/libraries`.
    - Select folder containing needed library and add to this variable. For
      example, add a space and `$(ARD_HOME)/libraries/SofrwareSerial` if You
      need SoftwareSerial library. (`$(ARD_HOME)` will expand to the variable
      defined in main Makefile when `make` works.)

Also You can add those additional variables (any or all of them may be omitted):

- **EXTRA_C_FLAGS** - any extra flags that will be passed to the C compiler
  (only).
- **EXTRA_CXX_FLAGS** any extra flags that should be passed to the C++ compiler.
  For example, some libraries loaded from Github may require C++ v11 statdard to
  compile properly. In that case set this variable to `-std=c++11`.

And also You can set here any variables of master Makefile, described in "Basic
setup" section. They will override values set in master Makefile. That means
that You can make any of that settings project-specific.

Just don't forget that master makefile must be included only by the string below
all of those variable definitions.

Usage
-----

In the shell, go inside the directory containing Your project and after that run
needed make command. Here are all possible variants.

- **make** or **make compile** will create `build` folder inside Your project's
  dir and compile all source code inside it:
  - Arduino core libraries will compile to *libarduino.a*;
  - external libraries (that You're downloaded from Github for example) - to
    *liblibrary.a* (there is even no changes in sources of that libraries
    needed, nor some additional makefiles);
  - project itself will be compiled to *my-sketch_project.o* (here "my-sketch"
    will be substituted with name of the project).
  - all this will be linked and transformed into resulting *.hex* file (that You
    can download to Your board with any programmer You wish).
  - Also there will be many *.lst* files that can be used for debugging. They
    contain description of assembler code generated for each compiled object
    file.
- **make upload** will compile entire project (if that was not done yet) and
  upload resulting *.hex* into Arduino board.
- **make clean** will remove *build* folder with all of it's contents.
- **make monitor** will run the monitoring of serial port's output in the
    terminal window. Its functionality almost the same as of port monitor in the
    Arduino IDE. Any key that You press generates symbol that is sent
    immediately to serial port, and all data received from that port appears as
    symbols on the screen.
    It uses shell `screen` command, so all basic commands for the terminal
    consists of pressing `<Ctrl-a>` and then a key that coresponds to some
    command. After calling the monitor You can use such commands:
    - press `<Ctrl-a> \` and then `y` to exit from terminal;
    - press `<Ctrl-a> ?` to show list of all available commands.
- **make upload_monitor** will compile the project (if it wasn't compilled yet),
    upload firmware to the Arduino board and run port monitor.

