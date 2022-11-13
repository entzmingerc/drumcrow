--- drumcrow
--[[
4 voice drum machine for monome crow
Driven with i2c commands
CROW.C1 X
CROW.C2 X Y
CROW.C3 X Y Z

Future
[ ] Calibrate C1 inputs to nicer values 0 to 10V
[ ] Calibrate inputs for TT voltage values directly to same internal values
[ ] Calibrate inputs for norns numbers if possible
[ ] Test norns input
[ ] Replace LCG with new noise function, responsive to inputs
[ ] Redo pulse width inputs and update loop with pulse width
[ ] Add ability to modulate pw2 maybe
[ ] set up better defaults

--]]
local states = {}
local ch = 1
local cmd = 11
local presets = {}
local c2 = {}
local shapes = {'linear','sine','logarithmic','exponential','now','wait','over','under','rebound'}

local bad_cmd = function (ch, value) 
    print("CAW!")
end

c2[0] = function (ch, v5)
	-- deselect
end

-- model pw timbre
    -- there is a bug w/ model 1 when pw = 16250
    -- detuned, undertones, sounds SICK
    -- DO NOT FIX IT YET
c2[1] = function (ch, v5)
    set_state(ch, 'pw', v5 / 10)
end

c2[2] = function (ch, v5)
    set_state(ch, 'pw2', v5 / 2)
end

-- ENV 1XX
-- ENV frequency (Hz*10) Hz*10 (-lp)
c2[11] = function (ch, v5)
    v5 = 2 ^ (0 - v5)
    set_state(ch, 'efr', v5)
end
-- ENV symmetry (A:D)
c2[12] = function (ch, v5)
    set_state(ch, 'esy', v5 / 5)
end
-- ENV curvature
c2[13] = function (ch, v5)
    set_state(ch, 'ecr', v5)
end
-- ENV pw timbre
c2[14] = function (ch, v5)
    set_state(ch, 'epw', v5 / 5)
end
-- ENV depth
c2[15] = function (ch, v5)
    set_state(ch, 'ent', v5)
end
-- LFO 2XX
-- LFO spd (Hz*10) Hz*10 (+rst)
c2[21] = function (ch, v5)
    set_state(ch, 'lfr', 2 ^ v5)
end
-- LFO symmetry (R:F) 
c2[22] = function (ch, v5)
    set_state(ch, 'lsy', v5 / 5)
end
-- LFO curvature 
c2[23] = function (ch, v5)
    set_state(ch, 'lcr', v5)
end
-- LFO pulse width 
c2[24] = function (ch, v5)
    set_state(ch, 'lpw', v5)
end
-- LFO DEPTH
c2[25] = function (ch, v5)
    set_state(ch, 'lnt', v5)
end
-- AMP ENV 1XX
-- AMP ENV frequency (Hz*10) Hz*10 (-lp)
c2[31] = function (ch, v5)
    v5 = 2 ^ (0 - v5)
    set_state(ch, 'afr', v5)
end
-- AMP ENV symmetry (A:D)
c2[32] = function (ch, v5)
    set_state(ch, 'asy', v5 / 5)
end
-- AMP ENV curvature
c2[33] = function (ch, v5)
    set_state(ch, 'acr', v5)
end
-- AMP ENV pw timbre
c2[34] = function (ch, v5)
    set_state(ch, 'apw', v5 / 5)
end
-- AMP ENV depth
c2[35] = function (ch, v5)
    set_state(ch, 'ant', v5)
end


-- -32768 to +32767
function u16_to_v10(u16)
    return u16/16384*10;
end

function v10_to_u16(u16)
    return u16/10*16384;
end
function v5_to_u16(u16)
    return u16/5*16384;
end
function v8_to_freq(v8)
    -- Tyler's Mordax said JF 0V = 261.61
    -- -5v - +5v = 8.17Hz - 8.37kHz.
  return 261.61 * (2 ^ v8)
end

function get_digits(b1)
	-- TT variables -32768..+32767 so 5 digit maximum
	local digits = {}
	for i = 1, 5 do
		digits[i] = b1 % 10
		b1 = (b1 - digits[i]) / 10
	end
	return digits
end

-- input 1 stream to update all the synths in a loop
function setup_input()
    print("INPUT OK.")
	
	-- read input voltage 1, map input 0..+10V to -10..+10 internally, update synths
    input[1].stream = function (v)
        if     v <=  0 then v = -10
		elseif v >= 10 then v =  10
        else   v = (v - 5) * 2
        end 
        ;(c2[cmd] or bad_cmd)(ch,v)--KEEP SEMICOLON!
        for i = 1, 4 do
            if i ~= nil then
                update_synth(i)
            end
        end
    end
	
    input[1]{mode = 'stream', time = 0.003}
    input[2].stream = function (v) collectgarbage("collect") end
    input[2]{mode = 'stream', time = 10}
end

-- initialize ASL table to loop as oscillator
function setup_synth(output_index, model, shape)

    -- variable 2-stage wave|\ to /\ to /|
	function var_saw (shape) 
		return loop {
			to(  dyn{amp=2}, dyn{cyc=1/440} *    dyn{pw=1/2} , shape),
			to(0-dyn{amp=2}, dyn{cyc=1/440} * (1-dyn{pw=1/2}), shape)
		} 
	end	

	-- linear congruential generator (LCG) (https://w.wiki/tV5)
	-- generates sequence of pseudo-random numbers
	-- X(n+1) = (aX.n + c) mod m
    -- a = pw2, c = pw, m and c are relatively prime
    -- a-1 is divisible by all prime factors of m
    -- a-1 is divisible by 4 if m is divisible by 4.
    function lcg(shape) 
		return loop {
			to(dyn{x = 1}:mul(dyn{pw2 = 4037}):step(dyn{pw = 21032}):wrap(-32768,  32768 ) / 32768 * dyn{amp=2}, 0, shape),
			to(dyn{x = 1} / 32768 * dyn{amp=2}, dyn{cyc=1/440} / 2, shape)
		} 
	end
	
	function bytebeat(shape)
		return loop { 
			to(dyn{x=1}:step(dyn{pw=1}):wrap(-20,20) * dyn{amp=2}, dyn{cyc=1}, shape)
		}
	end
	
	function noise(shape) 
		return loop {
			to(dyn{x=1}:mul(dyn{pw2=1}):step(dyn{pw=1}):wrap(-10,10) * dyn{amp=2}, 0.00005, shape)
		} 
	end
	
	-- assign action to output then run the output action
    states[output_index].mdl = model
	states[output_index].shp = shapes[shape]
	if model == 1 or model == 3 then 
		output[output_index]( var_saw(shapes[shape]) )
	elseif model == 2 then 
		output[output_index]( lcg(shapes[shape]) )
	elseif model == 4 then
		output[output_index]( bytebeat(shapes[shape]) )
	elseif model == 5 then
		output[output_index]( noise(shapes[shape]) )
	end
end

-- initialize i2c function calls for teletype
function setup_i2c()
	-- TT variables -32768..+32767 so 5 digit maximum
	-- ABCDE digit number, AB action, CD param, E channel
	-- set CV input 1 to <mod source, mod parameter, channel>
    ii.self.call1 = function (b1)
		digits = get_digits(b1)
		local action  = (digits[5] * 10) + digits[4]
		local param   = (digits[3] * 10) + digits[2]
		local channel = (digits[1] % 10 % 4)
        channel = (channel == 0 and 4) or channel
		for i = 1,5 do
			print("digits"..digits[i])
		end
		print("action "..action.." param "..param.." channel "..channel)
		
		-- 0: map input 1 voltage to (ch, cmd)
		if action == 0 then
            ch = channel
            cmd = param
            print("input 1 mapping to ch "..ch.." command "..cmd)
			
		-- 1: set ch synth engine 
        elseif action == 1 then
            print("setting ch "..channel.." to eng "..digits[2].." to shape "..digits[3])
            setup_synth(channel, digits[2], digits[3])
		
		-- 2: set ch synth amplitude quantizing (bitcrushery?) 
		-- 2121 = (2) command, (1) temperament, (2) scaling (1) channel
        elseif action == 2 then
            print("setting ch "..channel.." to temperament "..digits[3].." with scaling "..digits[2])
			if digits[3] == 0 or digits[2] == 0 then
				output[channel].scale( 'none' )
			else
				output[channel].scale( {}, digits[3], digits[2] )
			end
        else
        end
    end
	
	-- CROW.C2 x y -- set <mod source, mod parameter, channel> to <value>
    ii.self.call2 = function (b1, value)
        digits = get_digits(b1)
		local action  = (digits[5] * 10) + digits[4]
		local param   = (digits[3] * 10) + digits[2]
		local channel = (digits[1] % 10 % 4)
        channel = (channel == 0 and 4) or channel

		-- set a parameter value directly
		if param < 36 then 
			value = (u16_to_v10(value) - 5) * 2
			print("setting param to "..param.." on channel "..channel.." value "..value)
			c2[param](channel, value) 
			update_synth(channel)
			
		-- set global synth update time
		-- 0.002 - 0.1 sec time range from V -10 or V 10 in TT, initial is 0.003
		elseif param == 99 then
			value = (u16_to_v10(value) + 10) / 20 * (0.1 - 0.002) + 0.002
			print("setting input stream update time to "..value)
			input[1]{mode = 'stream', time = value}
		else
			bad_cmd(channel, value) 
		end
    end
	
	-- CROW.C3 x y z -- play (freq, amp) or (preset, amp)
    ii.self.call3 = function (ch, note, vol)
    -- | play frq, amp      
        if ch == nil or note == nil or vol == nil or ch < 1 or ch > 4 then 
            return 
        end
        local v8 = u16_to_v10(note)
        local amp = u16_to_v10(vol)
        states[ch].nte = v8
        states[ch].amp = amp
        trigger_note(ch)
    end
end

-- select channel, set value of a param in states array
function set_state(ch, key, value)
    if value ~= nil then
        states[ch][key] = value
    end
end

-- initialize state array for each output
function setup_state(ch)
    -- sy (symmetry) is like pulsewidth
    states[ch] = {
        nte = 0, -- note (for frequency calculation)
        amp = 2, -- amplitude of oscillator
        pw  = 0, -- pulse width variable 1
        pw2 = 1, -- pulse width variable 2 4037
        mdl = 1, -- model number
		shp = 'linear', -- shape (ASL CV Shape)
		
		-- ENVELOPE AMP
		afr = 100, -- decay time
		asy = -1, -- symmetry
		acr = 4, -- not referenced elsewhere (curvature?)
		apw = 0, -- pulse width
		ant = 0, -- note
		aph = 0, -- phase
		
        -- this crashes when I set it negative (or 0?)		
		-- ENVELOPE PITCH
        efr = 100, -- cycle length
		esy = -1, -- pulse width or symmetry
		ecr = 4, -- not referenced elsewhere (curvature)
		epw = 0, -- pulse width
		ent = 0, -- note 
		eph = 1, -- phase 
        
		-- LFO
		lfr = 5, -- frequency 
		lsy = 0, -- symmetry
		lcr = 0, -- curvature
		lpw = 0, -- pulse width
		lnt = 0, -- note
		lph = -1, -- phase
    }
    print("setting up state ")
    print("state #"..ch..": "..states[ch].nte)
end

-- assume ph and pw between {-1..1} incl
function peak(ph, pw, curve)
    local value = (ph < pw) and ((1 + ph) / (1 + pw))
        or (ph > pw) and ((1 - ph) / (1 - pw))
        or 1
    value = value ^ (2 ^ curve)
    return value
end

-- accumulates phase
function acc(phase, freq, sec, looping)
    phase = phase + (freq * sec)
    phase = looping and ((1 + phase) % 2 - 1) or math.min(1, phase)
    return phase
end

-- select channel, trigger note on that channel
function trigger_note(ch)
    -- print("triggered "..ch)
    -- do not retrigger attack
    if states[ch].eph >= states[ch].esy then
        states[ch].eph = -1
    end
	if states[ch].aph >= states[ch].asy then
        states[ch].aph = -1
    end
end

-- get state parameters, set output
function update_synth(i)
    local s = states[i]
    local sec = input[1].time
	
	-- AMPLITUDE ENVELOPE
	s.aph = acc(s.aph, s.afr, sec, false)
    local ampenv = peak(s.aph, s.asy, 3) 

    -- MOD ENVELOPES
    s.eph = acc(s.eph, s.efr, sec, false)
    local modenv = peak(s.eph, s.esy, 4)

    -- LFO
    s.lph = acc(s.lph, s.lfr, sec, true)
    local lfo = peak(s.lph, s.lsy, s.lcr)

    -- FREQ
    local note = s.nte + (modenv * s.ent) + (lfo * s.lnt) + (ampenv * s.ant)
    local freq = v8_to_freq(note)
    if freq <= 0 then freq = 0.0000000001 end
	if freq >= 20000 then freq = 20000 end
	
	-- Time of ASL stages
	local cyc = 1/freq
	if s.mdl == 3 then
		norm_cyc = cyc/0.1
		if math.random()*0.1 < norm_cyc then
			output[i].dyn.cyc = cyc + (cyc * 0.2 * math.random())
		else
			output[i].dyn.cyc = cyc + math.random()*0.002
		end
	elseif s.mdl == 5 then
		output[i].dyn.pw2 = cyc
	else
		output[i].dyn.cyc = cyc
	end
	
    -- AMP
	output[i].dyn.amp = ampenv * s.amp


    -- TIMBRE
    if s.mdl == 2 then
		-- LCG code
        local pw = s.pw
        output[i].dyn.pw = math.abs(pw * 16384)
        output[i].dyn.pw2 = s.pw2
    else
	    local pw = s.pw + (modenv * s.epw) + (lfo * s.lpw) + (ampenv * s.apw)
        pw = math.max(-1, math.min(pw, 1))
        pw = (pw + 1) / 2
		if s.mdl == 4 or s.mdl == 5 then
			output[i].dyn.pw = pw * s.pw2
		end
    end	
end

-- INIT
function init()
	for i = 1, 4 do
		setup_state(i)
		setup_synth(i, 1, 1)
	end	
	setup_i2c()
	setup_input()
end 