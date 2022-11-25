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
local setup_dividing_param = function (index, param_name, divisor) 
    cmd_list[index] = param_name
    c2[index] = function (ch, v) set_state(ch, param_name, v / divisor) end
end
cmd_list[00] = 'deselect' -- Frees the input voltage from mapping anything
c2[00] = function (ch, v)
end
setup_dividing_param(1, 'pw', 10) -- model pw timbre (bug w/ model 1 when pw = 16250 ?)
setup_dividing_param(2, 'pw2', 1) -- extra pw2 param, varying use case
cmd_list[3] = 'bit' -- quantizer v/oct scaling amount
c2[3] = function (ch, v)
	if v <= 0 then v = 0 end
    set_state(ch, 'bit', v)
end
cmd_list[11] = 'efr' -- ENV frequency (Hz*10) Hz*10 (-lp)
c2[11] = function (ch, v)
	set_state(ch, 'efr', 
	(v <= 9.5) and (2 ^ (0 - v*0.7)) or
	(v >  9.5) and 0.0000000002328)-- 2^-32 billions and billions
end
setup_dividing_param(12, 'esy', 1) -- ENV symmetry (A:D)
setup_dividing_param(13, 'ecr', 2) -- ENV curvature
setup_dividing_param(14, 'epw', 5) -- ENV pw timbre
setup_dividing_param(15, 'ent', 1) -- ENV depth
cmd_list[16] = 'etype' -- ENV type
c2[16] = function (ch, v)
	local flag = (v <= 0) and false or (v > 0) and true
	set_state(ch, 'etype', flag)
end
cmd_list[21] = 'lfr' -- LFO spd (Hz*10) Hz*10 (+rst)
c2[21] = function (ch, v)
	set_state(ch, 'lfr', 
	(v >  -9.5) and (2 ^ v) or
	(v <= -9.5) and 0.0000000002328)
end
setup_dividing_param(22, 'lsy', 5) -- LFO symmetry (R:F) 
setup_dividing_param(23, 'lcr', 2) -- LFO curvature 
setup_dividing_param(24, 'lpw', 1) -- LFO pulse width 
setup_dividing_param(25, 'lnt', 1) -- LFO DEPTH
cmd_list[26] = 'ltype' -- LFO type
c2[26] = function (ch, v)
	local flag = (v <= 0) and false or (v > 0) and true
	set_state(ch, 'ltype', flag)
end
cmd_list[31] = 'afr' -- AMP ENV frequency (Hz*10) Hz*10 (-lp)
c2[31] = function (ch, v)
	set_state(ch, 'afr', 
	(v <= 9.5) and (2 ^ (0 - v*0.7)) or
	(v >  9.5) and 0.0000000002328)
end
setup_dividing_param(32, 'asy', 5) -- AMP ENV symmetry (A:D)
setup_dividing_param(33, 'acr', 2) -- AMP ENV curvature
setup_dividing_param(34, 'apw', 5) -- AMP ENV pw timbre
setup_dividing_param(35, 'apw', 1) -- AMP ENV depth
cmd_list[36] = 'atype' -- AMP ENV type
c2[36] = function (ch, v)
	local flag = (v <= 0) and false or (v > 0) and true
	set_state(ch, 'atype', flag)
end
cmd_list[41] = 't_len' -- TRIG
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
function  v8_to_freq(v8) return 261.61 * (2 ^ v8) end -- Tyler's Mordax said JF 0V = 261.61 : -5v - +5v = 8.17Hz - 8.37kHz.
function v10_to_int(v) return (v >= 1) and (v - v % 1) or (v <= -1) and (-1*(v + (-1*v) % 1)) or 0 end
function v10_to_ratio(v) return (v >= 1) and (v - v % 1) or (v <= -1) and 1/(-1*(v + (-1*v) % 1)) or 0 end -- any number input, returns 1/(v integer), ..., 1/2, 1/1, 0, 1, 2, ..., v integer
function get_digits(b1) -- TT variables -32768..+32767 so 5 digit maximum
	local digits = {}
	for i = 1, 5 do digits[i] = b1 % 10; b1 = (b1 - digits[i]) / 10 end
	return digits
end
function setup_input() -- input 1 stream to update all the synths in a loop
    input[1].stream = function (v)
		v = math.min(math.max(v, -10), 10)
		v = (v - 5) * 2
		if act == 0 then
			;(c2[cmd] or bad_cmd)(ch,v)--KEEP SEMICOLON!
		elseif act == 3 then
			set_ratio(ch, cmd_list[cmd], v)
			;(c2[cmd] or bad_cmd)(ch,v)--KEEP SEMICOLON!
		end
		for i = 1, 4 do if i ~= nil then update_synth(i) end end
    end
    input[1]{mode = 'stream', time = 0.003}
    input[2].stream = function (v) collectgarbage("collect") end
    input[2]{mode = 'stream', time = 10}
end

function setup_synth(channel, model, shape) -- select ASL construct for a channel
	function var_saw(shape) -- variable 2-stage wave|\ to /\ to /|
		return loop {
			to(  dyn{amp=2}, dyn{cyc=1/440} *    dyn{pw=1/2} , shape),
			to(0-dyn{amp=2}, dyn{cyc=1/440} * (1-dyn{pw=1/2}), shape)
		} 
	end	
	function bytebeat(shape) -- adding pw to x every stage, wrapping around and incrementing
		return loop { 
			to(dyn{x=1}:step(dyn{pw=1}):wrap(-20,20) * dyn{amp=2}, dyn{cyc=1}, shape)
		}
	end
	function noise(shape) -- linear congruential generator (LCG) pseudo-random number generator X[n+1] = (a*X[n] + c) mod m
		return loop {
			to(dyn{x=1}:mul(dyn{pw2=1}):step(dyn{pw=1}):wrap(-10,10) * dyn{amp=2}, dyn{cyc=1}/2, shape)
		} 
	end
	function FMstep(shape) -- use step() to frequency modulate the ASL stage time 
		return loop { 
			to(  dyn{amp=2}, dyn{x=1}:step(dyn{pw2=1}):wrap(1,2) * dyn{cyc=1} * dyn{pw=1}, shape),
			to(0-dyn{amp=2}, dyn{x=1} * dyn{cyc=1} * (1-dyn{pw=1}), shape)
		}
	end
	function ASLsine(shape) -- root-product sine approximation y = x + 0.101321x^3
		return loop { 
			to((dyn{x=0}:step(dyn{pw=0.314}):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, shape)
		}
	end
	function ASLharmonic(shape) -- ASLsine with a mul(-1) applied to x
		return loop { 
			to((dyn{x=0}:step(dyn{pw=1}):mul(-1):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, shape)
		}
	end
    states[channel].mdl = model -- set crow output action to ASL construct then run action
	if model == 1 or model == 2 then output[channel]( var_saw(shapes[shape]) )
	elseif model == 3 then output[channel]( bytebeat(shapes[shape]) )
	elseif model == 4 then output[channel]( noise(shapes[shape]) )
	elseif model == 5 then output[channel]( FMstep(shapes[shape]) )
	elseif model == 6 then output[channel]( ASLsine(shapes[shape]) )
	elseif model == 7 then output[channel]( ASLharmonic(shapes[shape]) ) end
end
function setup_i2c() -- initialize i2c function calls for teletype
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
		if param == 86 then -- 86X: initialize outputs https://en.wikipedia.org/wiki/86_(term)
			if digits[1] == 0 then
				for i = 1, 4 do
					setup_state(i)
					setup_synth(i, 1, 1)
				end	
			else
				setup_state(channel)
				setup_synth(channel, 1, 1)
			end
		elseif param == 40 then -- turn on / off clock for a channel
			if clock_enable[channel] == 0 then
				clock_enable[channel] = 1
				clock_ID[channel] = clock.run(trigger_seq, channel)
			else
				clock_enable[channel] = 0	
				clock.cancel(clock_ID[channel])			
			end
		elseif action == 0 then -- 0: map input 1 voltage to (ch, cmd)
            ch  = channel
            cmd = param
			act = action
            print("input 1 mapping to ch "..ch.." command "..cmd)
        elseif action == 1 then -- 1: set channel, synth engine, and shape
            print("setting ch "..channel.." to eng "..digits[2].." to shape "..digits[3])
            setup_synth(channel, digits[2], digits[3])
        elseif action == 3 then -- 3: set ch ratio
			print("setting ch "..channel.." parameter "..param.." to channel 1 ratio")
			ch  = channel
			cmd = param
			act = action
        end
    end
    ii.self.call2 = function (b1, value) -- CROW.C2 x y -- set <mod source, mod parameter, channel> to <value>
        digits = get_digits(b1)
		local action  = (digits[5] * 10) + digits[4]
		local param   = (digits[3] * 10) + digits[2]
		local channel = (digits[1] % 10 % 4)
        channel = (channel == 0 and 4) or channel
		if param < 36 then -- set a parameter value directly
			value = (u16_to_v10(value) - 5) * 2
			value = math.min(math.max(value, -10), 10)
			print("setting param "..param.." on channel "..channel.." to value "..value)
			c2[param](channel, value) 
			update_synth(channel)
		-- set global synth update time
		elseif param == 99 then -- 0.002 - 0.1 sec time range from V -10 or V 10 in TT, initial is 0.003
			value = (u16_to_v10(value) + 10) / 20 * (0.1 - 0.002) + 0.002
			value = math.min(math.max(value, 0.002), 0.1)
			print("setting input stream update time to "..value)
			input[1]{mode = 'stream', time = value}
		else
			bad_cmd(channel, value) 
		end
    end
    ii.self.call3 = function (ch, note, vol) -- CROW.C3 x y z -- (channel) (note) (volume)
        if ch == nil or note == nil or vol == nil or ch < 1 or ch > 4 then return end
		set_state(ch, 'nte', u16_to_v10(note))
		set_state(ch, 'amp', u16_to_v10(vol))
        trigger_note(ch)
    end
end
function set_state(ch, key, value, step)
	step = step or 0
	if ch == 1 then
		if step ~= 0 then 
			states[1][key][step] = value -- to do ratio steps
		else
			states[1][key] = value 
			for i = 2,4 do -- ratio not 0 means ratio of channel 1
				if (ratios[i][key] ~= nil) and (ratios[i][key] ~= 0) then states[i][key] = states[1][key] * ratios[i][key] end
			end
		end
	elseif ratios[ch][key] ~= nil then -- ratio of 0 means independent of channel 1
		if ratios[ch][key] == 0 then states[ch][key] = value
		else states[ch][key] = states[1][key] * ratios[ch][key] end
	else -- ch 2-4 states
		if step ~= 0 then states[ch][key][step] = value
		else states[ch][key] = value end
	end
end
function set_ratio(ch, key, value) -- set ratio to channel 1
	if ratios[ch][key] ~= nil then ratios[ch][key] = v10_to_ratio(value) end
end
function setup_state(ch) -- initialize state array for each output
    states[ch] = {
        nte = 0, amp = 2, pw  = 0, pw2 = 4, bit = 0, mdl = 1,
		afr = 4, asy = -1, acr = 3, apw = 0, ant = 0, aph = 1, atype = false, -- ENVELOPE AMP
        efr = 1, esy = -1, ecr = 4, epw = 0, ent = 0, eph = 1, etype = false, -- ENVELOPE PITCH
		lfr = 5, lsy = 0, lcr = 0, lpw = 0, lnt = 0, lph = -1, ltype = true, -- LFO
		t_len = sq{1, 3}, t_rep = sq{3, 3}, -- TRIG SEQUENCER
    }
	ratios[ch] = {
        nte = 0, amp = 0, pw  = 0, pw2 = 0, bit = 0, mdl = 0,
		afr = 0, asy = 0, acr = 0, apw = 0, ant = 0, aph = 0, -- ENVELOPE AMP
        efr = 0, esy = 0, ecr = 0, epw = 0, ent = 0, eph = 0, -- ENVELOPE PITCH
		lfr = 0, lsy = 0, lcr = 0, lpw = 0, lnt = 0, lph = 0, -- LFO
    }
end
function peak(ph, pw, curve) -- assume ph and pw between {-1..1} incl
    local value = (ph < pw) and ((1 + ph) / (1 + pw))
        or (ph > pw) and ((1 - ph) / (1 - pw))
        or 1
    value = value ^ (2 ^ curve)
    return value
end
function acc(phase, freq, sec, looping) -- step through phase from -1 to +1
    phase = phase + (freq * sec)
    phase = looping and ((1 + phase) % 2 - 1) or math.min(1, phase)
    return phase
end
function trigger_note(ch) -- reset phase of envelopes on a channel
    if states[ch].eph >= states[ch].esy then states[ch].eph = -1 end -- do not retrigger if we're in attack
	if states[ch].aph >= states[ch].asy then states[ch].aph = -1 end
end
function update_synth(i) -- get state parameters, set output
    local s = states[i]
    local sec = input[1].time
	s.aph = acc(s.aph, s.afr, sec, s.atype) -- AMPLITUDE ENV 
    local ampenv = peak(s.aph, s.asy, s.acr) 
    s.eph = acc(s.eph, s.efr, sec, s.etype) -- FREQUENCY ENV
    local modenv = peak(s.eph, s.esy, s.ecr)
    s.lph = acc(s.lph, s.lfr, sec, s.ltype) -- LFO
    local lfo = peak(s.lph, s.lsy, s.lcr)
    local note = s.nte + (modenv * s.ent) + (lfo * s.lnt) + (ampenv * s.ant) -- FREQ & TIME for ASL stages
    local freq = v8_to_freq(note)
	freq = math.min(math.max(freq, 0.0001), 20000)
	local cyc = 1/freq
	if s.mdl == 2 then
		norm_cyc = cyc/0.1
		if math.random()*0.1 < norm_cyc then output[i].dyn.cyc = cyc + (cyc * 0.2 * math.random())
		else output[i].dyn.cyc = cyc + math.random()*0.002 end
	else output[i].dyn.cyc = cyc end
	output[i].dyn.amp = ampenv * s.amp -- AMP
	if s.bit <= 0 then output[i].scale('none') -- BIT 
	else output[i].scale({}, 2, s.bit * 3) end
	local pw = s.pw + (modenv * s.epw) + (lfo * s.lpw) + (ampenv * s.apw) -- PW
	pw = math.min(math.max(pw, -1), 1)
	pw = (pw + 1) / 2
	if s.mdl == 3 or s.mdl == 6 or s.mdl == 7 then output[i].dyn.pw = pw * s.pw2
	elseif s.mdl == 4 then
		output[i].dyn.pw = pw
		output[i].dyn.pw2 = s.pw2
	elseif s.mdl == 5 then
		output[i].dyn.pw = pw
		output[i].dyn.pw2 = s.pw2 / 50		
	else output[i].dyn.pw = pw end	
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
