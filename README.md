
Master Makefile for Arduino projects
====================================

This is a very simple main makefile to use with GNU Make utility for compiling
Your Arduino projects without the Arduino IDE.

There are also some more complete (and more complex) make systems for Arduino, such as
[Arduino-Makefile](https://github.com/sudar/Arduino-Makefile). You may find it
better fit to Your needs.

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

Setup for various IDEs
----------------------

I use Vim and there is nothing to write about: people uses it in many different
ways. If You use it, You most likely know how to set up build commands for Your
favorite keyboard shortcuts. See "Usage" section below for description of that
commands.

Not tried to use with other IDEs yet, so it would be great if somebody help me
to fulfill this section.

Usage
-----

**This section is under construction**
