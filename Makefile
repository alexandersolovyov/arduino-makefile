#
# Copyright 2011 Alan Burlison, alan@bleaklow.com.  All rights reserved.
# Subsequently modified in 2021 by Aleksandr Solovyov, solovyov-alexander@yandex.ru
# Use is subject to license terms.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#  1. Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY ALAN BURLISON "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL ALAN BURLISON OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
# OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Makefile for building Arduino projects outside of the Arduino environment
#
# This makefile should be included into a per-project Makefile of the following
# form:
#
# ----------
# BOARD = mega
# PORT = /dev/ttyUSB0
# INC_DIRS = ../common
# LIB_DIRS = $(ARD_HOME)/libraries/SPI ../libraries/Task ../libraries/VirtualWire
# include ../arduino-makefile/Makefile
# ----------
#
# Where:
#   BOARD    : Arduino board type, from $(ARD_HOME)/hardware/boards.txt
#   PORT     : serial port (or USB-serial);
#              for Solaris it will be inside /dev/term
#   INC_DIRS : List of directories containing common or additional header files
#              (optional)
#   LIB_DIRS : Full list of directories containing library source;
#              here must be paths to ALL libraries:
#              - libraries inside Your sketches folder;
#              - if You get error about missing header files, maybe You need to
#                add some libraries shipped with arduino:
#                search for them in "libraries" folder inside arduino installation
#                directory, use $(ARD_HOME) variable as shown in example above
#
# Additional variables also may be set:
#
#   EXTRA_C_FLAGS    : any extra flags that should be passed to the C compiller
#   EXTRA_CXX_FLAGS  : any extra flags that should be passed to the C++ compiler
#                      (set newer standard etc.)
#                
#
# Before using this Makefile you can adjust the following macros to suit
# your environment, either by editing this file directly or by defining them in
# the Makefile that includes this one, in which case they will override the
# definitions below:
#   ARD_REV      : arduino software revision, e.g. 0017, 0018;
#                  launch arduino IDE and watch the version in window's header;
#                  it may be "as is" or with dots -
#                  for example, if it looks like "1.0.6" it will be 0106.
#   ARD_HOME         : installation directory of the Arduino software.
#   ARD_BIN          : location of compiler binaries
#   AVRDUDE          : location of avrdude executable
#   AVRDUDE_CONF     : location of avrdude configuration file
#   PROGRAMMER       : avrdude programmer type:
#                      use "arduino" to program via bootloader,
#                      or use command `avrdude -c?` to see full list of programmers,
#                      or see man page for avrdude
#   MON_SPEED        : serial monitor speed
#   EXTRA_FLAGS      : any extra flags that should be passed to the compilers
#
# --------------------------------------------------------
# This file is tested with such revisions of Arduino IDE:
# by Alan Burlison:       0016, 0018
# by Aleksandr Solovyov:  0106
# --------------------------------------------------------

# Global configuration.

#   Example for standalone installation of Arduino
# ARD_REV ?= 0018
# ARD_HOME ?= /opt/arduino
# ARD_BIN ?= $(ARD_HOME)/hardware/tools/gcc-avr/bin
# AVRDUDE ?= $(ARD_HOME)/hardware/tools/avrdude
# AVRDUDE_CONF ?= $(ARD_HOME)/hardware/tools/avrdude.conf
# PROGRAMMER ?= arduino
# MON_SPEED ?= 9600

# For Arduino installed with system's package manager
ARD_REV ?= 0106
ARD_HOME ?= /usr/share/arduino
ARD_BIN ?= /usr/bin
AVRDUDE ?= /usr/bin/avrdude
AVRDUDE_CONF ?= /etc/avrdude/avrdude.conf
PROGRAMMER ?= arduino
MON_SPEED ?= 9600

### Nothing below here should require editing. ###

#TODO:
#- Make AVRDUDE_CONF variable optional

# Check for the required definitions.
ifndef BOARD
    $(error $$(BOARD) not defined)
endif
ifndef PORT
    $(error $$(PORT) not defined)
endif

# Version-specific settings (incremental changes)
#  version < 0018
ifeq ($(shell test $(ARD_REV) -lt "0018"; echo $$?), 0)
    ARD_BOARDS = $(ARD_HOME)/hardware/boards.txt
    ARD_SRC_DIR = $(ARD_HOME)/hardware/cores/arduino
    ARD_MAIN = $(ARD_SRC_DIR)/main.cxx
    SKT_PROJECT_SRC := $(firstword $(wildcard *.pde))
    ARD_MAIN_HEADER = WProgram.h
    ARD_BOOTLOADERS_DIR = $(ARD_HOME)/hardware/bootloaders
endif
#  version >= 0018
ifeq ($(shell test $(ARD_REV) -ge "0018"; echo $$?), 0)
    ARD_BOARDS = $(ARD_HOME)/hardware/arduino/boards.txt
    ARD_SRC_DIR = $(ARD_HOME)/hardware/arduino/cores/arduino
    ARD_MAIN = $(ARD_SRC_DIR)/main.cpp
    ARD_BOOTLOADERS_DIR = $(ARD_HOME)/hardware/arduino/bootloaders
endif
#  version >= 0022
ifeq ($(shell test $(ARD_REV) -ge "0022"; echo $$?), 0)
    ARD_MAIN_HEADER = Arduino.h
#  maybe need to change version from which these variables are needed:
    ARD_VARIANTS_DIR = $(ARD_HOME)/hardware/arduino/variants
endif
#  version >= 0100
ifeq ($(shell test $(ARD_REV) -ge "0100"; echo $$?), 0)
    # project file became *.ino, but *.pde is also supported
    SKT_PROJECT_SRC := $(firstword $(wildcard *.ino) $(SKT_PROJECT_SRC))
endif

# Platform-specific settings.
PLATFORM = $(shell uname -s)
ifeq "$(PLATFORM)" "SunOS"
    define run-monitor
	gnome-terminal -t '$(BOARD) $(PORT)' \
	    -e 'env -i tip -$(MON_SPEED) $(PORT)' &
    endef
    define kill-monitor
	- pkill -f 'tip.*$(PORT)'
    endef
else ifeq "$(PLATFORM)" "Linux"
    define run-monitor
        @ $(ECHO) "Inside terminal:"
        @ $(ECHO) "use '<Ctrl-a> \' to exit from it,"
        @ $(ECHO) "use '<Ctrl-a> ?' to show help."
	screen $(PORT) $(MON_SPEED)
    endef
    define kill-monitor
	- pkill -f 'screen.*$(PORT)'
    endef
else ifeq "$(PLATFORM)" "Darwin"
    $(error No monitor command for platform $(PLATFORM))
else
    $(error Unknown platform $(PLATFORM))
endif

# Standard macros.
SKETCH = $(notdir $(CURDIR))
BUILD_DIR = build
VPATH = $(LIB_DIRS)

# Macros derived from boards.txt
MCU := $(shell sed -n 's/$(BOARD)\.build\.mcu=\(.*\)/\1/p' < $(ARD_BOARDS))
F_CPU := $(shell sed -n 's/$(BOARD)\.build\.f_cpu=\(.*\)/\1/p' < $(ARD_BOARDS))
UPLOAD_SPEED := \
    $(shell sed -n 's/$(BOARD)\.upload\.speed=\(.*\)/\1/p' < $(ARD_BOARDS))
# board variant
VARIANT := \
    $(shell sed -n 's/$(BOARD)\.build\.variant=\(.*\)/\1/p' < $(ARD_BOARDS))
# Bootloader data
BOOTLOADER_FILE := \
    $(shell sed -n 's/$(BOARD)\.bootloader\.file=\(.*\)/\1/p' < $(ARD_BOARDS))
BOOTLOADER_FILE := \
    $(shell sed -n 's/$(BOARD)\.bootloader\.path=\(.*\)/\1/p' < $(ARD_BOARDS))/$(BOOTLOADER_FILE)
BOOTLOADER_LFUSE := \
    $(shell sed -n 's/$(BOARD)\.bootloader\.low_fuses=\(.*\)/\1/p' < $(ARD_BOARDS))
BOOTLOADER_HFUSE := \
    $(shell sed -n 's/$(BOARD)\.bootloader\.high_fuses=\(.*\)/\1/p' < $(ARD_BOARDS))
BOOTLOADER_EFUSE := \
    $(shell sed -n 's/$(BOARD)\.bootloader\.extended_fuses=\(.*\)/\1/p' < $(ARD_BOARDS))
BOOTLOADER_UNLK := \
    $(shell sed -n 's/$(BOARD)\.bootloader\.unlock_bits=\(.*\)/\1/p' < $(ARD_BOARDS))
BOOTLOADER_LK := \
    $(shell sed -n 's/$(BOARD)\.bootloader\.lock_bits=\(.*\)/\1/p' < $(ARD_BOARDS))

# Build tools.
CC = $(ARD_BIN)/avr-gcc
CXX = $(ARD_BIN)/avr-g++
CXXFILT = $(ARD_BIN)/avr-c++filt
OBJCOPY = $(ARD_BIN)/avr-objcopy
OBJDUMP = $(ARD_BIN)/avr-objdump
AR = $(ARD_BIN)/avr-ar
SIZE = $(ARD_BIN)/avr-size
NM = $(ARD_BIN)/avr-nm
MKDIR = mkdir -p
RM = rm -rf
MV = mv -f
ECHO = echo

# Compiler flags.
INC_FLAGS = \
    $(addprefix -I,$(INC_DIRS)) $(addprefix -I,$(LIB_DIRS)) -I$(ARD_SRC_DIR)
ifneq "$(VARIANT)" ""
    IQUOTE_FLAGS = -iquote$(ARD_VARIANTS_DIR)/$(VARIANT)
endif
ARD_FLAGS = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -DARDUINO=$(ARD_REV)
C_CXX_FLAGS = \
    -Wall -Wextra -Wundef -Werror -Wno-unused-parameter \
    -fdiagnostics-show-option -g -Wa,-adhlns=$(BUILD_DIR)/$*.lst \
    $(EXTRA_FLAGS)
C_FLAGS = \
    -std=gnu99 -Wno-old-style-declaration $(C_CXX_FLAGS) $(EXTRA_C_FLAGS)
#    -std=gnu99 -Wstrict-prototypes -Wno-old-style-declaration $(C_CXX_FLAGS)
CXX_FLAGS = \
    -Wno-error=strict-aliasing -Wno-error=write-strings -Wno-error=type-limits \
    -Wno-sign-compare -Wno-unused-variable $(C_CXX_FLAGS) $(EXTRA_CXX_FLAGS)

# Optimiser flags.
#     optimise for size, unsigned by default, pack data.
#     separate sections, drop unused ones, shorten branches, jumps.
#     don't inline, vectorise loops. no exceptions.
#     no os preamble, use function calls in prologues.
# http://gcc.gnu.org/onlinedocs/gcc-4.3.5/gcc/
# http://www.tty1.net/blog/2008-04-29-avr-gcc-optimisations_en.html
OPT_FLAGS = \
     -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums \
    -ffunction-sections -fdata-sections -Wl,--gc-sections,--relax \
    -fno-inline-small-functions -fno-tree-scev-cprop -fno-exceptions \
    -ffreestanding -mcall-prologues

# Build parameters.
IMAGE = $(BUILD_DIR)/$(SKETCH)
ARD_C_SRC = $(wildcard $(ARD_SRC_DIR)/*.c)
ARD_CXX_SRC = $(wildcard $(ARD_SRC_DIR)/*.cpp)
ARD_C_OBJ = $(patsubst %.c,%.o,$(notdir $(ARD_C_SRC)))
ARD_CXX_OBJ = $(patsubst %.cpp,%.o,$(notdir $(ARD_CXX_SRC)))
ARD_LIB = arduino
ARD_AR = $(BUILD_DIR)/lib$(ARD_LIB).a
ARD_AR_OBJ = $(ARD_AR)($(ARD_C_OBJ) $(ARD_CXX_OBJ))
ARD_LD_FLAG = -l$(ARD_LIB)

# Workaround for http://gcc.gnu.org/bugzilla/show_bug.cgi?id=34734
$(ARD_AR)(Tone.o) : CXX_FLAGS += -w

# Sketch libraries.
LIB_C_SRC = $(foreach ld,$(LIB_DIRS),$(wildcard $(ld)/*.c))
LIB_CXX_SRC = $(foreach ld,$(LIB_DIRS),$(wildcard $(ld)/*.cpp))
LIB_SRC = $(LIB_C_SRC) $(LIB_CXX_SRC)
ifneq "$(strip $(LIB_C_SRC) $(LIB_CXX_SRC))" ""
	LIB_C_OBJ = $(patsubst %.c,%.o,$(notdir $(LIB_C_SRC)))
	LIB_CXX_OBJ = $(patsubst %.cpp,%.o,$(notdir $(LIB_CXX_SRC)))
	LIB_LIB = library
	LIB_AR = $(BUILD_DIR)/lib$(LIB_LIB).a
	LIB_AR_OBJ = $(LIB_AR)($(LIB_C_OBJ) $(LIB_CXX_OBJ))
	LIB_LD_FLAG = -l$(LIB_LIB)
endif

# Sketch project file source (must be set in version-specific settings).
# SKT_PROJECT_SRC = *.ino or *.pde
$(info ---------------------------------------)
$(info Make project $(SKT_PROJECT_SRC))
$(info ---------------------------------------)
ifneq "$(strip $(SKT_PROJECT_SRC))" ""
	SKT_PROJECT_OBJ = $(BUILD_DIR)/$(SKETCH)_project.o
else
    $(error There is no source file or its extension is unsupported)
    $(error (try to change .ino extension to .pde if You are using Arduino older than 0100))
    $(error Compilation will fail!)
endif

# C and C++ source.
SKT_C_SRC = $(wildcard *.c)
SKT_CXX_SRC = $(wildcard *.cpp)
ifneq "$(strip $(SKT_C_SRC) $(SKT_CXX_SRC))" ""
	SKT_C_OBJ = $(patsubst %.c,%.o,$(SKT_C_SRC))
	SKT_CXX_OBJ = $(patsubst %.cpp,%.o,$(SKT_CXX_SRC))
	SKT_LIB = sketch
	SKT_AR = $(BUILD_DIR)/lib$(SKT_LIB).a
	SKT_AR_OBJ = $(SKT_AR)/($(SKT_C_OBJ) $(SKT_CXX_OBJ))
	SKT_LD_FLAG = -l$(SKT_LIB)
endif

# Common rule bodies.
define run-cc
	@ $(ECHO) ""
	@ $(ECHO) "Compiling target $@"
	$(CC) -c $(C_FLAGS) $(OPT_FLAGS) $(ARD_FLAGS) $(INC_FLAGS) \
	    $(IQUOTE_FLAGS) \
	    -MD -MT '$@($%)' -MF $(@D)/.$(@F)_$*.dep $< -o $(BUILD_DIR)/$%
	@ $(AR) rc $@ $(BUILD_DIR)/$%
	@ $(RM) $(BUILD_DIR)/$%
	@ $(CXXFILT) < $(BUILD_DIR)/$*.lst > $(BUILD_DIR)/$*.lst.tmp
	@ $(MV) $(BUILD_DIR)/$*.lst.tmp $(BUILD_DIR)/$*.lst
endef

define run-cxx
	@ $(ECHO) ""
	@ $(ECHO) "Compiling target $@"
	$(CXX) -c $(CXX_FLAGS) $(OPT_FLAGS) $(ARD_FLAGS) $(INC_FLAGS) \
	    $(IQUOTE_FLAGS) \
	    -MD -MT '$@($%)' -MF $(@D)/.$(@F)_$*.dep $< -o $(BUILD_DIR)/$%
	@ $(AR) rc $@ $(BUILD_DIR)/$%
	@ $(RM) $(BUILD_DIR)/$%
	@ $(CXXFILT) < $(BUILD_DIR)/$*.lst > $(BUILD_DIR)/$*.lst.tmp
	@ $(MV) $(BUILD_DIR)/$*.lst.tmp $(BUILD_DIR)/$*.lst
endef

# Rules.
.PHONY : compile clean upload monitor upload_monitor bootloader

compile : $(BUILD_DIR) $(IMAGE).hex
	@ $(ECHO) ""
	@ $(ECHO) "Project is compiled successfuly!"
	@ $(ECHO) ""

clean :
	@ $(ECHO) "Cleaning up..."
	@ $(ECHO) ""
	$(RM) $(BUILD_DIR)

$(BUILD_DIR) :
	$(MKDIR) $@

$(SKT_PROJECT_OBJ) : $(SKT_PROJECT_SRC)
	@ $(ECHO) ""
	@ $(ECHO) "Building project's object file $@:"
	@ $(ECHO) ""
	@ echo $(INC_FLAGS)
	echo '#include <$(ARD_MAIN_HEADER)>' > $(BUILD_DIR)/$(SKETCH)_project.cpp
	cat $(SKT_PROJECT_SRC) >> $(BUILD_DIR)/$(SKETCH)_project.cpp
	cd $(BUILD_DIR) && $(CXX) -c $(subst build/,,$(CXX_FLAGS)) \
	    $(OPT_FLAGS) $(ARD_FLAGS) -I.. \
	    $(patsubst -I..%,-I../..%,$(INC_FLAGS)) \
	    $(IQUOTE_FLAGS) \
	    $(SKETCH)_project.cpp -o $(@F)

(%.o) : $(ARD_SRC_DIR)/%.c
	$(run-cc)

(%.o) : $(ARD_SRC_DIR)/%.cpp
	$(run-cxx)

(%.o) : %.c
	$(run-cc)

(%.o) : %.cpp
	$(run-cxx)

$(BUILD_DIR)/%.d : %.c
	$(run-cc-d)

$(BUILD_DIR)/%.d : %.cpp
	$(run-cxx-d)

# The multiple "-lm" flags are to work around a linker bug.
$(IMAGE).hex : $(ARD_AR_OBJ) $(LIB_AR_OBJ) $(SKT_AR_OBJ) $(SKT_PROJECT_OBJ)
	@ $(ECHO) ""
	@ $(ECHO) "Building project file $@:"
	@ $(ECHO) ""
	$(CC) -lm $(CXX_FLAGS) $(OPT_FLAGS) $(ARD_FLAGS) -L$(BUILD_DIR) \
	    $(SKT_PROJECT_OBJ) $(SKT_LD_FLAG) $(LIB_LD_FLAG) $(ARD_LD_FLAG) \
	    -lm -o $(IMAGE).elf
	$(OBJCOPY) -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load \
	    --no-change-warnings --change-section-lma .eeprom=0 $(IMAGE).elf \
	    $(IMAGE).eep
	$(OBJCOPY) -O ihex -R .eeprom $(IMAGE).elf $(IMAGE).hex
	$(OBJDUMP) -h -S $(IMAGE).elf | $(CXXFILT) -t > $(IMAGE).lst
	$(SIZE) $(IMAGE).elf

upload : compile
	@ $(ECHO) ""
	@ $(ECHO) "Writing project to the device..."
	@ $(ECHO) ""
	$(kill-monitor)
	- $(AVRDUDE) -V -C$(AVRDUDE_CONF) -p$(MCU) -c$(PROGRAMMER) -P$(PORT) \
	    -b$(UPLOAD_SPEED) -D -Uflash:w:$(IMAGE).hex:i

monitor :
	@ $(ECHO) "Starting port monitor..."
	@ $(ECHO) ""
	$(kill-monitor)
	$(run-monitor)

upload_monitor : upload monitor

bootloader :
	@ $(ECHO) "Writing the bootloader..."
	@ $(ECHO) "NOTE:"
	@ $(ECHO) "Bootloader can be properly written only via ISP !"
	@ $(ECHO) "If trying to write via bootloader or JTAG -"
	@ $(ECHO) "it may erase the chip and definitely will fail all other operations!"
	@ $(ECHO) ""
	$(kill-monitor)
	@ $(ECHO) "Erase and unlock chip:"
	$(AVRDUDE) -V -C$(AVRDUDE_CONF) -p$(MCU) -c$(PROGRAMMER) -P$(PORT) \
	    -b$(UPLOAD_SPEED) -F -e -Ulock:w:$(BOOTLOADER_UNLK):m
	@ $(ECHO) "Write bootloader:"
	$(AVRDUDE) -V -C$(AVRDUDE_CONF) -p$(MCU) -c$(PROGRAMMER) -P$(PORT) \
	    -b$(UPLOAD_SPEED) -D -Uflash:w:$(ARD_BOOTLOADERS_DIR)/$(BOOTLOADER_FILE)
	@ $(ECHO) "Write fuses:"
	$(AVRDUDE) -V -C$(AVRDUDE_CONF) -p$(MCU) -c$(PROGRAMMER) -P$(PORT) \
	    -b$(UPLOAD_SPEED) -Ulfuse:w:$(BOOTLOADER_LFUSE):m
	- $(AVRDUDE) -V -C$(AVRDUDE_CONF) -p$(MCU) -c$(PROGRAMMER) -P$(PORT) \
	    -b$(UPLOAD_SPEED) -Uhfuse:w:$(BOOTLOADER_HFUSE):m
	- $(AVRDUDE) -V -C$(AVRDUDE_CONF) -p$(MCU) -c$(PROGRAMMER) -P$(PORT) \
	    -b$(UPLOAD_SPEED) -Uefuse:w:$(BOOTLOADER_EFUSE):m
	@ $(ECHO) "Lock access of a program to bootloader:"
	$(AVRDUDE) -V -C$(AVRDUDE_CONF) -p$(MCU) -c$(PROGRAMMER) -P$(PORT) \
	    -b$(UPLOAD_SPEED) -Ulock:w:$(BOOTLOADER_LK):m

-include $(wildcard $(BUILD_DIR)/.*.dep))

