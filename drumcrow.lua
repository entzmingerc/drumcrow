--- drumcrow
states = {}
ratios = {}
channel = 1
parameter = 0
c2 = {}
act = 0
shapes = {'linear','sine','logarithmic','exponential','now','wait','over','under','rebound'}
param_list = {}
clock_enable = {0, 0, 0, 0}
clock_ID = {}
function is_positive(v)  return (v > 0) and true or (v <= 0) and false end
function v10_to_int(v)   return (v >= 1) and (v - v % 1) or (v <= -1) and   (-1*(v + (-1*v) % 1)) or 0 end --   v, ...,   2,   1, 0, 1, 2, ..., v 
function v10_to_ratio(v) return (v >= 1) and (v - v % 1) or (v <= -1) and 1/(-1*(v + (-1*v) % 1)) or 0 end -- 1/v, ..., 1/2, 1/1, 0, 1, 2, ..., v 
function make_divide(divisor) return function (x) return x / divisor end end
function make_rectify_right(thresh, out_coeff, static)
	return function (v) return (v <= thresh) and (2 ^ (v*out_coeff)) or (v > thresh) and static end
end
function make_rectify_left(thresh, out_coeff, static)
	return function (v) return (v >= thresh) and (2 ^ (v*out_coeff)) or (v < thresh) and static end
end
function setup_hof_param (index, param_name, fn)
	param_list[index] = param_name
	c2[index] = function (ch, v) set_state(ch, param_name, fn(v)) end
end
local bad_param = function (ch, v) end 
setup_hof_param(1, 'nte', make_divide(1))
setup_hof_param(2, 'amp', make_divide(2)) -- negative a problem?
setup_hof_param(3, 'pw', make_divide(10))
setup_hof_param(4, 'pw2', make_divide(1)) 
param_list[5] = 'bit'
c2[5] = function (ch, v) if v <= 0 then v = 0 end; set_state(ch, 'bit', v) end
setup_hof_param(11, 'ent', make_divide(1))
setup_hof_param(12, 'eamp', make_divide(1))
setup_hof_param(13, 'epw', make_divide(5))
setup_hof_param(14, 'epw2', make_divide(1))
setup_hof_param(15, 'ebit', make_divide(1))
setup_hof_param(16, 'efr', make_rectify_right(9.5, -0.7, 0.0000000002328))
setup_hof_param(17, 'esy', make_divide(1))
setup_hof_param(18, 'ecr', make_divide(2))
setup_hof_param(19, 'etype', make_divide(1))
setup_hof_param(21, 'lnt', make_divide(1))
setup_hof_param(22, 'lamp', make_divide(1))
setup_hof_param(23, 'lpw', make_divide(1))
setup_hof_param(24, 'lpw2', make_divide(1))
setup_hof_param(25, 'lbit', make_divide(1))
setup_hof_param(26, 'lfr', make_rectify_left(-9.5, 1, 0.0000000002328))
setup_hof_param(27, 'lsy', make_divide(5))
setup_hof_param(28, 'lcr', make_divide(2))
setup_hof_param(29, 'ltype', make_divide(1))
setup_hof_param(31, 'ant', make_divide(1))
setup_hof_param(32, 'aamp', make_divide(1))
setup_hof_param(33, 'apw', make_divide(5))
setup_hof_param(34, 'apw2', make_divide(1))
setup_hof_param(35, 'abit', make_divide(1))
setup_hof_param(36, 'afr', make_rectify_right(9.5, -0.7, 0.0000000002328))
setup_hof_param(37, 'asy', make_divide(5))
setup_hof_param(38, 'acr', make_divide(2))
setup_hof_param(39, 'atype', make_divide(1))
setup_hof_param(41, 'tlenA', v10_to_ratio)
setup_hof_param(42, 'trepA', v10_to_int)
setup_hof_param(43, 'tlenB', v10_to_ratio)
setup_hof_param(44, 'trepB', v10_to_int)
-- setup_hof_param(45, 'hlenA', v10_to_ratio)
-- setup_hof_param(46, 'hrepA', v10_to_int)
-- setup_hof_param(47, 'hlenB', v10_to_ratio)
-- setup_hof_param(48, 'hrepB', v10_to_int)
setup_hof_param(49, 'ttype', make_divide(1))
param_list[81] = 'tempo' -- 10 to 2010 Tempo BPM
c2[81] = function (ch, v) clock.tempo = (v+10.1) * 100 end
param_list[82] = 'update_time' -- 0.002 to 0.1 sec
c2[82] = function (ch, v) 
	v = (v + 10) / 20 * (0.1 - 0.002) + 0.002 
	input[1]{mode = 'stream', time = v} 
end
function u16_to_v10(u16) return u16/16384*10 end -- -32768 to +32767
function get_digits(b1) -- TT variables -32768..+32767 so 5 digit maximum
	local digits = {}
	for i = 1, 5 do 
		digits[i] = b1 % 10
		b1 = (b1 - digits[i]) / 10
	end
	local action = (digits[5] * 10) + digits[4]
	local param = (digits[3] * 10) + digits[2]
	local ch = digits[1] % 5
	return digits, action, param, ch
end
function setup_input()
	input[1].stream = function (v)
		v = (math.min(math.max(v, -10), 10) - 5) * 2
		if act == 1 then
			set_ratio(channel, param_list[parameter], v)
		end
		;(c2[parameter] or bad_param)(channel,v)--KEEP SEMICOLON!
		for i = 1, 4 do if i ~= nil then update_synth(i) end end
	end
	input[1]{mode = 'stream', time = 0.003}
end

function setup_synth(ch, model, shape) -- select ASL construct for a channel
	function var_saw(shape) -- variable 2-stage wave|\ to /\ to /|
		return loop { to(  dyn{amp=2}, dyn{cyc=1/440} * dyn{pw=1/2}, shape), to(0-dyn{amp=2}, dyn{cyc=1/440} * (1-dyn{pw=1/2}), shape) } 
	end	
	function bytebeat(shape) -- adding pw to x every stage, wrapping around and incrementing
		return loop { to(dyn{x=1}:step(dyn{pw=1}):wrap(-20,20) * dyn{amp=2}, dyn{cyc=1}, shape) }
	end
	function noise(shape) -- linear congruential generator (LCG) pseudo-random number generator X[n+1] = (a*X[n] + c) mod m
		return loop { to(dyn{x=1}:mul(dyn{pw2=1}):step(dyn{pw=1}):wrap(-10,10) * dyn{amp=2}, dyn{cyc=1}/2, shape) } 
	end
	function FMstep(shape) -- use step() to frequency modulate the ASL stage time 
		return loop { 
			to(  dyn{amp=2}, dyn{x=1}:step(dyn{pw2=1}):wrap(1,2) * dyn{cyc=1} * dyn{pw=1}, shape),
			to(0-dyn{amp=2}, dyn{x=1} * dyn{cyc=1} * (1-dyn{pw=1}), shape)
		}
	end
	function ASLsine(shape) -- root-product sine approximation y = x + 0.101321x^3
		return loop { to((dyn{x=0}:step(dyn{pw=0.314}):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, shape) }
	end
	function ASLharmonic(shape) -- ASLsine with a mul(-1) applied to x
		return loop { to((dyn{x=0}:step(dyn{pw=1}):mul(-1):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, shape) }
	end
	states[ch].mdl = model -- set crow output action to ASL construct then run action
	if model == 1 or model == 2 then output[ch]( var_saw(shapes[shape]) )
	elseif model == 3 then output[ch]( bytebeat(shapes[shape]) )
	elseif model == 4 then output[ch]( noise(shapes[shape]) )
	elseif model == 5 then output[ch]( FMstep(shapes[shape]) )
	elseif model == 6 then output[ch]( ASLsine(shapes[shape]) )
	elseif model == 7 then output[ch]( ASLharmonic(shapes[shape]) ) end
end
function setup_i2c()
	ii.self.call1 = function (b1) -- CROW.C1 X, main input handler, b1 = ABCDE digits, AB action, CD param, E channel
		digits, action, param, ch = get_digits(b1)
		process_action(digits, action, param, ch, 1)
	end
	ii.self.call2 = function (b1, v) -- CROW.C2 x y, set param to value
		digits, action, param, ch = get_digits(b1)
		v = (u16_to_v10(v) - 5) * 2
		v = math.min(math.max(v, -10), 10)
		process_action(digits, action, param, ch, 2, v)
	end
	ii.self.call3 = function (ch, note, amp) -- CROW.C3 x y z, channel, note, amplitude
		if ch == nil or note == nil or amp == nil then return end
		ch = ch % 5;
		if ch == 0 then
			for i = 1,4 do
				states[i].nte = u16_to_v10(note)
				states[i].amp = u16_to_v10(amp)
				trigger_note(i)
			end
		else
			states[ch].nte = u16_to_v10(note)
			states[ch].amp = u16_to_v10(amp)
			trigger_note(ch)
		end
	end
end

function process_action(digits, action, param, ch, cmd, v)
	v = v or 0
	if action == 2 then -- 2: set new ASL construct (shape, model) keep act the same
		if ch == 0 then
			for i = 1, 4 do
				setup_synth(i, digits[2], digits[3])
			end
		else
			setup_synth(ch, digits[2], digits[3])
		end
		print("Setup Synth, Shape: "..digits[3].." Engine: "..digits[2].." Channel: "..ch)
	elseif action == 1 then -- 1: set ratio 
		if param == 86 then -- init
			if ch == 0 then
				for i = 1, 4 do
					setup_ratio(i)
					print("Init ratio: "..i)
				end	
			else
				setup_ratio(ch)
				print("Init ratio: "..ch)
			end
		elseif ch ~= 1 then
			if cmd == 1 then
				channel = ch; parameter = param; act = action
				print("Ratio to Ch1, Param: "..param.." Channel: "..ch)
			else
				set_ratio(ch, param_list[param], v)
				print("Ratio to Ch1, Param: "..param.." Channel: "..ch)
			end
		else
			channel = 1; parameter = 0; act = 0
			print("Bad Channel - Deselect")
		end
	elseif action == 0 then -- 0: set state
		if param == 86 then -- init
			if ch == 0 then
				for i = 1, 4 do
					setup_state(i); setup_ratio(i); setup_synth(i, 1, 1)
					print("Init Channel: "..i)
				end	
			else
				setup_state(ch); setup_ratio(ch); setup_synth(ch, 1, 1)
				print("Init Channel: "..ch)
			end
		elseif param == 40 then -- TRIG enable/disable
			if ch == 0 then
				for i = 1, 4 do
					trig_enable(i, false)
					print("CLK ON/OFF Channel: "..ch)
				end
			else
				trig_enable(ch, false)
				print("CLK ON/OFF Channel: "..ch)
			end
		-- elseif param == 85 then -- reset hseq
		elseif param == 84 then -- reset tseq
			if ch == 0 then
				for i = 1, 4 do
					trig_enable(i, true)
					print("CLK Reset Channel: "..ch)
				end
			else
				trig_enable(ch, true)
				print("CLK Reset Channel: "..ch)
			end
		elseif param_list[param] ~= nil then -- set state 
			channel = ch; parameter = param; act = action
			print("INPUT to Param: "..param.." Channel: "..ch)
		else
			channel = 1; parameter = 0; act = 0
			print("Deselect")
		end
	else
		channel = 1; parameter = 0; act = 0
		print("Deselect")
	end
end 
function set_state(ch, key, value)
	if ch == 0 then
		if act == 1 then -- setting all ratios
			for i = 2,4 do
				if ratios[i][key] == 0 then
					states[i][key] = 0
				else
					states[i][key] = states[1][key] * ratios[i][key]
				end
			end
		else -- setting all states
			for i = 1,4 do
				if i == 1 then
					states[i][key] = value
				else
					if ratios[i][key] == 0 then
						states[i][key] = value
					else
						states[i][key] = states[1][key] * ratios[i][key]
					end
				end
			end
		end
	elseif ch ~= 1 then -- set a single channel 2-4
		if act == 1 then -- setting a ratio, updating a state
			if ratios[ch][key] == 0 then
				states[ch][key] = 0
			else
				states[ch][key] = states[1][key] * ratios[ch][key]
			end
		else -- setting a state
			if ratios[ch][key] == 0 then
				states[ch][key] = value
			else
				states[ch][key] = states[1][key] * ratios[ch][key]
			end
		end
	elseif ch == 1 then
		states[ch][key] = value
		for i = 2,4 do
			if ratios[i][key] ~= 0 then
				states[i][key] = states[1][key] * ratios[i][key]
			end
		end
	end
end	
function set_ratio(ch, key, v)
	local function check_ratio(chan, key)
		if ratios[chan][key] ~= nil then 
			if key == 'efr' or key == 'afr' or key == 'lfr' or key == 'tlenA' or key == 'tlenB' then
				ratios[chan][key] = v10_to_ratio(v)
			else
				ratios[chan][key] = math.floor(5*v)/10
			end
		end
	end
	if ch == 0 then
		for i = 2,4 do 
			check_ratio(i, key)
		end
	elseif ch ~= 1 then	
		check_ratio(ch, key)
	end
end
function setup_state(ch)
	states[ch] = {
		-- hlenA = 1, hlenB = 1, hrepA = 1, hrepB = 1, ttype = 0,
		tlenA = 1, tlenB = 2, trepA = 2, trepB = 2, 
		ant = 0, aamp = 1, apw = 0, apw2 = 0, abit = 0, afr = 4, asy = -1, acr = 3, atype = 0, aph = 1, 
		lnt = 0, lamp = 0, lpw = 0, lpw2 = 0, lbit = 0, lfr = 5, lsy = 0,  lcr = 0, ltype = 1, lph = -1, 
		ent = 0, eamp = 0, epw = 0, epw2 = 0, ebit = 0, efr = 1, esy = -1, ecr = 4, etype = 0, eph = 1, 
		nte = 0, amp = 2,  pw = 0,  pw2 = 4,  bit = 0,  mdl = 1,
	}
end
function setup_ratio(ch)
	ratios[ch] = {
		-- hlenA = 0, hlenB = 0, hrepA = 0, hrepB = 0, ttype = 0,
		tlenA = 0, tlenB = 0, trepA = 0, trepB = 0, 
		ant = 0, aamp = 0, apw = 0, apw2 = 0, abit = 0, afr = 0, asy = 0, acr = 0, atype = 0, aph = 0, 
		lnt = 0, lamp = 0, lpw = 0, lpw2 = 0, lbit = 0, lfr = 0, lsy = 0, lcr = 0, ltype = 0, lph = 0, 
		ent = 0, eamp = 0, epw = 0, epw2 = 0, ebit = 0, efr = 0, esy = 0, ecr = 0, etype = 0, eph = 0, 
		nte = 0, amp = 0,  pw = 0,  pw2 = 0,  bit = 0,  mdl = 0,
	}
end
function acc(phase, freq, sec, looping) -- step through phase from -1 to +1
	phase = phase + (freq * sec)
	phase = looping and ((1 + phase) % 2 - 1) or math.max(math.min(1, phase), -1)
	return phase
end
function peak(ph, pw, curve) -- assume ph and pw between {-1..1} incl
	local value = (ph < pw) and ((1 + ph) / (1 + pw))
		or (ph > pw) and ((1 - ph) / (1 - pw))
		or 1
	value = value ^ (2 ^ curve)
	return value
end
function trigger_note(ch) -- reset phase of envelopes on a channel
	if states[ch].eph >= states[ch].esy then states[ch].eph = -1 end -- do not retrigger if we're in attack
	if states[ch].aph >= states[ch].asy then states[ch].aph = -1 end
end
function update_synth(i) -- get state parameters, set output
	local s = states[i]
	local sec = input[1].time
	s.aph = acc(s.aph, s.afr, sec, is_positive(s.atype)) -- AMPLITUDE ENV 
	local ampenv = peak(s.aph, s.asy, s.acr)
	s.eph = acc(s.eph, s.efr, sec, is_positive(s.etype)) -- FREQUENCY ENV
	local modenv = peak(s.eph, s.esy, s.ecr)
	s.lph = acc(s.lph, s.lfr, sec, is_positive(s.ltype)) -- LFO
	local lfo = peak(s.lph, s.lsy, s.lcr)
	local note   = s.nte + (modenv * s.ent)  + (lfo * s.lnt)  + (ampenv * s.ant)
	local volume = (modenv * s.eamp * s.amp) + (lfo * s.lamp * s.amp) + (ampenv * s.aamp * s.amp)
	local pw     = s.pw  + (modenv * s.epw)  + (lfo * s.lpw)  + (ampenv * s.apw) 
	local pw2    = s.pw2 + (modenv * s.epw2) + (lfo * s.lpw2) + (ampenv * s.apw2) 
	local bitz   = s.bit + (modenv * s.ebit) + (lfo * s.lbit) + (ampenv * s.abit)
	local freq = 440
	if note > -8.03127 and note < 6.25643 then -- FREQ & TIME
		freq = math.min(math.max(261.61 * (2 ^ note), 1), 20000)
	elseif note >= 6.25643 then
		freq = 20000
	else
		freq = 1
	end
	-- local freq = math.min(math.max(261.61 * (2 ^ note), 1), 20000) -- Tyler's Mordax said JF 0V = 261.61 : -5v - +5v = 8.17Hz - 8.37kHz.
	local cyc = 1/freq
	if s.mdl == 2 then
		norm_cyc = cyc/0.1
		if math.random()*0.1 < norm_cyc then output[i].dyn.cyc = cyc + (cyc * 0.2 * math.random())
		else output[i].dyn.cyc = cyc + math.random()*0.002 end
	else output[i].dyn.cyc = cyc end
	output[i].dyn.amp = volume -- AMP
	if bitz <= 0 then output[i].scale('none') -- BIT 
	else output[i].scale({}, 2, bitz * 3) end
	pw = math.min(math.max(pw, -1), 1) -- PW
	pw = (pw + 1) / 2
	if s.mdl == 3 or s.mdl == 6 or s.mdl == 7 then output[i].dyn.pw = pw * pw2
	elseif s.mdl == 4 then
		output[i].dyn.pw = pw
		output[i].dyn.pw2 = pw2
	elseif s.mdl == 5 then
		output[i].dyn.pw = pw
		output[i].dyn.pw2 = pw2 / 50
	else output[i].dyn.pw = pw end	
end
function trigger_seq(i)
	local rep_count = 0
	local len_count = 1
	local tlen = states[i].tlenA
	local trep = states[i].trepA
	while clock_enable[i] == 1 do
		if rep_count >= trep then
			rep_count = 0;
			if len_count == 1 then
				tlen = states[i].tlenB
				trep = states[i].trepB
				len_count = 2;
			else
				tlen = states[i].tlenA
				trep = states[i].trepA
				len_count = 1;
			end
		end
		trigger_note(i)
		rep_count = rep_count + 1
		clock.sync(tlen)
	end
end
function trig_enable(ch, reset)
	if reset == false then -- on off
		if clock_enable[ch] == 0 then
			clock_enable[ch] = 1
			clock_ID[ch] = clock.run(trigger_seq, ch)
		else
			clock_enable[ch] = 0	
			clock.cancel(clock_ID[ch])
		end
	else -- reset
		clock_enable[ch] = 1
		clock.cancel(clock_ID[ch])	
		clock_ID[ch] = clock.run(trigger_seq, ch)
	end
end
function init()
	print("init!")
	clock.tempo = 300
	for i = 1, 4 do
		setup_state(i); setup_ratio(i); setup_synth(i, 1, 1)
	end	
	setup_i2c()
	setup_input()
	print("setup complete!")
end 
