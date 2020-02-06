# Binary Calculator
![logo UniPa](https://skin-new.unipa.it/images/logo.png)
## Introduction

## Hardware


### Raspberry Pi model 4B


### FTDI FT232RL
The FT232RL is a USB to serial UART interface<sup>[9](##References)</sup>,
it has been connected to the Raspberry Pi 4 UART1 in the following configuration:
* FTDI-RX to RPi-GPIO14 (TX)
* FTDI-TX to RPi-GPIO16 (RX)
* FTDI-Ground to RPi-GND

The micro USB of the FTDI module was connected to a USB port on a computer with the appropriate software to use it.
Without this module, it would not have been possible to send data to and from the  Board.

### I/O choices
#### QTEATAK push buttons
6x6x5 mm tactile push buttons with two pins, they are rated to work with up to 12V of direct current, so they are safe for use with the 3,3V output of the GPIO pins of the Raspberry.

Their mechanical life expectancy is of 100000 uses which leads to a worst-case scenario of 6250 operations before a malfunction, that is deemed sufficient for the intended purpose of this project.  
#### LED

### Pull-down resistors

![schematic](./schematic.png)
## Environment


### pijFORTHos
 The pijFORTHos environment is based on an assembly FORTH interpreter called JonesFOrth, originally written for i686 assembly by _Richard WM Jones_.

 Following portings  brought to the Bare-Metal OS for the Raspberry Pi

### Ubuntu 19.04

### Picocom and Minicom
Minicom is a terminal emulator software for Unix-like operating systems, it is commonly used when setting up a remote serial console.<sup>[7](##References)</sup>

Picocom is, in principle, very similar to minicom.
It was designed as a simple, manual, modem configuration, testing, and debugging tool.<sup>[10](##References)</sup>

In effect, picocom is not an "emulator" per se. It is a simple program that opens, configures, manages a serial port (tty device) and its settings, and connects to it the terminal emulator already in use.

In the scope of this project, it is used as a serial communications program to allow access to the serial console of the Raspberry.

As ASCII-XFR<sup>[8](##References)</sup> was chosen to send the source file to the Raspberry, it  

[...]
Trough the command
`sudo picocom --b 115200 /dev/ttyUSB0 --imap delbs -s "ascii-xfr -sv -l100 -c10"
`

## Software

### Control flow

### Input

#### Debouncing

While testing the input code it occurred that a single button press sometimes originated up to three valid reads from the `GPEDS0` register, a phenomenon known as bouncing.<sup>[1](##References)</sup>

Although there are some widely available valid hardware solutions<sup>[11](##References)</sup> the nature of this application does not warrant the added hardware complexity:
it is not unreasonable to assume that two keypresses in less than 0.2 seconds are unlikely to occur, therefore a software workaround by adding a delay after each successful read before clearing the register and starting polling again is feasible.


### Output

### Inner representation



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
