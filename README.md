# drumcrow
This script turns Crow into a 4-channel drum machine driven with Monome Teletype.  

**Demos**  
Originally adapted from License's Flash Crash performance [here](https://www.youtube.com/watch?v=SYfeBtJjQ-M)  
postsolarpunk Flash Crash performance [here](https://www.youtube.com/watch?v=_EKpT1tO02o)  
playing around [here](https://www.youtube.com/watch?v=W48sP1b27rA)

# Teletype Commands
## CROW.C1 X
X = (mod source, mod parameter, channel)  
3 digits = sets the mod parameter value to the CV value at Crow input 1 (152 = 1 envelope, 5 depth, 2 channel)  
4 digits = changes synth model of a channel (1023 = 1 command set, 02 select model, 3 channel)  

## CROW.C2 X Y
X = 3 digit number only (mod source, mod parameter, channel)  
Y = Teletype number  
Directly sets the parameter at X to the value of Y  
CROW.C1 has higher priority than CROW.C2. For example, if `CROW.C1 151` is currently selected and `CROW.C2 151 V 4` is sent, then the value of 151 is set to Crow input 1 (CROW.C1) and ignores CROW.C2.

## CROW.C3 X Y Z
X = Channel (1 - 4)  
Y = Pitch (Teletype number −32768 - +32767)  
Z = Volume (Teletype number)  
Trigger the envelope at channel X, with pitch Y, with volume Z  

# Synth Parameters
## Mod Sources 
1 = ENV (envelope)  
2 = LFO  

## Mod Parameters
1 = Frequency (ENV cycle time or LFO rate)
2 = Symmetry (attack : decay)  
3 = Curvature  
4 = Pulse Width (timbre)  
5 = Depth (pitch depth)  

## Channels
1 = Crow Output 1  
2 = Crow Output 2  
3 = Crow Output 3  
4 = Crow Output 4  

## Synth Models
1 = Variable Saw  
2 = Square (Pulse Width Modulation)  
3 = LCG (Linear Congruential Generator = pseudorandom noise) (experimental)  
4 = Splash (random noise applied to ASL cycle time = splashy synth)  

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
Set M to your favorite tempo
M 172
Adjust Kick drum by selecting ENV cycle time (111) ENV pitch depth (151) and using PARAM knob to set the value
CROW.C1 111
CROW.C1 151
Change Snare drum to LCG using these commands CHANGE SYNTH MODEL (1032)
CROW.C1 1032
Adjust Snare drum by selecting decay time and pitch envelope of Channel 2 this time then using PARAM knob to set the value
CROW.C1 112
CROW.C1 152
```

Continue adding more voices, adjusting parameters, modulating sounds, sequencing drum patterns

# Possible Development Ideas
- Multiple (3 or 4) LCG synth models causes script to crash. An "event queue full!" error appears when using 4 LCG models at the same time.
- Same ENV controls cycle time and pitch depth, want to make two separate ENV for cycle time and pitch depth
- Experiment with different synth models
- Do something with crow input 2
- Add presets, get/set presets, sequence through presets, possibly using sequins table in Crow 
- Better code documentation, clean up variable names, comments, organization
- Remapping mod parameter ranges from 0 - 10V for easier / faster parameter tuning
