# EE2026 Sound Display and Entertainment System

NUS EE2026 AY19/20 S1 project for Monday 2pm Group 8 (John and Andrew)

For use on Basys 3 with microphone (port A) and OLED (port B) Pmod attachments.

Developed with Vivado 2018.2.

## Usage

The system will be initialised to the Volume Indicator feature. The switches (SWn, where n is an integer from 0 to 15) can be switched on (1) or off (0) and the push buttons (PBx, where x = U (up), D (down), L (left), R (right), C (centre)) can be pressed to control aspects of various features.

When SW15 is on, PBU and PBD will switch between the different features.

## Feature List

### Volume Indicator

Indicates the volume of the sound being received at the mic. 

Use SW0 and SW1 to switch colour schemes:

|SW0|SW1|Colour Scheme|
|---|---|-------------|
|0|0|Default|
|0|1|Ocean|
|1|0|Earth|
|1|1|Sunset|


Use SW9 and SW10 to control which 7-seg digits show are active:

|SW9|SW10|Display Position|
|----|----|-------------|
|0|0|The first 2 digits from the right|
|0|1|The first 2 digits from the left|
|1|0|The middle 2 digits|
|1|1|Same as 0, 1|

The other switches can toggle other features of the visualisation:

|Switch|Component|On Effect|Off Effect|
|------|------------|-------------|-------------|
|SW2|Border Thickness|3px|1px|
|SW3|Volume Bar|Disable|Enable|
|SW4|Border|Disable|Enable|
|SW5|Volume Bar Width|1px|3px|
|SW6|Volume Bar Thickness|48px|16px|
|SW15|Display Source|`mic_in` values on 12 LEDs|Peak intensity on 15 LEDs, decimal digits on 7-seg|

SW13 freezes the display at the current value when switched on, while SW14 forces output display to 0 when switched on.

### Vertical Volume Indicator

As above, but with bars being vertical rather than horizontal.

### Rectangular Volume Indicator

As above, but with rectangles of varying areas representing volume instead.

|SW5|SW7|Form|
|---|---|-------------|
|0|0|Default single resizeable rectangular volume indicator|
|0|1|4 resizeable rectangular volume indicators|
|1|0|1 rectangular volume indicator that moves around in response to sound|

### Circular Volume Indicator

As above, but with circles of varying areas representing volume instead.

|SW5|SW7|Form|
|---|---|-------------|
|0|0|Default single resizeable circular volume indicator|
|0|1|5 resizeable circular volume indicators|
|1|0|1 circular volume indicator that moves around in response to sound|

### Space Invaders 

PBL/PBR to move left/right and PBU to shoot. Enemies spawn and attack based on the frequency of the sound received at the mic. If the frequency associated with an enemy is high enough, the LEDs corresponding to its position will light up and it will respawn or attack, with its colour based on the intensity of the frequency too. Score is displayed on 7-seg. Being hit by an enemy shot resets the game, and sets your score to 0. The 7-seg will display “DEAD” until the character is respawned.

### Frequency Visualisation

Visualisation of the Fourier transform of the audio being received, with high frequency at the centre and low frequency at the edges. 7-seg will display which range has the predominant frequency and the LEDs will indicate the intensity, as per “Frequency-response eagle” below.

### Frequency-Response Eagle

Eagle that flaps its wings faster when frequency increases. Eagle’s flight direction can be set using the push buttons. For a certain speed to be reached, the greatest intensity of sound must be in the relevant frequency range. 7-seg indicates current speed of eagle and LED indicates the intensity of sound in the range (e.g. if the frequency is mostly in the middle, led[9:5] indicates how high the FFT value in that range is, led[4:0] is always on, and led[14:10] is always off).

Eagle sprites from [Amysaurus](https://www.xyphien.com/forums/resources/eagle-vulture-sprite-edits.113/).
