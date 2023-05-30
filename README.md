# drumcrow 
![alt text](https://github.com/entzmingerc/drumcrow/blob/main/drumcrow%20discord%20emote.png?raw=true)  
This script turns monome crow into a 4-channel drum machine synth. Driven with monome teletype (TT) or druid (and hopefully norns soon).  

**Demos**  
drumcrow sounds compilation [here](https://soundcloud.com/user-123356992/drumcrow-demo-sounds)  
30 minute live coding improv [here](https://soundcloud.com/user-123356992/crow-live-jam-19)  
drumcrow v1.0 tutorial [here](https://www.youtube.com/watch?v=rrcj5uk-hhY)  
originally adapted from License's Flash Crash performance [here](https://www.youtube.com/watch?v=SYfeBtJjQ-M)  
postsolarpunk Flash Crash performance [here](https://www.youtube.com/watch?v=_EKpT1tO02o)  
playing around [here](https://www.youtube.com/watch?v=W48sP1b27rA)

# ABSTRACT 
Turns crow into a 4 oscillator drum machine / synth  
4 outputs (voices)  
7 oscillator models  
3 modulation sources: note env, lfo, amp env with cycle time, attack/decay, curvature, looping per voice  
1 trigger/harmonic sequencer per voice  
frequency, note, amplitude, pulse width, bitcrush, cycle rate, modulatable  
teletype, druid, and (soon) norns control

For a bird's eye view, see drumcrow parameter matrix below.  

## Requirements
crow  
(teletype recommended, not required)  

## Installation
Connect crow to teletype using i2c connection.  
Navigate to the folder with drumcrow.lua in it and open druid.  
Run or Upload this script to crow using druid: `u drumcrow.lua` wait 10 seconds.  
If you run into the error `not enough memory` `User script evaluation failed.` try using `^^clear` to delete the uploaded script in crow, turn off power to your crow, turn on power to your crow, then try `u drumcrow.lua` again.  
```
> u drumcrow.lua
uploading drumcrow.lua
User script updated.
Running: drumcrow
setup complete!
^^ready()
```
Patch a constant voltage with a range 0 - 10V into crow input 1.  
You could use teletype for this, in the M script type `CV 4 PARAM` to set CV 4 to the parameter knob. Patch CV 4 to crow's input 1.  
If you do not have teletype and/or way to send 0 - 10V to crow input 1, then you can use druid to operate drumcrow.  
Finally, patch each crow output to a mixer to hear the audio.  

# MORE ABSTRACT
The [panharmonicorvus](https://en.wikipedia.org/wiki/Corvus) is a widely distributed genus of small-sized [panharmonicons](https://en.wikipedia.org/wiki/Panharmonicon) in the family [orchestrion](https://en.wikipedia.org/wiki/Orchestrion). It includes species commonly known as panharmonicrows, crrrazow and sharrow. The species commonly encountered in [Chembayou](https://cci.dev/pr/02) are the [drumcrow](https://github.com/entzmingerc/drumcrow/) named chiefly on the basis of their distinctive percussive sounding calls. The 45 or so members of this genus occur on all temperate continents. The collective name for a group of drumcrows is a "[chorus](https://en.wikipedia.org/wiki/Choir)". Recent research has found some drumcrow species capable of not only [tool use](https://en.wikipedia.org/wiki/Low-frequency_oscillation) but also [tool construction](https://monome.org/docs/crow/reference/). Drumcrows are now considered to be among the world's most sonically efficient animals with a [Kolmogorov complexity](https://en.wikipedia.org/wiki/Kolmogorov_complexity) equal to that of [bytebeat cyberbees](https://llllllll.co/t/bytebeats-a-beginner-s-guide/16491).

# Example Kick and Snare Pattern
Follow along with this video tutorial [here](https://www.youtube.com/watch?v=rrcj5uk-hhY)  
```
// Let's make Ch1 a kick drum, Ch2 a snare, Ch3 a simple melody
// Connect CV 4 to crow input 1, use PARAM knob to set values on crow (0 - 10V input)
M: 
CV 4 PARAM
EVERY 2: SCRIPT 1
EVERY 4: SCRIPT 2

1:
CROW.C3 1 V -1 V 7	// trigger channel 1 (1), set note (V -1), set amplitude (V 7)

2: 
CROW.C3 2 V 4 V 6	// trigger channel 2 (2), set note (V 4), set amplitude (V 6)

LIVE INPUT:	// select params on crow, adjust PARAM knob to set values on crow
M 172		
CROW.C1 1211	// set synth (1) shape sine (2) model var_saw (1) channel 1 (1)
CROW.C1 211	// note env (2) note mod depth (1) channel 1 (1), turn knob up
CROW.C1 261	// note env (2) cycle time (6) channel 1 (1), turn knob down

CROW.C1 1132	// set synth (1) shape linear (1) model noise (3) channel 2 (2)
CROW.C1 142	// oscillator (1) pw2 (4) channel 2 (2) turn knob, bring the noise!
CROW.C1 462	// amp env (4) cycle time (6) channel 2 (2) turn knob, shorten the noise!
CROW.C1 212	// pitch env (2) note mod depth (1) channel 2 (2) turn knob, pitch the noise!
CROW.C1 312	// lfo (3) note mod depth (1) channel 2 (2) turn knob, mod the noise!
CROW.C1 362	// lfo (3) cycle time (6) channel 2 (2) turn knob, lfo the noise!

CROW.C1 503	// trig seq (5) turn on (0) channel 3 (3)
CROW.C1 463	// amp env (4) decay time (6) channel 2 (2) turn knob, adjust decay time
CROW.C1 563	// trig seq (5) step 1 (6) channel 3 (3) turn knob, select harmonic
CROW.C1 573	// trig seq (5) step 2 (7) channel 3 (3) turn knob, select harmonic
CROW.C1 583	// trig seq (5) step 3 (8) channel 3 (3) turn knob, select harmonic

CROW.C1 460	// amp env (4) cycle time (6) all channels (0) turn knob, adjust all decay times
...
```  
Explore from here, add ch4, adjust parameters, modulate sounds, sequence drum patterns, explore synth models  

![alt text](https://github.com/entzmingerc/drumcrow/blob/main/drumcrow%20parameter%20matrix.PNG?raw=true)

# Commands
## Teletype Operation
`CROW.C1 X` Select a parameter. The voltage at crow input 1 sets the parameter value (0 - 10V)  
`CROW.C2 X Y` Set parameter X to value Y (uses TT range `V -10` to `V 10` to cover the same range as 0 - 10V input)  
`CROW.C3 X Y Z` Triggers envelopes on channel X with note Y and amplitude Z  

Examples: navigate using digits (module, param, channel)  
`CROW.C1 234` select module 2 param 3 on channel 4, input voltage sets the value  
`CROW.C1 1234` put a 1 in front to set synth (shape, model, channel)  
`CROW.C2 261 V 4` sets 26 on channel 1 to V 4  
`CROW.C3 1 V 0 V 5` select channel 1, set note to `V 0`, set volume to `V 5`, trigger envelopes  

channel = 0 select all channels  
channel = 1-4 select a channel  
(5, 6, 7, 8, 9 wraps to 0, 1, 2, 3, 4 respectively)  

Parameters such as freq, note, amplitude, pulse width, and pw2 act a bit differently depending on the oscillator model used. The modulation sources are mostly the same with small differences. The CROW.C3 command sets note (11X) and amplitude (12X) of the oscillator, then triggers the envelopes. The amp env (4) is for amplitude control. The note env (2) is for pitch modulation. However, all 3 mod sources can affect amplitude or pitch of the oscillator if desired. All 3 mod sources can be set to cycle infinitely, but only amp env (4) and note env (2) will be retriggered if CROW.C3 is called. The lfo (3) is not retriggered when CROW.C3 is called.  

## Druid Operation
Druid can use the same functions teletype uses.  
`ii.self.call1( param )` is `CROW.C1 param`  
`ii.self.call2( param, value )` is `CROW.C2 param value`  
`ii.self.call3( channel, note, volume )` is `CROW.C3 channel note volume`  

Use `ii.self.call1(50X)` to turn on/off crow trig sequencers where X is channel (0-4). If you can, patch a constant voltage 0 to 10V to crow input 1, and use `ii.self.call1` to select parameters and set values with the input voltage. If you can not send an input voltage, then use `ii.self.call2` to select parameters and set their values directly from druid. Params such as 50X, 81X, 86X, that do not require a value can be called with ii.self.call2, it just ignores the sent value.  

When using call2 or call3, these commands are tuned to the teletype range of `V -10` to `V 10` which translates to the range: -16384 to 16384. 0V at crow input 1 is -16384, 10V at crow input 1 is 16384, and 5V at crow input 1 is 0. An easy way to work with this is to use multiples of 1000 from -16000 to 16000 for quick value settings. However, if you set note this way, you'll be out of tune from other synths (from 440Hz). Note value V 0 = 0 is tuned to C2. The exact teletype V to druid Integer values are listed below.  

Translated Example Kick and Snare Pattern from above using druid:  
```
ii.self.call1(501)		// turns on crow trig sequencer 1, could use call2 also
ii.self.call3(0, -1000, 10000)	// trigger all channels (0), set all notes (-1000), set all volumes (10000)
ii.self.call2(1211, 1)		// set synth (1) shape sine (2) model var_saw (1) channel 1 (1), ignores second value (1)
ii.self.call2(211, 2000) 	// note env (2) note mod depth (1) channel 1 (1), set value (2000), ~5V
ii.self.call2(261, -3000)	// note env (2) cycle time (6) channel 1 (1), send value (-3000), ~4V

ii.self.call2(1132, 1)		// set synth (1) shape linear (1) model noise (3) channel 2 (2), ignores second value (1)
ii.self.call2(112, 5000)	// oscillator (1) note (1) channel 2 (2), set value (5000), ~6V
ii.self.call2(142, 11000)	// oscillator (1) pw2 (4) channel 2 (2), set value (11000), ~8V
ii.self.call2(462, -3000)	// amp env (4) cycle time (6) channel 2 (2), set value (-3000), ~4V
ii.self.call2(212, 8000)	// pitch env (2) note mod depth (1) channel 2 (2), set value (8000), ~7V
...
```

teletype V = druid integer  
`V 10` = 16384  
`V  9` = 14746  
`V  8` = 13107  
`V  7` = 11469  
`V  6` = 9830  
`V  5` = 8192  
`V  4` = 6554  
`V  3` = 4915  
`V  2` = 3277  
`V  1` = 1638  
`V  0` = 0  
`V -1` = -1638, etc...  

## CROW.C1 X  
Selects a parameter. Control voltage at crow input 1 sets the parameter value (0 - 10V). These are the available sliders / knobs / buttons.  
| TT Command | DIGIT 3 | DIGIT 2 | DIGIT 1 | Description |
| --- | --- | --- | --- | --- |
| `0` | ~ | ~ |  ~ | deselect a parameter, maps input voltage to nothing <br> unused numbers deselect a parameter <br> setting trig seq tempo `81X` sets tempo then deselects |
| `10X` | 1 osc | 0 freq | 0-4 channel | maximum allowed frequency of a channel <br> default to 1x of global max (7000 Hz) <br> 0 <= V <= 10 :: 0.001x ... 1x|
| `11X` | 1 osc | 1 note | 0-4 channel | oscillator note of a channel <br> minimum set to 1Hz but can be set lower for LFOs <br> 0 <= V <= 10 :: 1Hz ... 20kHz|
| `12X` | 1 osc | 2 amplitude | 0-4 channel | oscillator amplitude of a channel <br> can be overdriven using modulation sources <br> 0 < V <= 5 :: -5V ... 0V <br> 5 <= V <= 10 :: 0V ... 5V |
| `13X` | 1 osc | 3 pulse width | 0-4 channel | pulse width of a channel <br> changes depending on the model <br> 0 <= V <= 10 :: -1 ... 1|
| `14X` | 1 osc | 4 pw2 | 0-4 channel | optional extra parameter <br> changes depending on the model <br> 0 <= V <= 10 :: -10 ... 10 |
| `15X` | 1 osc | 5 bitcrush amount | 0-4 channel | quantizer v/oct for a channel, bitcrush distortion <br> 0 <= V <= 5 :: OFF <br> 5 < V <= 10 :: temperament at 2 and V/Oct from 1 to 20 |
| `16X` | 1 osc | 6 caw to cyc3 | 0-4 channel | scales amount CAW sequencer modulates mod 3 cycle time (36X) <br> 0 <= V <= 5 :: OFF <br> 5 < V <= 10 :: 0x ... 2x |
| `17X` | 1 osc | 7 caw to cyc4 | 0-4 channel | scales amount CAW sequencer modulates mod 4 cycle time (46X) <br> 0 <= V <= 5 :: OFF <br> 5 < V <= 10 :: 0x ... 2x |
| `18X` | 1 osc | 8 caw to note | 0-4 channel | if CAW sequences note <br> 0 <= V <= 5 :: OFF <br> 5 < V <= 10 :: ON |
| `19X` | 1 osc | 9 splash | 0-4 channel | amount of noise applied to note <br> 0 <= V <= 5 :: OFF <br> 5 < V <= 10 :: 0 ... 5 |
| `20X` | 2 note env | 0 mod depth freq | 0-4 channel | env mod depth of maximum frequency <br> default to 0x <br> 0 <= V <= 10 :: 0x ... 1x|
| `21X` | 2 note env | 1 mod depth note | 0-4 channel | env mod depth of pitch <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `22X` | 2 note env | 2 mod depth amp | 0-4 channel | env mod depth of amplitude <br> 0 <= V <= 10 :: -3.3 ... 0 ... +3.3|
| `23X` | 2 note env | 3 mod depth pw | 0-4 channel | env mod depth of pulse width <br> 0 <= V <= 10 :: -2 ... 0 ... +2|
| `24X` | 2 note env | 4 mod depth pw2 | 0-4 channel | env mod depth of pw2 (misc) <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `25X` | 2 note env | 5 mod depth bit | 0-4 channel | env mod depth of bitcrush amount <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `26X` | 2 note env | 6 cycle time | 0-4 channel | env cycle time <br> 0 <= V <= 9.75 :: 0.006 sec - 100 sec <br> 9.75 < V <= 10 :: 2<sup>32</sup> seconds <br> [billions and billions](https://en.wikipedia.org/wiki/Carl_Sagan#%22Billions_and_billions%22)|
| `27X` | 2 note env | 7 attack / decay | 0-4 channel | env attack / decay ratio <br> V = 0.0 :: attack 0% decay 100% quieter <br> V = 2.5 :: attack 0% decay 100% <br> V = 5.0 :: attack 50% decay 50% <br> V = 7.5 :: attack 100% decay 0% <br> V = 10 :: attack 100% decay 0% quieter infinite release|
| `28X` | 2 note env | 8 curvature | 0-4 channel | env curvature <br> 0 <= V <= 10 :: 2<sup>-5</sup> ... 0 ... 2<sup>5</sup> <br> square ... linear ... logarithmic|
| `29X` | 2 note env | 9 looping | 0-4 channel |0 <= V <= 5 :: env looping OFF (default) <br> 5 < V < 10 :: env looping ON | 
| `30X` | 3 lfo | 0 mod depth freq | 0-4 channel | lfo mod depth of maximum frequency <br> default to 0x <br> 0 <= V <= 10 :: 0x ... 1x|
| `31X` | 3 lfo | 1 mod depth note | 0-4 channel | lfo mod depth of frequency <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `32X` | 3 lfo | 2 mod depth amp | 0-4 channel | lfo mod depth of amplitude <br> 0 <= V <= 10 :: -3.3 ... 0 ... +3.3|
| `33X` | 3 lfo | 3 mod depth pw | 0-4 channel | lfo mod depth of pulse width <br> 0 <= V <= 10 :: -2 ... 0 ... +2|
| `34X` | 3 lfo | 4 mod depth pw2 | 0-4 channel | lfo mod depth of pw2 (misc) <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `35X` | 3 lfo | 5 mod depth bit | 0-4 channel | lfo mod depth of bitcrush amount <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `36X` | 3 lfo | 6 cycle time | 0-4 channel | lfo cycle time <br> 0.25 <= V <= 10 :: 1 Hz - 1024 Hz :: 724 sec - 0.001 sec <br> 0 <= V <= 0.25 :: 2<sup>32</sup> seconds|
| `37X` | 3 lfo | 7 attack / decay | 0-4 channel | lfo attack / decay ratio <br> V = 0.0 :: attack 0% decay 100% quieter <br> V = 2.5 :: attack 0% decay 100% <br> V = 5.0 :: attack 50% decay 50% <br> V = 7.5 :: attack 100% decay 0% <br> V = 10 :: attack 100% decay 0% quieter infinite release|
| `38X` | 3 lfo | 8 curvature | 0-4 channel | lfo curvature <br> 0 <= V <= 10 :: 2<sup>-5</sup> ... 0 ... 2<sup>5</sup> <br> square ... linear ... logarithmic|
| `39X` | 3 lfo | 9 looping | 0-4 channel | lfo does not reset phase when voice is triggered <br> 0 <= V <= 5 :: lfo looping OFF <br> 5 < V <= 10 :: lfo looping ON (default)| 
| `40X` | 4 amp env | 0 mod depth freq | 0-4 channel | env mod depth of maximum frequency <br> default to 0x <br> 0 <= V <= 10 :: 0x ... 1x|
| `41X` | 4 amp env | 1 mod depth note | 0-4 channel | env mod depth of frequency <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `42X` | 4 amp env | 2 mod depth amp | 0-4 channel | env mod depth of amplitude <br> 0 <= V <= 10 :: -3.3 ... 0 ... +3.3|
| `43X` | 4 amp env | 3 mod depth pw | 0-4 channel | env mod depth of pulse width <br> 0 <= V <= 10 :: -2 ... 0 ... +2|
| `44X` | 4 amp env | 4 mod depth pw2 | 0-4 channel | env mod depth of pw2 (misc) <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `45X` | 4 amp env | 5 mod depth bit | 0-4 channel | env mod depth of bitcrush amount <br> 0 <= V <= 10 :: -10 ... 0 ... +10|
| `46X` | 4 amp env | 6 cycle time | 0-4 channel | env cycle time <br> 0 <= V <= 9.75 :: 0.006 sec - 100 sec <br> 9.75 < V <= 10 :: 2<sup>32</sup> seconds|
| `47X` | 4 amp env | 7 attack / decay | 0-4 channel | envelope attack / decay ratio <br> V = 0.0 :: attack 0% decay 100% quieter <br> V = 2.5 :: attack 0% decay 100% <br> V = 5.0 :: attack 50% decay 50% <br> V = 7.5 :: attack 100% decay 0% <br> V = 10 :: attack 100% decay 0% quieter infinite release|
| `48X` | 4 amp env | 8 curvature | 0-4 channel | env curvature <br> 0 <= V <= 10 :: 2<sup>-5</sup> ... 0 ... 2<sup>5</sup> <br> square ... linear ... logarithmic|
| `49X` | 4 amp env | 9 looping | 0-4 channel | 0 <= V <= 5 :: env looping OFF (default) <br> 5 < V < 10 :: env looping ON | 
| `50X` | 5 trig seq | 0 ON/OFF | 0-4 channel | turn ON/OFF trig sequencer for channel |
| `51X` | 5 trig seq | 1 length A | 0-4 channel | length of time to wait after a trigger in A <br> 0 <= V <= 10 :: 1/10, ..., 1/2, 1/1, 0, 1, 2, ..., 10 beats |
| `52X` | 5 trig seq | 2 repeats A | 0-4 channel | number of times to "trigger then wait length A" before moving to B <br> 0 <= V <= 10 :: 10, ..., 2, 1, 1, 1, 2, ..., 10 repeats |
| `53X` | 5 trig seq | 3 length B | 0-4 channel | length of time to wait after a trigger in B <br> 0 <= V <= 10 :: 1/10, ..., 1/2, 1/1, 0, 1, 2, ..., 10 beats |
| `54X` | 5 trig seq | 4 repeats B | 0-4 channel | number of times to "trigger then wait length B" before moving to A <br> 0 <= V <= 10 :: 10, ..., 2, 1, 1, 1, 2, ..., 10 repeats |
| `55X` | 5 trig seq | 5 flaps | 0-4 channel | direction of steps to advance CAW sequence <br> 0 <= V <= 10 :: 1 (forwards), 2 (two steps forward), 3 (backwards), 4 (no step) |
| `56X` | 5 trig seq | 5 CAW1 | 0-4 channel | harmonic for step 1 <br> 0 <= V <= 10 :: 1/10, ..., 1/2, 1/1, 0, 1, 2, ..., 10 |
| `57X` | 5 trig seq | 5 CAW2 | 0-4 channel | harmonic for step 2 <br> 0 <= V <= 10 :: 1/10, ..., 1/2, 1/1, 0, 1, 2, ..., 10 |
| `58X` | 5 trig seq | 5 CAW3 | 0-4 channel | harmonic for step 3 <br> 0 <= V <= 10 :: 1/10, ..., 1/2, 1/1, 0, 1, 2, ..., 10 |
| `59X` | 5 trig seq | 5 CAW4 | 0-4 channel | harmonic for step 4 <br> 0 <= V <= 10 :: 1/10, ..., 1/2, 1/1, 0, 1, 2, ..., 10 |
| `81X` | 8 | 1 | any number | set global tempo of all sequencers then deselects <br> 0 <= V <= 10 :: 10 BPM ... 2010 BPM| 
| `82X` | 8 | 2 | any number | global update time of all voices <br> 0 <= V <= 10 :: 0.006 sec ... 0.1 sec <br> defualt 0.006 <br> shorter times may overload CPU <br> longer times result in stair-step modulation| 
| `83X` | 8 | 2 | any number | global maximum frequency of all voices <br> 0 <= V <= 10 :: 0.01 Hz ... 20000 Hz <br> defualt 7000 Hz <br> higher frequencies than default may overload CPU| 
| `85X` | 8 | 2 | 0-4 channel | reset position of trigger sequencer <br> keeps length and repeat values the same | 
| `86X` | 8 | 6 | 0-4 channel | set a channel to its initial value [86 Term](https://en.wikipedia.org/wiki/86_(term))| 
| `1XYZ` | 1 set synth | 1-9 shape<br>1-7 model | 0-4 channel | Set [shape](https://monome.org/docs/crow/reference/#shaping-cv) and model <br> default :: shape = 1 linear, model = 1 var_saw|

## CROW.C2 X Y
| TT Command | Parameter | Value | Description |
| --- | --- | --- | --- |
| `CROW.C2 X Y` | 3-digit parameter X <br> CROW.C1 see above | TT value `V -10` ... `V 10` <br> =input voltage 0-10V <br> =druid -16384 to 16384 | set a parameter on a channel to a value directly, without input voltage <br> CROW.C1 takes higher priority than CROW.C2|

Many parameters can be set to zero by using `V 0`. The 0 to 10V input control voltage range is the same range as teletype `V -10` to `V 10` is the same as from druid -16384 to 16384. Any CROW.C1 command can be replaced by CROW.C2. Use the teletype OP `VV` to set a parameter to a decimal value. Some parameters, like pulse width, are sensitive to decimal changes. If CROW.C1 is selecting the same parameter CROW.C2 is trying to set, CROW.C1 takes higher priority than CROW.C2. (Technically speaking, CROW.C2 will set the parameter, but it will then be immediately overwritten by the C1 value in the next update loop, CAW).  

### CAW! C2 IDEAS
Try doing everything with C2 instead of C1 and the PARAM knob  
Try deselecting a parameter before setting it using C2: `CROW.C1 0`  
Try setting things to zero! This sets lfo note mod depth to zero on channel 1: `CROW.C2 311 V 0`  
Try setting amp env decay time to a random value from teletype: `CROW.C2 462 RRAND V -5 V 5`  
Try exploring decimal pw2 values with the ASLsine and noise models: `CROW.C2 141 VV 10`  
Try sequencing Ch1 note with teletype patterns: `CROW.C2 111 PN.NEXT 0`  
....while triggering the channel with another pattern: `CROW.C3 1 N PN.NEXT 1 V 5`  
........while drumcrow sequencer is ON `CROW.C1 501`  
............while randomly updating drumcrow sequencer values `CROW.C2 + 510 RAND 3 RRAND V 4 V 7`  
................while every 5 we set decay envelope to PARAM for fun `EV 5: CROW.C2 461 PARAM`  
....................(I haven't actually tested this, CAW)  

## CROW.C3 X Y Z
| TT Command | X | Y | Z | Description |
| --- | --- | --- | --- | --- |
| `CROW.C3 X Y Z` | 0-4 channel | V -10 ... V 10 <br> note <br> TT Value | V -10 ... V 10 <br> amplitude <br> TT Value | channel, note, amplitude, triggers envelopes <br> only triggers amp env and note env if passed attack stage <br> note usually `V -3` ... `V 7` <br> amplitude usually `V 0` ... `V 10`|

CROW.C3 X Y Z = (channel) (note) (amplitude)  
Select channel. Set note. Set amplitude. Triggers envelopes. Sequence notes and volumes from teletype using patterns, random values, and so on. Some synth models change tone depending on note. Mix oscillators using volume parameter, set to 0 to mute. Set all amp modulation `2` type parameters to zero as well if volume is still heard while trying to mute. Try using channel 0 to quickly set the note and volume of all channels. It uses the same teletype range of V -10 to V 10 as CROW.C2 for note and volume. Trigger chords by using multiple CROW.C3 commands in a single teletype script each selecting different notes and channels. CROW.C3 note value V 0 from teletype translates to the musical note C2. CROW.C3 is compatible with N and VV voltage commands from teletype.  

## Models
`CROW.C1 1XYZ` Sets synth (1) shape (X) model (Y) channel (Z). There are 9 shapes and currently 7 synth models. You can set all channels by using channel = 0. Explore different combinations of shapes and synth models. Each model behaves differently depending on how the parameters are set. Some work better at higher note values, so if it doesn't sound quite right, try a higher note. Set the note using a CROW.C3 command or turn up the note (11) yourself. The freq parameter (10X) sets the maximum allowable ASL frequency for a channel X. The bit parameter (15X) applies quantization to the amplitude of the ASL output voltage. Refer to the [ASL Oscillator document](https://docs.google.com/document/d/1rif4Xkr2mvPt7-AtZXZ10HZQSWhS0JS5iVN1x0s7KBg/edit?usp=sharing) in the forum post for further model design discussion.  

1. var_saw(amp, cyc, pw, shape) (Default)  
Go up to a +voltage, down to a -voltage. Triangle model with pulse width control. Use shape to select 1 triangle, 2 sine, 5 square, or select any shape 1-9 to hear different tones.  
```
loop { to(  dyn{amp=2}, dyn{cyc=1/440} * dyn{pw=1/2}, shape), to(0-dyn{amp=2}, dyn{cyc=1/440} * (1-dyn{pw=1/2}), shape) } 
```
2. bytebeat(amp, cyc, pw, shape)  
Output voltage is stepped by PW each loop and wrapped between -10 ... 10. Crow hardware limit is -5 to +10V. Cyc determines our "sample rate" and PW determines the "step rate". Both affect the output frequency. 
```
-- dyn.pw = pw * pw2
loop { to(dyn{x=1}:step(dyn{pw=1}):wrap(-10,10) * dyn{amp=2}, dyn{cyc=1}, shape) }
```
3. noise(amp, cyc, pw, pw2, shape)  
Noise is an [LCG](https://en.wikipedia.org/wiki/Linear_congruential_generator) used to create noise using the equation x(n+1) = ((x * pw2)  + pw) % 10. Set PW2 to a value to get some noise. PW2 is sensitive to decimal values as well, explore sweet spots. Higher pitches for higher frequency noise. Use short amplitude envelope cycle times for high hats and snares.  
```
-- dyn.pw = pw, dyn.pw2 = pw2
loop { to(dyn{x=1}:mul(dyn{pw2=1}):step(dyn{pw=1}):wrap(-5,5) * dyn{amp=2}, dyn{cyc=1}/2, shape) } 
```
4. FMstep(amp, cyc, pw, pw2, shape)  
This expands the var_saw model to multiply cyc by a dynamic variable x that sweeps between 1 and 2 at a speed set by pw2. Low pw2 values means the frequency modulates slowly, higher pw2 value results in a more FM type sound.  
```
-- dyn.pw = pw, dyn.pw2 = pw2 / 50
loop {to(  dyn{amp=2}, dyn{x=1}:step(dyn{pw2=1}):wrap(1,2) * dyn{cyc=1} * dyn{pw=1}, shape),
			to(0-dyn{amp=2}, dyn{x=1} * dyn{cyc=1} * (1-dyn{pw=1}), shape) }
```
5. ASLsine(amp, cyc, pw, shape)  
This is a root-product sine wave approximation y = x + 0.101321(x)^3. The var_saw model can select two voltage points to move between, but ASL can't step through a waveform unless we make 100 ASL stages and step through them manually. Instead, we can loop one ASL stage, step x by PW and, wrap it between -pi and +pi, and now it roughly traces out a sine wave. The X variable is stepped each time its referenced. Time it takes to step a voltage is determined by cyc.  
```
-- dyn.pw = pw * pw2
loop { to((dyn{x=0}:step(dyn{pw=0.314}):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, shape) }
```
6. ASLharmonic(amp, cyc, pw, shape)  
Same as ASLsine but we add a mul(-1) to x so each time x is called the polarity flips. Slightly more chaotic with PW2.  
```
-- dyn.pw = pw * pw2
loop { to((dyn{x=0}:step(dyn{pw=1}):mul(-1):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, shape) }
```

7. bytebeat5(amp, cyc, pw, pw2)  
Another bytebeat model. pw sets the step rate. pw2 sets the modulo range. note and freq determine cyc which is the "sample rate" of the bytebeat shape.  
```
loop{to(dyn{x=0}:step(dyn{pw=0.1}):wrap(0, 10) % dyn{pw2=1} * dyn{amp=2}, dyn{cyc=1}, shape)}
```

## Shapes  
Select the shape of the synth model listed in monome crow [documentation](https://monome.org/docs/crow/reference/#shaping-cv).  
[Easing functions](https://easings.net/) define how to walk point to point.  
Shapes can be used to change the tone of the ASL oscillator.  
1 = linear, 2 = sine, 3 = logarithmic, 4 = exponential, 5 = now, 6 = wait, 7 = over, 8 = under, 9 = rebound  

## Trigger Sequencer
drumcrow can be triggered externally if the trigger sequencer is on or off. `CROW.C1 50X` turns on / turns off the trigger sequencer for a channel. `CROW.C1 81X` can be used to set the tempo on crow for all channels 10 BPM to 2010 BPM (X is any number). This will read the input voltage, set the tempo, then immediately deselect the input. You can not sweep the input voltage to sweep the tempo, you have to send this command to set the tempo value. When a trigger sequencer is turned on, it will trigger the channel immediately with the current setting of note (11X) and amplitude (12X). `CROW.C3 X Y Z` can quickly set the note and amplitude if desired.  

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

### Harmonic CAW Sequencer
Parameters `56X, 57X, 58X, 59X` set the frequency multiplier for each step 1, 2, 3, 4. Default values for each step is {1, 1, 1, 1} but each step can be set to 1/10, 1/9, ... 1/2, 1/1, 1, 1, 2, ... 9, 10. For example, if channel 1 note is set to 400Hz and the multiplier is set to 3 then you will hear 1200Hz. This is the 3rd harmonic of the fundamental frequency 400Hz. Harmonic sequencers [sequence ratios](https://www.youtube.com/watch?v=yA9uguVcd6o) instead of absolute values. Harmonics are integer values, subharmonics are fractional multipliers. Each trigger we step forward to the next ratio depending on the direction of flaps `55X`. Sequencing the note value is ON by default, but it can be turned off using `18X`. The sequencer can be mapped to lfo cycle time `36X` using the parameter `16X` which sets the mod depth (0x ... 2x) of the sequencer value. The sequencer can be mapped to amp env cycle time `46X` using the parameter `17X` which sets the mod depth (0x ... 2x) of the sequencer value.  

flaps `55X` sets what direction we step for each trigger  
If our CAW sequence is {1, 3, 1/2, 4} and we are at 1/2:  
flaps = 1, forwards, next step is 4  
flaps = 2, two steps forward, next step is 1  
flaps = 3, backwards, next step is 3  
flaps = 4, no change, next step is 1/2  

### CAW! TRIG SEQ IDEAS
Try using trig seq simultaneously with external TT sequencing using CROW.C3  
Try sequencing trig seq parameters directly with CROW.C2  
Try setting all channels to the same note and volume using CROW.C3, and then sequence each channel differently.  
Try sequencing amp env cycle time `17X` for open / closed high hat sounds.  
Try turning on and off trigger sequencers at various rates to step patterns irregularly.  
Try using flaps to change all channels' directions simultaneously.  
Try making noise by cranking tempo up to 2000 BPM and using subharmonic divisions and trigger length divisions.  
Try sequencing the lfo cycle rate with `16X`, make wubs with lfo frequency mod depth `31X` and PW mod depth `34X`.    

# Future Development
- port to norns, currently prototyping nb_drumcrow  
- possibly zxcvbn?  