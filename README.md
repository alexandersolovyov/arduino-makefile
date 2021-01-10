
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
with another IDEs, such as Eclipse, NetBeans or even Vim. With this makefile 
You can (almost) easily set up Your favorite environment to code for Arduino.

Note about Operating Systems
----------------------------

Original file was created mainly to work on Solaris OS, and here it is reworked
to work best under Linux.

I did not do any efforts to make it work for Windows,
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

Then You have two options:

- If You do not plan to use GIT for committing changes to some outer repository,
  simply create file "Makefile.master" at the root folder of Your Arduino
  projects and copy contents of the makefile into it.
- If You plan to use GIT for some reason, clone this repository into the root of
  Your Arduino projects (by default, on Linux it is `~/sketches`). For example,
  go into that folder and do

```bash
git clone https://github.com/alexandersolovyov/arduino-makefile.git
```

This will be the main Makefile for all of Your
Arduino projects. Each project will have its own, more simple makefile,
to which this main makefile must be included.

### 3. Edit the makefile to fit for Your environment

Change global configuration variables in this main makefile to that fitting to
Your Arduino installation and avrdude programmer settings. Comments in the file
will guide You.

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
