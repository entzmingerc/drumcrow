# drumcrow
This script turns Crow into a 4-channel drum machine driven with Monome Teletype.  

**Demos**  
Originally adapted from License's Flash Crash performance [here](https://www.youtube.com/watch?v=SYfeBtJjQ-M)  
postsolarpunk Flash Crash performance [here](https://www.youtube.com/watch?v=_EKpT1tO02o)  
playing around [here](https://www.youtube.com/watch?v=W48sP1b27rA)

# Teletype Commands
## CROW.C1 X
### 2 digits 

| TT Command | DIGIT 2 | DIGIT 1 | Description |
| --- | --- | --- | --- |
| `CROW.C1 0` | ~ | ~ | Deselect a parameter |
| `CROW.C1 11` <br> `CROW.C1 12` <br> `CROW.C1 13` <br> `CROW.C1 14` | PW | Channel | Sets the pulse width (PW) for a channel |
| `CROW.C1 21` <br> `CROW.C1 22` <br> `CROW.C1 23` <br> `CROW.C1 24` | PW2 | Channel | Sets a second pulse width (PW2) for a channel, varying purposes |
| `CROW.C1 31` <br> `CROW.C1 32` <br> `CROW.C1 33` <br> `CROW.C1 34` | BIT | Channel | Sets a quantizer v/oct (BIT) for a channel <br> V <= 5 : OFF <br> 5 < V <= 10 Temperament at 2 and V/Oct Scaling from 0 to 20 |

X = (1, channel)  
Sets pulse width of a channel  
`CROW.C1 14` sets input 1 value to pulse width on channel 4 (14, 1 pulse width, 4 channel)  
### 3 digits  
X = (mod source, mod parameter, channel)  
Sets the mod parameter value to the CV value at Crow input 1  
`CROW.C1 252` sets input 1 value to LFO depth on channel 2 (2 LFO, 5 depth, 2 channel)  
### 4 digits  
X = (command, shape, model, channel) 
Changes synth model of a channel  
`CROW.C1 1513` sets synth model on channel 3 to model 1 with shape 5 (1513, 1 command set, 5 shape, 1 model, 3 channel)  

## CROW.C2 X Y
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
