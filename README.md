
---
title : "Binary Calculator on baremetal Raspberry Pi 4"
date: "February 2020"
author: "Andrea Augello, Università degli Studi di Palermo"

---
# Introduction

# Hardware


![Breadboard schematic](./media/schematic.png)


## Raspberry Pi model 4B

![Raspberry Pi model 4B](https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Raspberry_Pi_4_Model_B_-_Side.jpg/450px-Raspberry_Pi_4_Model_B_-_Side.jpg)

The Raspberry Pi 4B [Fig. 2] is the latest iteration of the Raspberry Pi SoC, launched on 24th June 2019[@PI_release],
it replaces the older Raspberry Pi 3 B+ which was based on the Broadcom BCM2835 chip[@BCM2835][@BCM2835_datasheet_errata] and boasts high-end specs:

* A 1.5GHz quad-core 64-bit ARM Cortex-A72 CPU
* 1GB, 2GB, or 4GB of LPDDR4 SDRAM
* Full-throughput Gigabit Ethernet
* Dual-band 802.11ac wireless networking
* Bluetooth 5.0
* Two USB 3.0 and two USB 2.0 ports
* Dual monitor support, at resolutions up to 4K
* VideoCore VI graphics, supporting OpenGL ES 3.x
* 4Kp60 hardware decode of HEVC video
* Complete compatibility with earlier Raspberry Pi products

Although claiming complete backward compatibility with earlier products, the documentation available in not very comprehensive[@pi4_datasheet], which makes porting code not always straightforward.

## FTDI FT232RL
The FT232RL is a USB to serial UART interface[@FT232RL],
it has been connected to the Raspberry Pi 4 UART1 in the following configuration:

* FTDI-RX to RPi-GPIO14 (TX)
* FTDI-TX to RPi-GPIO16 (RX)
* FTDI-Ground to RPi-GND

The micro USB of the FTDI module was connected to a USB port on a computer with the appropriate software to use it.
Without this module, it would not have been possible to send data to and from the  Board.

## I/O choices
### Qteatak push buttons

![](https://www.ubuy.co.th/productimg/?image=aHR0cHM6Ly9tLm1lZGlhLWFtYXpvbi5jb20vaW1hZ2VzL0kvNTE2bnRENnE4M0wuX0FDX1VTMjE4Xy5qcGc.jpg)

With ease of use and familiarity of a potential end-user with similar products push buttons were considered an appropriate choice for an input method,
moreover, single buttons were chosen in favor of a button matrix because a 3x3 button matrix would require 6 pin connections against the 7 needed in the other case, but the added complexity does not make it a worthwhile trade-off.  

The chosen buttons are 6x6x5 mm tactile push buttons with two pins produced by Qteatak a Shenzhen based electronics company, they are rated to work with up to 12V of direct current, so they are safe for use with the 3,3V output of the GPIO pins of the Raspberry.

Their mechanical life expectancy is of 100000 uses which leads to a worst-case scenario of 6250 operations before a malfunction, that is deemed sufficient for the intended purpose of this project.  

### LED

![](https://cdn-reichelt.de/bilder/web/xxl_ws/A500/LED5MM.png)

Due to the base two chosen for the calculator, it seemed a natural decision to display the numbers using LED lights, with lit LEDs standing for a 1 bit and an off light standing for a 0 bit.  
To avoid possible confusion when interpreting the result an extra LED lights up to signal if the shown number is negative and, as such, has to be read as a two's complement.  
Moreover, since there is a very limited number of bits to display values if the actual result is outside the representable range and is thus truncated a red LED light will turn on to signal the overflow.


# Environment


## pijFORTHos
 The pijFORTHos environment is based on an assembly FORTH interpreter called JonesForth, originally written for i686 assembly by _Richard WM Jones_.

 Following portings  brought to the Bare-Metal OS for the Raspberry Pi

## Ubuntu 19.04

## Picocom and Minicom
Minicom is a terminal emulator software for Unix-like operating systems, it is commonly used when setting up a remote serial console.[@Minicom]

Picocom is, in principle, very similar to minicom.
It was designed as a simple, manual, modem configuration, testing, and debugging tool.[@Picocom]

In effect, picocom is not an "emulator" per se. It is a simple program that opens, configures, manages a serial port (tty device) and its settings, and connects to it the terminal emulator already in use.

In the scope of this project, it is used as a serial communications program to allow access to the serial console of the Raspberry.

As ASCII-XFR[@ASCII] was chosen to send the source file to the Raspberry, it  

[...]

Trough the command
`sudo picocom --b 115200 /dev/ttyUSB0 --imap delbs -s "ascii-xfr -sv -l100 -c10"
`

# Software
Since it is not possible with the selected environment to have the Raspberry automatically load the source code at startup, the code is to be sent via a serial connection.

Since the file transfer happens character by character at a quite limited speed and every file has to be selected singularly, it is convenient to use a bash script to remove unessential parts of the code (i.e. comments and empty lines) and merge everything into a single file.

The developed script, `merge_source.sh`, makes use of `awk` to recognize comments and not print them, and `sed` to remove lines containing only whitespaces.

```bash
#!/bin/bash
cd src
cat se-ans.f setup.f logic.f output.f input.f control.f |
awk -F"\\" '{print $1}' |
awk -F"[^A-Z]+[()][^A-Z]+" '{print $1 $    3}' |
sed '/^[[:space:]]*$/d' > ../merged_src.f

```

## ANSI compliance
JonesForth is not ANSI compliant[@pijFORTHos], hence some standard words do not behave as one would expect.

The `se-ans.f` code provided in the course materials contains some definitions to ensure compliance for some words of common use.

This code is the first to be loaded to ensure that the subsequent instructions are executed correctly.

## Utilities

The Raspberry Pi 4 B has a different procedure to set the internal pull-up/down compared to the older models, hence two functions are provided for compatibility's sake.
This has not yet been documented, however, one can gain insight on how to change the pull-up/down settings by analyzing how some c libraries added support for the Broadcom 2711 GPIO[@pingpio] [@raspi-gpio]

## Control flow

## Input


### Debouncing

While testing the input code it occurred that a single button press sometimes originated up to three valid reads from the `GPEDS0` register, a phenomenon known as bouncing.[@ganssle2004guide]

Although there are some widely available valid hardware solutions[@gay2017mc14490] the nature of this application does not warrant the added hardware complexity:
By trial and error it was found that the bouncing lasts less than 0.2 seconds, and
it is not unreasonable to assume that two keypresses in less than 0.2 seconds are unlikely to occur[@kinkead1975typing], therefore it is feasible to implement a software workaround by adding a delay after each successful read,
and then clearing the register before polling again.


## Output

## Inner representation



# Conclusion


## Possible improvements

# References

[Bibtex file](./paper.bib)
