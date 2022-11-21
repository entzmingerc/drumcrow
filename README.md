# drumcrow
This script turns Crow into a 4-channel drum machine driven with Monome Teletype.  

**Demos**  
Originally adapted from License's Flash Crash performance [here](https://www.youtube.com/watch?v=SYfeBtJjQ-M)  
postsolarpunk Flash Crash performance [here](https://www.youtube.com/watch?v=_EKpT1tO02o)  
playing around [here](https://www.youtube.com/watch?v=W48sP1b27rA)

# What is this?
Make an oscillator by pushing voltage up and down with ASL. Dyn variables update amplitude, frequency, and other parameters of the ASL oscillator. Teletype sends commands to Crow using i2c to set parameters and trigger envelopes. Teletype + drumcrow = Drum machine!  

First, patch a constant voltage with a range 0 - 10V into Crow input 1. You can use teletype to do this or something else. In M type `CV 4 PRM` to set CV 4 output to the Parameter knob. Then patch this to Crow's input 1. Next, patch each Crow output to a mixer so you can hear the audio.  
`CROW.C3 X Y Z` Trigger the envelope on X (channel) Y (note) Z (volume)  
`CROW.C1 X` Select a parameter. Adjust the voltage at Crow input 1 to adjust the parameter value.  

# Example Kick and Snare Pattern
Connect CV output 4 on Teletype to Crow input 1.  
Use the Param knob on Teletype to set Crow input 1 voltage 0-10V. Alternatively, you can use any 0-10V voltage source. 
```
TELETYPE SCRIPTS:
M: 
CV 4 PARAM
EVERY 2: SCRIPT 1
EVERY 4: SCRIPT 2

1:
CROW.C3 1 V -2 V 10

2: 
CROW.C3 2 V 4 V 6
```
```
LIVE INPUT: 
// Set M to your favorite tempo
M 172

// Set Channel 1 to sine wave kick drum
// 1 set model, 2 sine shape, 1 oscillator model, 1 channel
CROW.C1 1211

// Adjust Kick drum 
// ENV cycle time (111) ENV pitch depth (151)
// Use PARAM knob to set the value each time
CROW.C1 111
CROW.C1 151

// Change Snare drum to LCG (noise)
// 1 set model, 1 linear shape, 4 LGG model, 2 channel
CROW.C1 1142

// Adjust Snare drum parameters PW2, decay time, pitch envelope of Channel 2
// Use PARAM knob to set the value each time
CROW.C1 22
CROW.C1 112
CROW.C1 152
```
Continue adding more voices, adjusting parameters, modulating sounds, sequencing drum patterns

# Teletype Commands
## CROW.C1 X  
Select a parameter to set Crow input 1 voltage to  
| TT Command | DIGIT 3 | DIGIT 2 | DIGIT 1 | Description |
| --- | --- | --- | --- | --- |
| `CROW.C1 0` | ~ | ~ |  0 | Deselect a parameter, maps input voltage to nothing |
| `CROW.C1 1X` | ~ | 1 Pulse Width | 1-4 Channel | Sets the pulse width for a channel |
| `CROW.C1 2X` | ~ | 2 Pulse Width 2 | 1-4 Channel | Sets a second pulse width variable a channel <br> Changes depending on the model |
| `CROW.C1 3X` | ~ | 3 Bitcrush Amount | 1-4 Channel | Sets a quantizer v/oct for a channel, bitcrush distortion <br> V <= 5 :: OFF <br> 5 < V <= 10 :: Temperament at 2 and V/Oct from 1 to 20 |
| `CROW.C1 11X` | 1 FREQ ENV | 1 Cycle Time | 1-4 Channel | Select enevelope cycle time <br> 0 <= V <= 9.75 :: 0.006 sec - 100 sec <br> 9.75 < V <= 10 :: 2<sup>32</sup> seconds <br> [billions and billions](https://en.wikipedia.org/wiki/Carl_Sagan#%22Billions_and_billions%22)|
| `CROW.C1 12X` | 1 FREQ ENV | 2 Attack / Decay | 1-4 Channel | Select envelope attack / decay ratio <br> V = 0.0 :: Attack 0% Decay 100% Quieter <br> V = 2.5 :: Attack 0% Decay 100% <br> V = 5.0 :: Attack 50% Decay 50% <br> V = 7.5 :: Attack 100% Decay 0% <br> V = 10 :: Attack 100% Decay 0% Quieter Infinite Release|
| `CROW.C1 13X` | 1 FREQ ENV | 3 Curvature | 1-4 Channel | Select envelope curvature <br> 0 <= V <= 10 :: 2<sup>-5</sup> ... 0 ... 2<sup>5</sup> <br> square ... linear ... logarithmic|
| `CROW.C1 14X` | 1 FREQ ENV | 4 Mod Depth PW | 1-4 Channel | Select envelope modulation depth of PW <br> Scales the envelope by a number <br> 0 <= V <= 10 :: -5 ... 0 ... +5|
| `CROW.C1 15X` | 1 FREQ ENV | 5 Mod Depth NOTE | 1-4 Channel | Select envelope modulation depth of NOTE <br> Scales the envelope by a number <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `CROW.C1 16X` | 1 FREQ ENV | 6 Looping | 1-4 Channel | V <= 1 :: Envelope looping OFF (default) <br> V > 1 :: Envelope looping ON | 
| `CROW.C1 21X` | 2 LFO | 1 Cycle Time | 1-4 Channel | Select LFO cycle time <br> 0.25 <= V <= 10 :: 0.001 Hz - 1024 Hz :: 724 sec - 0.001 sec <br> 0 <= V <= 0.25 :: 2<sup>32</sup> seconds <br> Fastest update time is 0.002sec or 250Hz, aliasing above this|
| `CROW.C1 22X` | 2 LFO | 2 Attack / Decay | 1-4 Channel | Select LFO attack / decay ratio <br> V = 0.0 :: Attack 0% Decay 100% Quieter <br> V = 2.5 :: Attack 0% Decay 100% <br> V = 5.0 :: Attack 50% Decay 50% <br> V = 7.5 :: Attack 100% Decay 0% <br> V = 10 :: Attack 100% Decay 0% Quieter Infinite Release|
| `CROW.C1 23X` | 2 LFO | 3 Curvature | 1-4 Channel | Select LFO curvature <br> 0 <= V <= 10 :: 2<sup>-5</sup> ... 0 ... 2<sup>5</sup> <br> square ... linear ... logarithmic|
| `CROW.C1 24X` | 2 LFO | 4 Mod Depth PW | 1-4 Channel | Select LFO modulation depth of PW <br> Scales the envelope by a number <br> 0 <= V <= 10 :: -5 ... 0 ... +5|
| `CROW.C1 25X` | 2 LFO | 5 Mod Depth NOTE | 1-4 Channel | Select LFO modulation depth of NOTE <br> Scales the envelope by a number <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `CROW.C1 26X` | 2 LFO | 6 Looping | 1-4 Channel | V <= 1 :: LFO looping OFF <br> V > 1 :: LFO looping ON (default)| 
| `CROW.C1 31X` | 3 AMP ENV | 1 Cycle Time | 1-4 Channel | Select enevelope cycle time <br> 0 <= V <= 9.75 :: 0.006 sec - 100 sec <br> 9.75 < V <= 10 :: 2<sup>32</sup> seconds |
| `CROW.C1 32X` | 3 AMP ENV | 2 Attack / Decay | 1-4 Channel | Select envelope attack / decay ratio <br> V = 0.0 :: Attack 0% Decay 100% Quieter <br> V = 2.5 :: Attack 0% Decay 100% <br> V = 5.0 :: Attack 50% Decay 50% <br> V = 7.5 :: Attack 100% Decay 0% <br> V = 10 :: Attack 100% Decay 0% Quieter Infinite Release|
| `CROW.C1 33X` | 3 AMP ENV | 3 Curvature | 1-4 Channel | Select envelope curvature <br> 0 <= V <= 10 :: 2<sup>-5</sup> ... 0 ... 2<sup>5</sup> <br> square ... linear ... logarithmic|
| `CROW.C1 34X` | 3 AMP ENV | 4 Mod Depth PW | 1-4 Channel | Select envelope modulation depth of PW <br> Scales the envelope by a number <br> 0 <= V <= 10 :: -5 ... 0 ... +5|
| `CROW.C1 35X` | 3 AMP ENV | 5 Mod Depth NOTE | 1-4 Channel | Select envelope modulation depth of NOTE <br> Scales the envelope by a number <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `CROW.C1 36X` | 3 AMP ENV | 6 Looping | 1-4 Channel | V <= 1 :: Envelope looping OFF (default) <br> V > 1 :: Envelope looping ON | 
| `CROW.C1 86X` | 8 | 6 | 1-4 Channel | Set a channel to its initial value | 
| `CROW.C1 86X` | 8 | 6 | 0 | Sets all channels to their initial values [86 Term](https://en.wikipedia.org/wiki/86_(term)) | 

### 4 digits  
| TT Command | DIGIT 4 | DIGIT 3 | DIGIT 2 | DIGIT 1 | Description |
| --- | --- | --- | --- | --- | --- |
| `CROW.C1 1XYZ` | 1 SET MODEL | 1-9 Shape | 1-7 Model | 1-4 Channel | Set model on a channel with a [shape](https://monome.org/docs/crow/reference/#shaping-cv) <br> Default :: Model = 1 var_saw, Shape = 1 linear|
| `CROW.C1 3XYZ` | 3 SET RATIO | 1-3 Mod Source | 1-5 Mod Parameter | 2-4 Channel | Set a channel's parameter value to a scaled value of channel 1's parameter value <br> 0 <= V <= 10 :: 1/10, 1/9, ..., 1/2, 1/1, 0, 1, 2, ..., 9, 10 <br> A value of 0 (V 5) disables the ratio setting|

## CROW.C2 X Y
| TT Command | Parameter | Value | Description |
| --- | --- | --- | --- |
| `CROW.C2 X Y` | 11-364 <br> Select Parameter <br> CROW.C1 see above | V 0 ... V 10 <br> TT Value | Set a channel parameter to a value directly |
| `CROW.C2 999 Y` | 999 <br> Set Modulation Update Time | V -10 ... V 10 <br> TT Value | Set update time <br> V -10 ... V 10 :: 0.002 - 0.1 seconds (default 0.003) <br> Parameters and modulation sources update faster ... slower <br> Turns a smooth ENV slope into a stair step |

CROW.C2 X Y = (mod source, mod parameter, channel) (value)  
Set a parameter directly  
CROW.C1 has higher priority than CROW.C2.  
If `CROW.C1 151` is currently selected and `CROW.C2 151 V 4` is sent, then the value of 151 is set to Crow input 1 (CROW.C1) and ignores CROW.C2.  
Most parameters can be set to zero by using V 5. (The 0V to 10V input is scaled to a -10 to +10 value internally)  
Use VV to set a parameter to a decimal value. For example: `CROW.C2 21 VV 750`  
Some parameters are sensitive to decimal changes (PW2, PW, CYCLE TIME, ...).  

## CROW.C3 X Y Z
| TT Command | X | Y | Z | Description |
| --- | --- | --- | --- | --- |
| `CROW.C3 X Y Z` | 1-4 Channel | V -10 ... V 10 <br> Note <br> TT Value | V -10 ... V 10 <br> Volume <br> TT Value | Triggers channel at note and volume <br> Retrigger AMP ENV and FREQ ENV if passed attack stage <br> Note usually V -2 ... V 8 <br> Volume usually V 0 ... V 10|

CROW.C3 X Y Z = (channel) (note) (volume)  
Trigger a note on a channel.  
Sequence notes using TT patterns, random values, and so on. Synth models change tone depending on note.  
Mix oscillators using volume parameter, sequence velocity, set to 0 to mute.

## Models
1. var_saw(amp, cyc, pw, shape) (Default)  
Up to a voltage, down to a negative voltage. Triangle shape with pulse width control. Time to travel between each voltage determined by cyc. Use shape to select 1 triangle, 2 sine, 5 square, or select any shape 1-9 to hear different tones.  
2. var_saw(amp, cyc, pw, shape)  
Same as 1 but with random noise added to cyc variable during the udpate loop, distinctive splashy noise.  
3. bytebeat(amp, cyc, pw, shape)  
Output voltage is stepped by PW each loop and wrapped between -20 ... 20. The time to complete each voltage step is determined by cyc.  
4. LCG(amp, cyc, pw, pw2, shape)  
Linear Congruential Generator is a pseudorandom number generator using the equation voltage(n+1) = (pw2 * voltage(n) + pw) mod 10. PW2 can be used to sweep through a large range of noisy sounds. PW2 is sensitive to decimal values as well, explore sweet spots. Note affects the sounds as well, higher pitches for higher frequency noise. Use short amplitude envelope cycle times for high hats and snares.  
5. FMstep(amp, cyc, pw, pw2, shape)  
This expands the var_saw model to multiply cyc by a dynamic variable x that sweeps between 1 and 2 at a speed set by PW2. Low PW values means a lower frequency is multiplied to the Note freq.  
6. ASLsine(amp, cyc, pw, shape)  
This is a root-product sine wave approximation y = x + 0.101321(x)^3. The var_saw model can select two voltage points to move between, but ASL can't directly step through a waveshape unless we were to make 100 ASL stages and step through a waveshape manually. Instead, we can loop one ASL stage, step x by PW each loop, wrap it between -pi and +pi, and now each voltage step roughly traces out a sine wave. Sounds real good. Time it takes between each voltage step is determined by cyc.  
7. ASLharmonic(amp, cyc, pw, shape)  
Same as ASLsine but we add a mul(-1) to x so that its polarity is negated each loop. This gives a frequency from the time it takes to step through the sine wave approximation and the frequency from the x variable flipping polarity back and forth. An attempt to generate harmonics.  

## Shapes  
Select the shape of the synth model listed in Monome Crow [documentation](https://monome.org/docs/crow/reference/#shaping-cv)  
[Easing functions](https://easings.net/) define how to walk point to point  
Shapes can be used to change the tone of the ASL oscillator.  
1 = linear  
2 = sine  
3 = logarithmic  
4 = exponential  
5 = now  
6 = wait  
7 = over  
8 = under  
9 = rebound  

## Ratios
`CROW.C1 3XYZ` The action (3) sets the parameter (XY) on channel (Z) equal to a scaled value of the same parameter on channel 1. Select a multiplier using Crow input 1 voltage. Multipliers are quantized to integer scalings.  
`CROW.C1 3312` turn up input voltage to V 6 ish, now Channel 2's amplitude envelope cycle time (31) is set to Channel 1's amplitude envelope cycle time x 2. When Channel 1's value is changed, Channel 2's value will be updated as well.  
Try linking LFO speed, ENV cycle time, ENV pitch modulation. Experiment!  
0 <= V <= 10 :: 1/10, 1/9, ..., 1/2, 1/1, 0, 1, 2, ..., 9, 10  
0 - disables ratio for the parameter  

# Future Development
- Get/set presets, sequence through presets, possibly using sequins table in Crow
- Norns can call i2c funcitons on Crow and could be used to drive drumcrow in addition to Teletype
- Ratio multiplier tuning for exponential parameters
- Write up ASL oscillator theory
- ByteBeat and Rungler oscillator possibly
