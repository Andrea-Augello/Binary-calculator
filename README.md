# Binary Calculator
![logo UniPa](https://skin-new.unipa.it/images/logo.png)
## Introduction

## Hardware


### Raspberry Pi model 4B


### FTDI FT232RL
The FT232RL<sup>[9]</sup> is a USB to serial UART interface,
it has been connected to the Raspberry Pi 4 UART1 in the following configuration:
* FTDI-RX to RPi-GPIO14 (TX)
* FTDI-TX to RPi-GPIO16 (RX)
* FTDI-Ground to RPi-GND

The micro USB of the FTDI module was connected to a USB port on a computer with the appropriate software to use it.
Without this module, it would not have been possible to send data to and from the  Board.

### I/O choices


### Pull-down resistors


## Environment


### pijFORTHos
 The pijFORTHos environment is based on an assembly FORTH interpreter called JonesFOrth, originally written for i686 assembly by _Richard WM Jones_.

 Following portings  brought to the Bare-Metal OS for the Raspberry Pi

### Ubuntu 19.04

### Picocom and Minicom
Minicom<sup>[7]</sup> is a terminal emulator software for Unix-like operating systems, it is commonly used when setting up a remote serial console.

Picocom<sup>[10]</sup> is, in principle, very similar to minicom.
It was designed as a simple, manual, modem configuration, testing, and debugging tool.

In effect, picocom is not an "emulator" per se. It is a simple program that opens, configures, manages a serial port (tty device) and its settings, and connects to it the terminal emulator already in use.

In the scope of this project, it is used as a serial communications program to allow access to the serial console of the Raspberry.

As ASCII-XFR<sup>[8]</sup> was chosen to send the source file to the Raspberry, it  

[...]
Trough the command
`sudo picocom --b 115200 /dev/ttyUSB0 --imap delbs -s "ascii-xfr -sv -l100 -c10"
`

## Software


### Bouncing


## Conclusion


### Possible improvements


## References
[1] [Jack G. Ganssle - A guide to debouncing ](https://my.eng.utah.edu/~cs5780/debouncing.pdf)

[2]  [Sean Eron Anderson - Bit Twiddling Hacks](https://graphics.stanford.edu/~seander/bithacks.html)

[3] [Raspberry Pi 4 Model B preliminary datasheet](https://github.com/raspberrypi/documentation/blob/master/hardware/raspberrypi/bcm2711/rpi_DATA_2711_1p0_preliminary.pdf)

[4] [BCM2835 ARM Peripherals](https://github.com/raspberrypi/documentation/blob/master/hardware/raspberrypi/bcm2835/BCM2835-ARM-Peripherals.pdf)

[5] [BCM2835 datasheet errata](https://elinux.org/BCM2835_datasheet_errata)

[6] [pijFORTHos built-in words](https://github.com/Avoncliff/pijFORTHos/blob/master/doc/forth.md)

[7] [Minicom man page](http://man8.org/linux/man-pages/man1/minicom.1.html)

[8] [ASCII-XFR man page](http://man7.org/linux/man-pages//man1/ascii-xfr.1.html)

[9] [FT232RL datasheet](https://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT232R.pdf)

[10] [Picocom man page](https://www.mankier.com/1/picocom)

[11] [Gay W. (2017) MC14490 and Software Debouncing. In: Custom Raspberry Pi Interfaces. Apress, Berkeley, CA](https://link.springer.com/chapter/10.1007/978-1-4842-2406-9_5)
