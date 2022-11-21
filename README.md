# drumcrow
This script turns Crow into a 4-channel drum machine driven with Monome Teletype.  

**Demos**  
Originally adapted from License's Flash Crash performance [here](https://www.youtube.com/watch?v=SYfeBtJjQ-M)  
postsolarpunk Flash Crash performance [here](https://www.youtube.com/watch?v=_EKpT1tO02o)  
playing around [here](https://www.youtube.com/watch?v=W48sP1b27rA)

# Teletype Commands
## CROW.C1 X
### 2 digits 
CROW.C1 X = (param, channel)  
| TT Command | DIGIT 2 | DIGIT 1 | Description |
| --- | --- | --- | --- |
| `CROW.C1 0` | ~ | ~ | Deselect a parameter, maps input voltage to nothing |
| `CROW.C1 1X` | 1 Pulse Width | 1-4 Channel | Sets the pulse width for a channel |
| `CROW.C1 2X` | 2 Pulse Width 2 | 1-4 Channel | Sets a second pulse width variable a channel <br> Used for varying purposes |
| `CROW.C1 3X` | 3 Bitcrush Amount | 1-4 Channel | Sets a quantizer v/oct for a channel, bitcrush distortion <br> V <= 5 :: OFF <br> 5 < V <= 10 :: Temperament at 2 and V/Oct from 1 to 20 |

### 3 digits  
CROW.C1 X = (mod source, mod parameter, channel)  
| TT Command | DIGIT 3 | DIGIT 2 | DIGIT 1 | Description |
| --- | --- | --- | --- | --- |
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
CROW.C1 X = (action, param 1, param 2, channel)
| TT Command | DIGIT 4 | DIGIT 3 | DIGIT 2 | DIGIT 1 | Description |
| --- | --- | --- | --- | --- | --- |
| `CROW.C1 1XYZ` | 1 SET MODEL | 1-9 Shape | 1-7 Model | 1-4 Channel | Set a channel to a synth model with a [shape](https://monome.org/docs/crow/reference/#shaping-cv) |
| `CROW.C1 3XYZ` | 3 SET RATIO | 1-3 Mod Source | 1-5 Mod Parameter | 2-4 Channel | Set a channel parameter to a scaled value of channel 1's parameter value <br> 0 <= V <= 0 :: 1/10, 1/9, ..., 1/2, 1/1, 0, 1, 2, ..., 9, 10 <br> A value of 0 (V 5) disables the ratio setting|



## CROW.C2 X Y
CROW.C2 X Y = (action, param 1, param 2, channe)
| TT Command | DIGIT 4 | DIGIT 3 | DIGIT 2 | DIGIT 1 | Description |
| --- | --- | --- | --- | --- | --- |
| `CROW.C1 1XYZ` | 1 SET MODEL | 1-9 Shape | 1-7 Model | 1-4 Channel | Set a channel to a synth model with a [shape](https://monome.org/docs/crow/reference/#shaping-cv) |

X = 3 digit number only (mod source, mod parameter, channel)  
Y = Teletype number  
Directly sets the parameter at X to the value of Y  
`CROW.C2 111 V 5` sets the envelope cycle time on channel 2 to the value V 5  
CROW.C1 has higher priority than CROW.C2. For example, if `CROW.C1 151` is currently selected and `CROW.C2 151 V 4` is sent, then the value of 151 is set to Crow input 1 (CROW.C1) and ignores CROW.C2.

## CROW.C3 X Y Z
X = Channel (1 - 4)  
Y = Pitch (Teletype number +/- V 10)  
Z = Volume (Teletype number +/- V 10)  
Trigger the envelope at channel X, with pitch Y, with volume Z  
`CROW.C3 1 V 4 V 9` triggers the envelope of channel 1 with pitch V 4 at volume V 9  

# Synth Parameters
Pitch and Volume determined when triggered with `CROW.C3`  
Pulse Width is set using 2 digit `CROW.C1` command  
Shape is selected using 4 digit `CROW.C1` command  

## Mod Sources 
1 = Envelope (ENV)  
2 = Low Frequency Oscillator (LFO)

## Mod Parameters
1 = Frequency (ENV cycle time or LFO rate)  
2 = Symmetry (attack : decay)  
3 = Curvature  
4 = Pulse Width (PW modulation from ENV or LFO)  
5 = Depth (pitch depth from ENV or LFO)  

## Channels
1 = Crow Output 1  
2 = Crow Output 2  
3 = Crow Output 3  
4 = Crow Output 4  

## Models
1 = Variable Oscillator (2-stage ASL, goes up, goes down, shape applied to both stages)  
2 = LCG (Linear Congruential Generator = pseudorandom noise) (experimental)  
3 = Splash (random noise applied to ASL cycle time = splashy synth)  

## Shapes  
Select the shape of the synth model  
CV Shapes listed in Monome Crow [documentation](https://monome.org/docs/crow/reference/#shaping-cv)  
[Easing functions](https://easings.net/) define how to walk point to point  
1 = linear  
2 = sine  
3 = logarithmic  
4 = exponential  
5 = now  
6 = wait  
7 = over  
8 = under  
9 = rebound  

# Example Kick and Snare Pattern
Connect CV output 4 on Teletype to Crow input 1.  
Use the Param knob on Teletype to set Crow input 1 voltage 0-10V. Alternatively, you can use any 0-10V voltage source. 
```
M: 
CV 4 PARAM
EV 2: $ 1
EV 4: $ 2

1:
CROW.C3 1 V -2 V 10

2: 
CROW.C3 2 V 4 V 6

LIVE INPUT: 
// Set M to your favorite tempo
M 172

// Set Channel 1 to sine wave kick drum
// 1 set model, 2 sine shape, 1 oscillator model, 1 channel
CROW.C1 1211

// Adjust Kick drum 
// ENV cycle time (111) ENV pitch depth (151)
// Use PARAM knob to set the value
CROW.C1 111
CROW.C1 151

// Change Snare drum to LCG
// 1 set model, 1 linear shape, 2 LGG model, 2 channel
CROW.C1 1122

// Adjust Snare drum decay time and pitch envelope of Channel 2 using PARAM knob
CROW.C1 112
CROW.C1 152
```

Continue adding more voices, adjusting parameters, modulating sounds, sequencing drum patterns

# Possible Development Ideas
- Multiple (3 or 4) LCG synth models causes script to crash. An "event queue full!" error appears when using 4 LCG models at the same time.
- Same ENV controls cycle time and pitch depth, want to make two separate ENV for cycle time and pitch depth
- Add presets, get/set presets, sequence through presets, possibly using sequins table in Crow 
- Better code documentation, clean up variable names, comments, organization
- Remapping mod parameter ranges from 0 - 10V for easier / faster parameter tuning
