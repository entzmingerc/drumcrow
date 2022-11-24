--- drumcrow
local states = {}
local ratios = {}
local ch = 1
local cmd = 11
local c2 = {}
local act = 0
local shapes = {'linear','sine','logarithmic','exponential','now','wait','over','under','rebound'}
local cmd_list = {}
clock_enable = {0, 0, 0, 0}
sq = sequins
clock_ID = {}

local bad_cmd = function (ch, value) 
    print("CAW! Bad command!")
end
-- Frees the input voltage from mapping anything
cmd_list[00] = 'deselect'
c2[00] = function (ch, v)
end
-- model pw timbre (bug w/ model 1 when pw = 16250 ?)
cmd_list[1] = 'pw'
c2[1] = function (ch, v)
    set_state(ch, 'pw', v / 10)
end
-- extra pw2 param, varying use case
cmd_list[2] = 'pw2'
c2[2] = function (ch, v)
    set_state(ch, 'pw2', v)
end
-- quantizer v/oct scaling amount
cmd_list[3] = 'bit'
c2[3] = function (ch, v)
	if v <= 0 then v = 0 end
    set_state(ch, 'bit', v)
end
-- ENV frequency (Hz*10) Hz*10 (-lp)
cmd_list[11] = 'efr'
c2[11] = function (ch, v)
	set_state(ch, 'efr', 
	(v <= 9.5) and (2 ^ (0 - v*0.7)) or
	(v >  9.5) and 0.0000000002328)-- 2^-32 billions and billions
end
-- ENV symmetry (A:D)
cmd_list[12] = 'esy'
c2[12] = function (ch, v)
    set_state(ch, 'esy', v / 5)
end
-- ENV curvature
cmd_list[13] = 'ecr'
c2[13] = function (ch, v)
    set_state(ch, 'ecr', v / 2)
end
-- ENV pw timbre
cmd_list[14] = 'epw'
c2[14] = function (ch, v)
    set_state(ch, 'epw', v / 5)
end
-- ENV depth
cmd_list[15] = 'ent'
c2[15] = function (ch, v)
    set_state(ch, 'ent', v)
end
-- ENV type
cmd_list[16] = 'etype'
c2[16] = function (ch, v)
	local flag = (v <= 0) and false or (v > 0) and true
	set_state(ch, 'etype', flag)
end
-- LFO spd (Hz*10) Hz*10 (+rst)
cmd_list[21] = 'lfr'
c2[21] = function (ch, v)
	set_state(ch, 'lfr', 
	(v >  -9.5) and (2 ^ v) or
	(v <= -9.5) and 0.0000000002328)
end
-- LFO symmetry (R:F) 
cmd_list[22] = 'lsy'
c2[22] = function (ch, v)
    set_state(ch, 'lsy', v / 5)
end
-- LFO curvature 
cmd_list[23] = 'lcr'
c2[23] = function (ch, v)
    set_state(ch, 'lcr', v / 2)
end
-- LFO pulse width 
cmd_list[24] = 'lpw'
c2[24] = function (ch, v)
    set_state(ch, 'lpw', v)
end
-- LFO DEPTH
cmd_list[25] = 'lnt'
c2[25] = function (ch, v)
    set_state(ch, 'lnt', v)
end
-- LFO type
cmd_list[26] = 'ltype'
c2[26] = function (ch, v)
	local flag = (v <= 0) and false or (v > 0) and true
	set_state(ch, 'ltype', flag)
end
-- AMP ENV frequency (Hz*10) Hz*10 (-lp)
cmd_list[31] = 'afr'
c2[31] = function (ch, v)
	set_state(ch, 'afr', 
	(v <= 9.5) and (2 ^ (0 - v*0.7)) or
	(v >  9.5) and 0.0000000002328)
end
-- AMP ENV symmetry (A:D)
cmd_list[32] = 'asy'
c2[32] = function (ch, v)
    set_state(ch, 'asy', v / 5)
end
-- AMP ENV curvature
cmd_list[33] = 'acr'
c2[33] = function (ch, v)
    set_state(ch, 'acr', v / 2)
end
-- AMP ENV pw timbre
cmd_list[34] = 'apw'
c2[34] = function (ch, v)
    set_state(ch, 'apw', v / 5)
end
-- AMP ENV depth
cmd_list[35] = 'ant'
c2[35] = function (ch, v)
	set_state(ch, 'ant', v)
end
-- AMP ENV type
cmd_list[36] = 'atype'
c2[36] = function (ch, v)
	local flag = (v <= 0) and false or (v > 0) and true
	set_state(ch, 'atype', flag)
end

-- TRIG
cmd_list[41] = 't_len'
c2[41] = function (ch, v)
	set_state(ch, 't_len', v10_to_ratio(v), 1)
end
cmd_list[42] = 't_rep'
c2[42] = function (ch, v)
	set_state(ch, 't_rep', v10_to_int(v), 1)
end
cmd_list[43] = 't_len'
c2[43] = function (ch, v)
	set_state(ch, 't_len', v10_to_ratio(v), 2)
end
cmd_list[44] = 't_rep'
c2[44] = function (ch, v)
	set_state(ch, 't_rep', v10_to_int(v), 2)
end

-- -32768 to +32767
function u16_to_v10(u16) return u16/16384*10 end
function v10_to_u16(u16) return u16/10*16384 end
function  v5_to_u16(u16) return u16/5*16384  end
    -- Tyler's Mordax said JF 0V = 261.61
    -- -5v - +5v = 8.17Hz - 8.37kHz.
function  v8_to_freq(v8) return 261.61 * (2 ^ v8) end
function v10_to_int(v)
	return (v >= 1) and (v - v % 1) or (v <= -1) and (-1*(v + (-1*v) % 1)) or 0 
end
function v10_to_ratio(v)
	-- any number input, returns 1/(v integer), ..., 1/2, 1/1, 0, 1, 2, ..., v integer
	return (v >= 1) and (v - v % 1) or (v <= -1) and 1/(-1*(v + (-1*v) % 1)) or 0
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
    input[1].stream = function (v)
		v = math.min(math.max(v, -10), 10)
		v = (v - 5) * 2
		if act == 0 then
			;(c2[cmd] or bad_cmd)(ch,v)--KEEP SEMICOLON!
		elseif act == 3 then
			set_ratio(ch, cmd_list[cmd], v)
			;(c2[cmd] or bad_cmd)(ch,v)--KEEP SEMICOLON!
		end
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

-- select ASL construct for a channel
function setup_synth(channel, model, shape)

    -- variable 2-stage wave|\ to /\ to /|
	function var_saw(shape) 
		return loop {
			to(  dyn{amp=2}, dyn{cyc=1/440} *    dyn{pw=1/2} , shape),
			to(0-dyn{amp=2}, dyn{cyc=1/440} * (1-dyn{pw=1/2}), shape)
		} 
	end	

	-- adding pw to x every stage, wrapping around and incrementing
	function bytebeat(shape)
		return loop { 
			to(dyn{x=1}:step(dyn{pw=1}):wrap(-20,20) * dyn{amp=2}, dyn{cyc=1}, shape)
		}
	end
	
	-- linear congruential generator (LCG) pseudo-random number generator X[n+1] = (a*X[n] + c) mod m
	function noise(shape) 
		return loop {
			to(dyn{x=1}:mul(dyn{pw2=1}):step(dyn{pw=1}):wrap(-10,10) * dyn{amp=2}, dyn{cyc=1}/2, shape)
		} 
	end
	
	-- use step() to frequency modulate the ASL stage time 
	function FMstep(shape)
		return loop { 
			to(  dyn{amp=2}, dyn{x=1}:step(dyn{pw2=1}):wrap(1,2) * dyn{cyc=1} * dyn{pw=1}, shape),
			to(0-dyn{amp=2}, dyn{x=1} * dyn{cyc=1} * (1-dyn{pw=1}), shape)
		}
	end
	
	-- root-product sine approximation y = x + 0.101321x^3
	function ASLsine(shape)
		return loop { 
			to((dyn{x=0}:step(dyn{pw=0.314}):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, shape)
		}
	end

	-- ASLsine with a mul(-1) applied to x
	function ASLharmonic(shape)
		return loop { 
			to((dyn{x=0}:step(dyn{pw=1}):mul(-1):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, shape)
		}
	end
	
	-- set crow output action to ASL construct then run action
    states[channel].mdl = model
	if model == 1 or model == 2 then 
		output[channel]( var_saw(shapes[shape]) )
	elseif model == 3 then
		output[channel]( bytebeat(shapes[shape]) )
	elseif model == 4 then
		output[channel]( noise(shapes[shape]) )
	elseif model == 5 then
		output[channel]( FMstep(shapes[shape]) )
	elseif model == 6 then
		output[channel]( ASLsine(shapes[shape]) )
	elseif model == 7 then
		output[channel]( ASLharmonic(shapes[shape]) )
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

		-- 86X: initialize outputs https://en.wikipedia.org/wiki/86_(term)
		if param == 86 then
			if digits[1] == 0 then
				for i = 1, 4 do
					setup_state(i)
					setup_synth(i, 1, 1)
				end	
			else
				setup_state(channel)
				setup_synth(channel, 1, 1)
			end

		-- turn on / off clock for a channel
		elseif param == 40 then
			if clock_enable[channel] == 0 then
				clock_enable[channel] = 1
				clock_ID[channel] = clock.run(trigger_seq, channel)
			else
				clock_enable[channel] = 0	
				clock.cancel(clock_ID[channel])			
			end

		-- 0: map input 1 voltage to (ch, cmd)
		elseif action == 0 then
            ch  = channel
            cmd = param
			act = action
            print("input 1 mapping to ch "..ch.." command "..cmd)

		-- 1: set channel, synth engine, and shape
        elseif action == 1 then
            print("setting ch "..channel.." to eng "..digits[2].." to shape "..digits[3])
            setup_synth(channel, digits[2], digits[3])
		
		-- 3: set ch ratio
        elseif action == 3 then
			print("setting ch "..channel.." parameter "..param.." to channel 1 ratio")
			ch  = channel
			cmd = param
			act = action
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
			value = math.min(math.max(value, -10), 10)
			print("setting param "..param.." on channel "..channel.." to value "..value)
			c2[param](channel, value) 
			update_synth(channel)
			
		-- set global synth update time
		-- 0.002 - 0.1 sec time range from V -10 or V 10 in TT, initial is 0.003
		elseif param == 99 then
			value = (u16_to_v10(value) + 10) / 20 * (0.1 - 0.002) + 0.002
			value = math.min(math.max(value, 0.002), 0.1)
			print("setting input stream update time to "..value)
			input[1]{mode = 'stream', time = value}
		else
			bad_cmd(channel, value) 
		end
    end
	
	-- CROW.C3 x y z -- (channel) (note) (volume)
    ii.self.call3 = function (ch, note, vol)
        if ch == nil or note == nil or vol == nil or ch < 1 or ch > 4 then 
            return 
        end
		set_state(ch, 'nte', u16_to_v10(note))
		set_state(ch, 'amp', u16_to_v10(vol))
        trigger_note(ch)
    end
end

function set_state(ch, key, value, step)
	step = step or 0
	if ch == 1 then
		if step ~= 0 then 
			states[1][key][step] = value
			-- to do ratio steps
		else
			states[1][key] = value 
			for i = 2,4 do
				-- ratio not 0 means ratio of channel 1
				if (ratios[i][key] ~= nil) and (ratios[i][key] ~= 0) then 
					states[i][key] = states[1][key] * ratios[i][key]
				end
			end
		end
	-- ratio of 0 means independent of channel 1
	elseif ratios[ch][key] ~= nil then
		if ratios[ch][key] == 0 then
			states[ch][key] = value
		else
			states[ch][key] = states[1][key] * ratios[ch][key]
		end
	else -- ch 2-4 states
		if step ~= 0 then 
			states[ch][key][step] = value
		else
			states[ch][key] = value
		end
	end
end

-- set ratio to channel 1
function set_ratio(ch, key, value)
	if ratios[ch][key] ~= nil then
		ratios[ch][key] = v10_to_ratio(value)
	end
end

-- initialize state array for each output
function setup_state(ch)
    states[ch] = {
        nte = 0, -- note (for frequency calculation)
        amp = 2, -- amplitude of oscillator
        pw  = 0, -- pulse width variable 1
        pw2 = 4, -- extra parameter for affecting ASL oscillators
		bit = 0, -- quantizer v/oct scaling amount
        mdl = 1, -- model number
		
		-- ENVELOPE AMP
		afr = 4, -- decay time
		asy = -1, -- symmetry
		acr = 3, -- exponent for peak function (curve)
		apw = 0, -- pulse width
		ant = 0, -- note
		aph = 1, -- phase
		atype = false,
			
		-- ENVELOPE PITCH
        efr = 1, -- cycle length
		esy = -1, -- pulse width or symmetry
		ecr = 4, -- exponent for peak function (curve)
		epw = 0, -- pulse width
		ent = 0, -- note 
		eph = 1, -- phase 
		etype = false,
        
		-- LFO
		lfr = 5, -- frequency 
		lsy = 0, -- symmetry
		lcr = 0, -- curvature
		lpw = 0, -- pulse width
		lnt = 0, -- note
		lph = -1, -- phase
		ltype = true,
				
		-- TRIG SEQUENCER
		t_len = sq{1, 3},
		t_rep = sq{3, 3},
    }
	ratios[ch] = {
        nte = 0, -- note (for frequency calculation)
        amp = 0, -- amplitude of oscillator
        pw  = 0, -- pulse width variable 1
        pw2 = 0, -- extra parameter for affecting ASL oscillators
		bit = 0, -- quantizer v/oct scaling amount
        mdl = 0, -- model number
		
		-- ENVELOPE AMP
		afr = 0, -- decay time
		asy = 0, -- symmetry
		acr = 0, -- exponent for peak function (curve)
		apw = 0, -- pulse width
		ant = 0, -- note
		aph = 0, -- phase
			
		-- ENVELOPE PITCH
        efr = 0, -- cycle length
		esy = 0, -- pulse width or symmetry
		ecr = 0, -- exponent for peak function (curve)
		epw = 0, -- pulse width
		ent = 0, -- note 
		eph = 0, -- phase 
        
		-- LFO
		lfr = 0, -- frequency 
		lsy = 0, -- symmetry
		lcr = 0, -- curvature
		lpw = 0, -- pulse width
		lnt = 0, -- note
		lph = 0, -- phase
    }
end

-- assume ph and pw between {-1..1} incl
function peak(ph, pw, curve)
    local value = (ph < pw) and ((1 + ph) / (1 + pw))
        or (ph > pw) and ((1 - ph) / (1 - pw))
        or 1
    value = value ^ (2 ^ curve)
    return value
end

-- step through phase from -1 to +1
function acc(phase, freq, sec, looping)
    phase = phase + (freq * sec)
    phase = looping and ((1 + phase) % 2 - 1) or math.min(1, phase)
    return phase
end

-- reset phase of envelopes on a channel
function trigger_note(ch)
    -- do not retrigger if we're in attack
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
	
	-- AMPLITUDE ENV 
	s.aph = acc(s.aph, s.afr, sec, s.atype)
    local ampenv = peak(s.aph, s.asy, s.acr) 

    -- FREQUENCY ENV
    s.eph = acc(s.eph, s.efr, sec, s.etype)
    local modenv = peak(s.eph, s.esy, s.ecr)

    -- LFO
    s.lph = acc(s.lph, s.lfr, sec, s.ltype)
    local lfo = peak(s.lph, s.lsy, s.lcr)

    -- FREQ & TIME for ASL stages
    local note = s.nte + (modenv * s.ent) + (lfo * s.lnt) + (ampenv * s.ant)
    local freq = v8_to_freq(note)
	freq = math.min(math.max(freq, 0.0001), 20000)
	local cyc = 1/freq
	if s.mdl == 2 then
		norm_cyc = cyc/0.1
		if math.random()*0.1 < norm_cyc then
			output[i].dyn.cyc = cyc + (cyc * 0.2 * math.random())
		else
			output[i].dyn.cyc = cyc + math.random()*0.002
		end
	else
		output[i].dyn.cyc = cyc
	end
	
    -- AMP
	output[i].dyn.amp = ampenv * s.amp
	
	-- BIT 
	if s.bit <= 0 then
		output[i].scale('none')
	else
		output[i].scale({}, 2, s.bit * 3)
	end

    -- PW
	local pw = s.pw + (modenv * s.epw) + (lfo * s.lpw) + (ampenv * s.apw)
	pw = math.min(math.max(pw, -1), 1)
	pw = (pw + 1) / 2
	if s.mdl == 3 or s.mdl == 6 or s.mdl == 7 then
		output[i].dyn.pw = pw * s.pw2
	elseif s.mdl == 4 then
		output[i].dyn.pw = pw
		output[i].dyn.pw2 = s.pw2
	elseif s.mdl == 5 then
		output[i].dyn.pw = pw
		output[i].dyn.pw2 = s.pw2 / 50		
	else
		output[i].dyn.pw = pw
    end	
end

function trigger_seq(i)
	local rep_count = 0
	local t_len = states[i].t_len[1]
	local t_rep = states[i].t_rep[1]
	while clock_enable[i] == 1 do
		if rep_count >= t_rep then
			rep_count = 0;
			t_len = states[i].t_len()
			t_rep = states[i].t_rep()
		end
		trigger_note(i)
		rep_count = rep_count + 1
		clock.sync(t_len)
	end
end

function init()
	clock.tempo = 300
	for i = 1, 4 do
		setup_state(i)
		setup_synth(i, 1, 1)
	end	
	setup_i2c()
	setup_input()
	print("setup complete!")
end 