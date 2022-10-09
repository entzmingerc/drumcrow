# drumcrow
turns crow into a 4-channel drum machine with teletype

# Teletype Commands
CROW.C1 X
X = (mod source, mod parameter, channel)
3 digits = maps CV in 1 to a parameter (152 = envelope, depth, channel 2)
4 digits = changes synth model of a channel (1023 = set model 02 on channel 3)

CROW.C2 X Y
X = 3 digit number only (mod source, mod parameter, channel)
Y = teletype number
Sets the parameter at X to the value of Y

CROW.C3 X Y Z
X = Channel (1 - 4)
Y = Pitch (teletype number)
Z = Volume (teletype numebr) 
Trigger the envelope at Channel X, with pitch Y, with volume Z

Synth Model
1 = Variable Saw
2 = Pulse Width Modulation Square
3 = LCG (Linear Congruential Generator = pseudorandom noise)
4 = math.random noise testing (non-functional)

Mod Source 
1 = ENV (envelope)
2 = LFO

Mod Parameter
1 = Frequency
2 = Symmetry (attack : decay)
3 = Curvature 
4 = Pulse Width (timbre)
5 = Depth (amplitude)

Channel
1 = Output 1
2 = Output 2
3 = Output 3
4 = Output 4