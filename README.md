# drumcrow
This script turns crow into a 4-channel drum machine driven with monome teletype. 

# Teletype Commands
## CROW.C1 X
X = (mod source, mod parameter, channel)  
3 digits = maps CV at Crow input 1 to a parameter (152 = 1 envelope, 5 depth, 2 channel)  
4 digits = changes synth model of a channel (1023 = 1 command set, 02 select model, 3 channel)  

## CROW.C2 X Y
X = 3 digit number only (mod source, mod parameter, channel)  
Y = teletype number  
Directly sets the parameter at X to the value of Y  

## CROW.C3 X Y Z
X = Channel (1 - 4)  
Y = Pitch (teletype number −32768 and 32767)  
Z = Volume (teletype number)  
Trigger the envelope at channel X, with pitch Y, with volume Z  

# Synth Parameters
## Synth Model
1 = Variable Saw  
2 = Square (Pulse Width Modulation)  
3 = LCG (Linear Congruential Generator = pseudorandom noise) (experimental)  
4 = Splash (random noise applied to ASL cycle time = splashy synth)  

## Mod Source 
1 = ENV (envelope)  
2 = LFO  

## Mod Parameter
1 = Frequency  
2 = Symmetry (attack : decay)  
3 = Curvature  
4 = Pulse Width (timbre)  
5 = Depth (amplitude)  

## Channel
1 = Crow Output 1  
2 = Crow Output 2  
3 = Crow Output 3  
4 = Crow Output 4  

# Example Kick Snare Pattern
```
M: 
CV 4 PARAM
EV 2: $ 1
EV 4: $ 1

1:
CROW.C3 1 V -2 V 10

2: 
CROW.C3 2 V 4 V 6

LIVE INPUT: 
Adjust Kick drum using these commands ENV DECAY TIME (111) ENV PITCH DEPTH (151)
CROW.C1 111
CROW.C1 151
Change Snare drum to LCG using these commands CHANGE SYNTH MODEL (1032)
CROW.C1 1032
Adjust Snare drum decay time and pitch envelope by selecting Channel 2
CROW.C1 112
```

Continue adding more voices, adjusting parameters, modulating sounds, sequencing drum patterns

# Possible Development Ideas
- Multiple (3 or 4) LCG synth models causes script to crash. An "event queue full!" error appears when using 4 LCG models at the same time.
- Same ENV is tied to amplitude and to pitch decay, want to make two separate ENV for pitch and decay
- Experiment with different synth models
- Do something with crow input 2
- Add presets, get/set presets, sequence through presets, possibly using sequins table in Crow 
- Better code documentation, clean up variable names, comments, organization
- Remapping mod parameter ranges from 0 - 10V for easier / faster parameter tuning
