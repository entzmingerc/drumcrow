# drumcrow 
![alt text](https://github.com/entzmingerc/drumcrow/blob/main/drumcrow%20discord%20emote.png?raw=true)  
This script turns monome crow into a 4-channel drum machine synth driven with monome teletype or druid.  

**Demos**  
Drumcrow sound compilation [here](https://soundcloud.com/user-123356992/drumcrow-demo-sounds)  
Originally adapted from License's Flash Crash performance [here](https://www.youtube.com/watch?v=SYfeBtJjQ-M)  
postsolarpunk Flash Crash performance [here](https://www.youtube.com/watch?v=_EKpT1tO02o)  
playing around [here](https://www.youtube.com/watch?v=W48sP1b27rA)

# ABSTRACT 
Turns crow into a 4 oscillator drum machine / synth  
4 outputs (voices)  
6 oscillator models  
3 modulation sources (cycle time, attack/decay shape, curvature, retriggering) per voice  
1 trigger and harmonic sequencer per voice  
Frequency, amplitude, pulse width, bitcrush control  
Able to set relationships between parameter values of multiple voices  

Upload this script to crow using druid. Connect crow to teletype using i2c connection. Patch a constant voltage with a range 0 - 10V into crow input 1. Use teletype to do this or something else. In teletype, in the M script type `CV 4 PRM` to set CV 4 to the parameter knob. Patch CV 4 to crow's input 1. Finally, patch each crow output to a mixer so you can hear the audio.  

`CROW.C1 X` Select a parameter. The voltage at crow input 1 sets the parameter value. (0 - 10V)  
`CROW.C2 X Y` Set parameter X to value Y  
`CROW.C3 X Y Z` Trigger envelopes on channel X with note Y and amplitude Z  

# MORE ABSTRACT
The [panharmonicorvus](https://en.wikipedia.org/wiki/Corvus) is a widely distributed genus of small-sized [panharmonicons](https://en.wikipedia.org/wiki/Panharmonicon) in the family [orchestrion](https://en.wikipedia.org/wiki/Orchestrion). It includes species commonly known as panharmonicrows, crrrazow and sharrow. The species commonly encountered in [Chembayou](https://cci.dev/pr/02) are the [drumcrow](https://github.com/entzmingerc/drumcrow/) named chiefly on the basis of their distinctive percussive sounding calls. The 45 or so members of this genus occur on all temperate continents. The collective name for a group of drumcrows is a "[chorus](https://en.wikipedia.org/wiki/Choir)". Recent research has found some drumcrow species capable of not only [tool use](https://en.wikipedia.org/wiki/Low-frequency_oscillation) but also [tool construction](https://monome.org/docs/crow/reference/). Drumcrows are now considered to be among the world's most sonically efficient animals with a [Kolmogorov complexity](https://en.wikipedia.org/wiki/Kolmogorov_complexity) equal to that of [bytebeat cyberbees](https://llllllll.co/t/bytebeats-a-beginner-s-guide/16491).

# Example Kick and Snare Pattern
```
// Connect CV 4 to crow input 1, use PARAM knob to set values on crow (0 - 10V input)
M: 
CV 4 PARAM
EVERY 2: SCRIPT 1
EVERY 4: SCRIPT 2

1:
CROW.C3 1 V -1 V 10	// Trig Ch1 (1) Note (V -1) Amplitude (V 10)

2: 
CROW.C3 2 V 4 V 6	// Trig Ch2 (2) Note (V 4) Amplitude (V 6) = 2 V 4 V 6

LIVE INPUT:	// Let's make Ch1 a kick and Ch2 a snare, adjust PARAM knob to set values
M 172		// your new favorite tempo
CROW.C1 2211	// Set Model (2) Shape sine (2) Model var_saw (1) Channel 1 (1)
CROW.C1 261	// Freq ENV (2) Decay time (6) Channel 1 (1)
CROW.C1 211	// Freq ENV (2) Pitch mod depth (1) Channel 1 (1)

CROW.C1 2132	// Set Model (2) Shape linear (1) Model noise (3) Ch2 (2)
CROW.C1 142	// Oscillator (1) PW2 (4) Channel 2 (2) = 142, BRING THE NOISE
CROW.C1 262	// Pitch ENV (2) Decay time (6) Channel 2 (2) = 262, SHORTEN the noise
CROW.C1 212	// Pitch ENV (2) Pitch mod depth (1) Channel 2 (2), pitch the noise?
...
```  
Continue adding more voices, adjusting parameters, modulating sounds, sequencing drum patterns  

![alt text](https://github.com/entzmingerc/drumcrow/blob/main/drumcrow%20parameter%20matrix.PNG?raw=true)

# Teletype Commands
Channel = 0 select all channels  
Channel = 1-4 select a channel  
(5, 6, 7, 8, 9 wraps to 0, 1, 2, 3, 4 respectively)  

Note, Amplitude, Pulse Width, and PW2 act differently depending on the oscillator model used. For example, both Note and Pulse Width control the resulting frequency of the bytebeat inspired oscillator. The modulation sources are mostly the same with small difference. The CROW.C3 command sets Note (11X) and Amplitude (12X) of the oscillator, then triggers the envelopes. The AMP ENV (4) is for amplitude control. The FREQ ENV (2) is for frequency modulation. However, all 3 mod sources can affect amplitude or frequency of the oscillator if desired. All 3 mod sources can be set to cycle infinitely, but only AMP ENV (4) and FREQ ENV (2) will be retriggered if CROW.C3 is called. The LFO (3) is not retriggered when CROW.C3 is called.  

## CROW.C1 X  
Selects a parameter. Voltage at crow input 1 sets the parameter value. These are the available sliders / knobs / buttons.  
| TT Command | DIGIT 3 | DIGIT 2 | DIGIT 1 | Description |
| --- | --- | --- | --- | --- |
| `0` | ~ | ~ |  ~ | Deselect a parameter, maps input voltage to nothing <br> Any unused number deselects a parameter |
| `11X` | 1 Osc | 1 Note | 0-4 Channel | Sets oscillator frequency of a channel <br> Minimum set to 1Hz but can be set lower for LFOs <br> 0 <= V <= 10 :: 1Hz ... 20kHz|
| `12X` | 1 Osc | 2 Amplitude | 0-4 Channel | Sets oscillator amplitude of a channel <br> Can be overdriven using modulation sources |
| `13X` | 1 Osc | 3 Pulse Width | 0-4 Channel | Sets pulse width of a channel |
| `14X` | 1 Osc | 4 PW2 | 0-4 Channel | Sets PW2 which is an optional extra parameter <br> Changes depending on the model |
| `15X` | 1 Osc | 5 Bitcrush Amount | 0-4 Channel | Sets a quantizer v/oct for a channel, bitcrush distortion <br> 0 <= V <= 5 :: OFF <br> 5 < V <= 10 :: Temperament at 2 and V/Oct from 1 to 20 |
| `16X` | 1 Osc | 6 Caw to Fr4 | 0-4 Channel | Scales amount CAW sequencer modulates mod 4 cycle time (46X) <br> 0 <= V <= 5 :: OFF <br> 5 < V <= 10 :: 0 ... 2 |
| `17X` | 1 Osc | 7 Caw to Fr4 | 0-4 Channel | Scales amount CAW sequencer modulates mod 3 cycle time (36X) <br> 0 <= V <= 5 :: OFF <br> 5 < V <= 10 :: 0 ... 2 |
| `18X` | 1 Osc | 8 Caw to Note | 0-4 Channel | Sets if CAW sequences Note <br> 0 <= V <= 5 :: OFF <br> 5 < V <= 10 :: ON |
| `19X` | 1 Osc | 9 Splash | 0-4 Channel | Sets amount of noise applied to Note <br> 0 <= V <= 5 :: OFF <br> 5 < V <= 10 :: 0 ... 5 |
| `21X` | 2 FREQ ENV | 1 Mod Depth NOTE | 0-4 Channel | ENV mod depth of frequency <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `22X` | 2 FREQ ENV | 2 Mod Depth AMP | 0-4 Channel | ENV mod depth of amplitude <br> 0 <= V <= 10 :: -3.3 ... 0 ... +3.3|
| `23X` | 2 FREQ ENV | 3 Mod Depth PW | 0-4 Channel | ENV mod depth of pulse width <br> 0 <= V <= 10 :: -2 ... 0 ... +2|
| `24X` | 2 FREQ ENV | 4 Mod Depth PW2 | 0-4 Channel | ENV mod depth of PW2 (misc) <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `25X` | 2 FREQ ENV | 5 Mod Depth BIT | 0-4 Channel | ENV mod depth of bitcrush amount <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `26X` | 2 FREQ ENV | 6 Cycle Time | 0-4 Channel | Set ENV cycle time <br> 0 <= V <= 9.75 :: 0.006 sec - 100 sec <br> 9.75 < V <= 10 :: 2<sup>32</sup> seconds <br> [billions and billions](https://en.wikipedia.org/wiki/Carl_Sagan#%22Billions_and_billions%22)|
| `27X` | 2 FREQ ENV | 7 Attack / Decay | 0-4 Channel | Set ENV attack / decay ratio <br> V = 0.0 :: Attack 0% Decay 100% Quieter <br> V = 2.5 :: Attack 0% Decay 100% <br> V = 5.0 :: Attack 50% Decay 50% <br> V = 7.5 :: Attack 100% Decay 0% <br> V = 10 :: Attack 100% Decay 0% Quieter Infinite Release|
| `28X` | 2 FREQ ENV | 8 Curvature | 0-4 Channel | Set ENV curvature <br> 0 <= V <= 10 :: 2<sup>-5</sup> ... 0 ... 2<sup>5</sup> <br> square ... linear ... logarithmic|
| `29X` | 2 FREQ ENV | 9 Looping | 0-4 Channel | V <= 0 :: ENV looping OFF (default) <br> V > 0 :: ENV looping ON | 
| `31X` | 3 LFO | 1 Mod Depth NOTE | 0-4 Channel | LFO mod depth of frequency <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `32X` | 3 LFO | 2 Mod Depth AMP | 0-4 Channel | LFO mod depth of amplitude <br> 0 <= V <= 10 :: -3.3 ... 0 ... +3.3|
| `33X` | 3 LFO | 3 Mod Depth PW | 0-4 Channel | LFO mod depth of pulse width <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `34X` | 3 LFO | 4 Mod Depth PW2 | 0-4 Channel | LFO mod depth of PW2 (misc) <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `35X` | 3 LFO | 5 Mod Depth BIT | 0-4 Channel | LFO mod depth of bitcrush amount <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `36X` | 3 LFO | 6 Cycle Time | 0-4 Channel | Set LFO cycle time <br> 0.25 <= V <= 10 :: 1 Hz - 1024 Hz :: 724 sec - 0.001 sec <br> 0 <= V <= 0.25 :: 2<sup>32</sup> seconds <br> Fastest update time is 0.002sec or 250Hz, aliasing above this|
| `37X` | 3 LFO | 7 Attack / Decay | 0-4 Channel | Set LFO attack / decay ratio <br> V = 0.0 :: Attack 0% Decay 100% Quieter <br> V = 2.5 :: Attack 0% Decay 100% <br> V = 5.0 :: Attack 50% Decay 50% <br> V = 7.5 :: Attack 100% Decay 0% <br> V = 10 :: Attack 100% Decay 0% Quieter Infinite Release|
| `38X` | 3 LFO | 8 Curvature | 0-4 Channel | Set LFO curvature <br> 0 <= V <= 10 :: 2<sup>-5</sup> ... 0 ... 2<sup>5</sup> <br> square ... linear ... logarithmic|
| `39X` | 3 LFO | 9 Looping | 0-4 Channel | LFO does not reset phase when voice is triggered <br> V <= 1 :: LFO looping OFF <br> V > 1 :: LFO looping ON (default)| 
| `41X` | 4 AMP ENV | 1 Mod Depth NOTE | 0-4 Channel | ENV mod depth of frequency <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `42X` | 4 AMP ENV | 2 Mod Depth AMP | 0-4 Channel | ENV mod depth of amplitude <br> 0 <= V <= 10 :: -3.3 ... 0 ... +3.3|
| `43X` | 4 AMP ENV | 3 Mod Depth PW | 0-4 Channel | ENV mod depth of pulse width <br> 0 <= V <= 10 :: -2 ... 0 ... +2|
| `44X` | 4 AMP ENV | 4 Mod Depth PW2 | 0-4 Channel | ENV mod depth of PW2 (misc) <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `45X` | 4 AMP ENV | 5 Mod Depth BIT | 0-4 Channel | ENV mod depth of bitcrush amount <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `46X` | 4 AMP ENV | 6 Cycle Time | 0-4 Channel | Set ENV cycle time <br> 0 <= V <= 9.75 :: 0.006 sec - 100 sec <br> 9.75 < V <= 10 :: 2<sup>32</sup> seconds|
| `47X` | 4 AMP ENV | 7 Attack / Decay | 0-4 Channel | Set envelope attack / decay ratio <br> V = 0.0 :: Attack 0% Decay 100% Quieter <br> V = 2.5 :: Attack 0% Decay 100% <br> V = 5.0 :: Attack 50% Decay 50% <br> V = 7.5 :: Attack 100% Decay 0% <br> V = 10 :: Attack 100% Decay 0% Quieter Infinite Release|
| `48X` | 4 AMP ENV | 8 Curvature | 0-4 Channel | Set ENV curvature <br> 0 <= V <= 10 :: 2<sup>-5</sup> ... 0 ... 2<sup>5</sup> <br> square ... linear ... logarithmic|
| `49X` | 4 AMP ENV | 9 Looping | 0-4 Channel | V <= 0 :: ENV looping OFF (default) <br> V > 0 :: ENV looping ON | 
| `50X` | 5 TRIG SEQ | 0 ON/OFF | 0-4 Channel | Turn ON/OFF Trig Sequencer for channel |
| `51X` | 5 TRIG SEQ | 1 Length A | 0-4 Channel | Set length of time to wait after a trigger in A <br> 0 <= V <= 10 :: 0, 1/10, ..., 1/2, 1, 2, ..., 10 Beats |
| `52X` | 5 TRIG SEQ | 2 Repeats A | 0-4 Channel | Set number of times to "trigger then wait length A" before moving to B <br> 0 <= V <= 10 :: 10, ..., 2, 1, 0, 1, 2, ..., 10 Repeats |
| `53X` | 5 TRIG SEQ | 3 Length B | 0-4 Channel | Set length of time to wait after a trigger in B <br> 0 <= V <= 10 :: 0, 1/10, ..., 1/2, 1/1, 1, 2, ..., 10 Beats |
| `54X` | 5 TRIG SEQ | 4 Repeats B | 0-4 Channel | Set number of times to "trigger then wait length B" before moving to A <br> 0 <= V <= 10 :: 10, ..., 2, 1, 0, 1, 2, ..., 10 Repeats |
| `55X` | 5 TRIG SEQ | 5 Flaps | 0-4 Channel | Set number of steps to advance CAW sequence <br> 0 <= V <= 10 :: 1 (default), 2, 3, 4 |
| `56X` | 5 TRIG SEQ | 5 CAW1 | 0-4 Channel | Select Harmonic for Step 1 <br> 0 <= V <= 10 :: 0, 1/10, ..., 1/2, 1, 2, ..., 10 |
| `57X` | 5 TRIG SEQ | 5 CAW2 | 0-4 Channel | Select Harmonic for Step 2 <br> 0 <= V <= 10 :: 0, 1/10, ..., 1/2, 1, 2, ..., 10 |
| `58X` | 5 TRIG SEQ | 5 CAW3 | 0-4 Channel | Select Harmonic for Step 3 <br> 0 <= V <= 10 :: 0, 1/10, ..., 1/2, 1, 2, ..., 10 |
| `59X` | 5 TRIG SEQ | 5 CAW4 | 0-4 Channel | Select Harmonic for Step 4 <br> 0 <= V <= 10 :: 0, 1/10, ..., 1/2, 1, 2, ..., 10 |
| `81X` | 8 | 1 | any number | Set global tempo of all sequencers <br> 0 <= V <= 10 :: 10 BPM ... 2010 BPM| 
| `82X` | 8 | 2 | any number | Set global update speed of all voices <br> 0 <= V <= 10 :: 0.002 sec ... 0.1 sec <br> Defualt 0.005, shorter speeds may cause CPU overload, higher speeds result in stair-step modulation| 
| `85X` | 8 | 2 | 0-4 Channel | Reset position of trigger sequencer, keeps length and repeat values the same | 
| `86X` | 8 | 6 | 0-4 Channel | Set a channel to its initial value [86 Term](https://en.wikipedia.org/wiki/86_(term))| 
| `1XYZ` | 1 SET RATIO | Parameter <br> X: 1-5 Digit 3 <br> Y: 1-9 Digit 2 | 0, 2-4 Channel | Set a channel's parameter value to be a scaled value of channel 1's parameter value <br> 0 <= V <= 10 :: 0, 1/10, 1/9, ..., 1/2, 1, 2, ..., 9, 10 <br> A value of 0 disables ratio, otherwise the ratio value overrules any other attempt to set value|
| `2XYZ` | 2 SET MODEL | 1-9 Shape<br>1-6 Model | 0-4 Channel | Set model on a channel with a [shape](https://monome.org/docs/crow/reference/#shaping-cv) <br> Default :: Model = 1 var_saw, Shape = 1 linear|

## CROW.C2 X Y
| TT Command | Parameter | Value | Description |
| --- | --- | --- | --- |
| `CROW.C2 X Y` | Select Parameter for X <br> CROW.C1 see above | V 0 ... V 10 <br> TT Value | Set a channel parameter to a value directly <br> Can be used to set ratios directly (1XYZ) <br> Values set with CROW.C1 takes higher priority than CROW.C2|

Many parameters can be set to zero by using V 5. (The 0V to 10V input is scaled to a -10 to +10 value internally). Most ratio values can be set to zero by setting input voltage to 0V (or V -10 from TT). Use the teletype OP `VV` to set a parameter to a decimal value. Some parameters are sensitive to decimal changes. If CROW.C1 is selecting the same parameter CROW.C2 is trying to set, CROW.C1 takes higher priority than CROW.C2. (Technically speaking, CROW.C2 will set the parameter, but it will then be immediately overwritten by the C1 value in the next update loop, CAW).  

### C2 CAW CAW CAW
Try doing everything with C2 instead of C1 and the PARAM knob  
Try deselecting a parameter before setting it using C2: `CROW.C1 0`  
Try setting things to zero! This sets LFO frequency mod depth to zero on channel 1: `CROW.C2 311 V 5`  
Try setting amplitude to 0 (mute / turn off): `CROW.C2 123 V 5`  
Try setting envelope decay time to a random value from teletype: `CROW.C2 362 RRAND V 0 V 5`  
Try setting the update speed to decimal values near minimum: `CROW.C2 821 VV 120`  
Try exploring decimal PW2 values with the ASLsine and Noise models: `CROW.C2 141 VV 510`  
Try sequencing Ch1 note with teletype patterns: `CROW.C2 111 PN.NEXT 0`  
....while triggering the channel with another pattern: `CROW.C3 1 N PN.NEXT 1 V 5`  
........while drumcrow sequencer is ON `CROW.C1 501`  
............while randomly updating drumcrow sequencer values `CROW.C2 + 560 RAND 3 RRAND V 4 V 7`  
................while every 5 we set decay envelope to param for fun `EV 5: CROW.C2 461 PARAM`  
....................(I haven't actually tested this, CAW)  

## CROW.C3 X Y Z
| TT Command | X | Y | Z | Description |
| --- | --- | --- | --- | --- |
| `CROW.C3 X Y Z` | 1-4 Channel | V -10 ... V 10 <br> Note <br> TT Value | V -10 ... V 10 <br> Amplitude <br> TT Value | Set note, set amplitude, then retrigger envelopes <br> Only Trigger AMP ENV and FREQ ENV if passed attack stage <br> Note typically V -2 ... V 8 <br> Amplitude usually V 0 ... V 10|

CROW.C3 X Y Z = (channel) (note) (amplitude)  
Set note. Set amplitude. Trigger envelopes. Sequence notes using TT patterns, random values, and so on. Some synth models change tone depending on note. Mix oscillators using volume parameter, sequence velocity, set to 0 to mute. Set all Amplitude modulation to zero as well if volume is still heard.  

## Models
1. var_saw(amp, cyc, pw, shape) (Default)  
Up to a voltage, down to a negative voltage. Triangle shape with pulse width control. Time to travel between each voltage determined by cyc. Use shape to select 1 triangle, 2 sine, 5 square, or select any shape 1-9 to hear different tones.  
```
loop { to(  dyn{amp=2}, dyn{cyc=1/440} * dyn{pw=1/2}, shape), to(0-dyn{amp=2}, dyn{cyc=1/440} * (1-dyn{pw=1/2}), shape) } 
```
2. bytebeat(amp, cyc, pw, shape)  
Output voltage is stepped by PW each loop and wrapped between -20 ... 20. The time to complete each voltage step is determined by cyc. 
```
-- dyn.pw = pw * pw2
loop { to(dyn{x=1}:step(dyn{pw=1}):wrap(-20,20) * dyn{amp=2}, dyn{cyc=1}, shape) }
```
3. noise(amp, cyc, pw, pw2, shape)  
Linear Congruential Generator is a pseudorandom number generator using the equation voltage(n+1) = (pw2 * voltage(n) + pw) mod 10. PW2 can be used to sweep through a large range of noisy sounds. PW2 is sensitive to decimal values as well, explore sweet spots. Note affects the sounds as well, higher pitches for higher frequency noise. Use short amplitude envelope cycle times for high hats and snares.  
```
-- dyn.pw = pw, dyn.pw2 = pw2
loop { to(dyn{x=1}:mul(dyn{pw2=1}):step(dyn{pw=1}):wrap(-10,10) * dyn{amp=2}, dyn{cyc=1}/2, shape) } 
```
4. FMstep(amp, cyc, pw, pw2, shape)  
This expands the var_saw model to multiply cyc by a dynamic variable x that sweeps between 1 and 2 at a speed set by PW2. Low PW values means a lower frequency is multiplied to the Note freq.  
```
-- dyn.pw = pw, dyn.pw2 = pw2 / 50
loop {to(  dyn{amp=2}, dyn{x=1}:step(dyn{pw2=1}):wrap(1,2) * dyn{cyc=1} * dyn{pw=1}, shape),
			to(0-dyn{amp=2}, dyn{x=1} * dyn{cyc=1} * (1-dyn{pw=1}), shape) }
```
5. ASLsine(amp, cyc, pw, shape)  
This is a root-product sine wave approximation y = x + 0.101321(x)^3. The var_saw model can select two voltage points to move between, but ASL can't directly step through a waveshape unless we were to make 100 ASL stages and step through a waveshape manually. Instead, we can loop one ASL stage, step x by PW each loop, wrap it between -pi and +pi, and now each voltage step roughly traces out a sine wave. Sounds cool. Time it takes between each voltage step is determined by cyc.  
```
-- dyn.pw = pw * pw2
loop { to((dyn{x=0}:step(dyn{pw=0.314}):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, shape) }
```
6. ASLharmonic(amp, cyc, pw, shape)  
Same as ASLsine but we add a mul(-1) to x so that its polarity is negated each loop. This gives a frequency from the time it takes to step through the sine wave approximation and the frequency from the x variable flipping polarity back and forth. Slightly more chaotic with PW2.  
```
-- dyn.pw = pw * pw2
loop { to((dyn{x=0}:step(dyn{pw=1}):mul(-1):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, shape) }
```

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
`CROW.C1 1XYZ` Set ratio (1) sets a parameter (XY) on channel (Z) equal to a scaled value of Ch1 parameter. Select a multiplier using crow input 1 voltage. Multipliers are quantized to integer scalings and fractions (see below). `CROW.C1 1462` turn up input voltage to V 6 ish, now Ch2's amplitude envelope cycle time (46) is set to Ch1's amplitude envelope cycle time x 2. When Ch1's value is changed, Ch2's value will be updated as well. All parameters in blue in the drumcrow parameter matrix (see figure further above) can have ratios enabled between Ch1 and Ch2,3,4. If a ratio is on, then that parameter will ignore any attempts to set its value. A ratio is off if the ratio is set to 0. A ratio is on if a ratio value is not zero. You can initialize a channel's ratios with `CROW.C1 186X`. You can set multiple channel's ratios using Ch = 0.  

ratio 0 <= V <= 10 :: 0, 1/10, 1/9, ..., 1/2, 1, 2, ..., 9, 10  
0 - disables ratio for the parameter  

### RATIOS CAW CAW CAW  
Try setting LFO cycle ratio (36) for all channels, then vary Ch1: `CROW.C1 1360` `CROW.C1 361`  
Try setting LFO Loop ratio (39) negative for Ch2 and positive for Ch3. Turning on Ch1 will turn on Ch2 and turn on Ch3.  
Try setting Ch2's Note ratio: `CROW.C1 1112`  
Set Ratio (1) Note (11) on Ch2 (2) to Ch1 as always: `CROW.C1 1112`  
....Use CROW.C3 to sequence Ch1 Note using teletype and listen to Ch2 following along: `CROW.C3 1 N PN.NEXT 0 V 5`  
........Turn on Ch1 and Ch2 trig sequencers (50X) and hear the rhythms: `CROW.C1 501` `CROW.C1 502`  
............Set Ratio (1) LenA parameter (51) on Ch2 (2), then vary LenA (51) on Ch1 (1): `CROW.C1 1512` `CROW.C1 511`  
................Set Ratio (1) Flaps (55) on Ch2 (2), then vary Flaps (55) on Ch1 (1): `CROW.C1 1552` `CROW.C1 551`  

## Trigger Sequencer
drumcrow can be triggered externally if the trigger sequencer is on or off. `CROW.C1 50X` turns on / turns off the trigger sequencer for a channel. `CROW.C1 81X` can be used to set the main tempo on crow for all channels 10 BPM to 2010 BPM (X is any number, 81X). When a trigger sequencer is turned on, it will trigger the channel immediately with the current setting of note (11X) and amplitude (12X). `CROW.C3 X Y Z` can quickly set the note and amplitude if desired.  

Trigger sequencers start in stage A. At each stage, a trigger will occur then the clock will wait a certain amount of time. After the time is up, it will trigger again, then wait that length of time. `51X` sets how long of a time to wait and `52X` sets how many times to repeat this action before moving on to stage B. Stage B is exactly the same as stage A. `53X` sets how long of a time to wait and `54X` sets how many times to repeat this action before moving on to stage A.  
```
1 : A___A___A___B_B_A___A___A___B_B_A___A___A___B_B_A___A___A___B_B_  
2 : A__A__A__B_____A__A__A__B_____A__A__A__B_____A__A__A__B_____A__A  
3 : AAAAB___AAAAB___AAAAB___AAAAB___AAAAB___AAAAB___AAAAB___AAAAB___  
4 : A___B___A___B___A___B___A___B___A___B___A___B___A___B___A___B___  
```
-Different trigger sequencer per channel. Each A or B represents a trigger.  

The length of time between triggers is synced to clock divisions/multiplications of the main tempo set with `81X`. All channels are synced to the same main tempo. Varying rhythms can be created between channels with a small changes to length and repeats. Setting a length to 0 <= V <= 5 will result in a shorter beats whereas 5 < V <= 10 results in much widers spacing between triggers. For ratchet effects, set length to a smaller value and set the number of repeats very high. For a constant rhythm, set length of A using `51X` then immediately change to `53X` without adjusting the input voltage, both will be set to the same clock division. For phasing drum patterns, try setting the main tempo to a high value, the length and repeats of A to a high value, and the number of repeats of B to 1. A small value for length of B could then be used to slightly offset one channel from another. Notice how in the visual example above, sequence 2 phases slowly to the left when compared to sequence 1. 

```
LenA 1 RepA 1 LenB 2   RepB 1 : A_B__A_B__A_B__A_B__
LenA 2 RepA 1 LenB 2   RepB 1 : A__B__A__B__A__B__A__B__
LenA 2 RepA 1 LenB 2   RepB 2 : A__B__B__A__B__B__A__B__B__A__B__B__
LenA 2 RepA 1 LenB 1   RepB 2 : A__B_B_A__B_B_A__B_B_A__B_B_
LenA 3 RepA 1 LenB 1   RepB 2 : A___B_B_A___B_B_A___B_B_A___B_B_
LenA 3 RepA 1 LenB 1/2 RepB 2 : A___BBA___BBA___BBA___BB
LenA 3 RepA 1 LenB 1/2 RepB 5 : A___BBBBBA___BBBBBA___BBBBBA___BBBBB
```
-4 cycles of various trigger patterns. Each A or B represents a trigger.  

### Harmonic Sequencer
Parameters `56X, 57X, 58X, 59X` set the frequency multiplier for each step 1, 2, 3, 4. Default values for each step is {1, 1, 1, 1} but each step can be set to 0, 1/10, 1/9, ... 1/2, 1, 2, ... 9, 10. For example, if channel 1 note is set to 400Hz and the multiplier is set to 3 then you will hear 1200Hz. This is the 3rd harmonic of the fundamental frequency 400Hz. This is why it's called a harmonic sequencer, [we sequence ratios](https://www.youtube.com/watch?v=yA9uguVcd6o) instead of absolute values. Harmonics are integer values, subharmonics are fractional multipliers. Each trigger we step forward to the next ratio. Sequencing the note value is ON by default, but it can be turned off using `18X`. The sequencer can be mapped to AMP ENV cycle time `46X` using the parameter `16X` which sets the mod depth (0 ... 2) of the sequencer value. The sequencer can be mapped to LFO cycle time `36X` using the parameter `17X` which sets the mod depth (0 ... 2) of the sequencer value.  

Flaps `55X` sets how many steps forward we step each trigger {1, 2, 3, 4}. Results in 4 directions  
Flaps = 1, forwards  
Flaps = 2, toggle between current step and two steps forward  
Flaps = 3, backwards  
Flaps = 4, no change  

### TRIG SEQ CAW CAW CAW
Try using ratios to manipulate harmonics across all channels simultaneously.  
Try sequencing AMP ENV cycle time for open / closed high hat sounds.  
Try turning on and off trigger sequencers at various rates to step patterns irregularly.  
Try using various ratio values with Flaps to change all channels' directions simultaneously.  
Try making noise by cranking tempo up to 2000 BPM and using subharmonic divisions and trigger length divisions.  
Try sequencing the LFO, make dubstep wubs with LFO frequency mod depth `31X` and PW mod depth `34X`.  
Try CAW CAW CAW.  

# Future Development
- port to norns
