--- drumcrow
states = {}
ratios = {}
caw_mult = {1, 1, 1, 1}
channel = 1
parameter = 0
c2 = {}
act = 0
shapes = {'linear','sine','logarithmic','exponential','now','wait','over','under','rebound'}
param_list = {}
clock_ID = {}
clock_on = {}
function is_positive(v) return (v > 0) and true or (v <= 0) and false end
function v10_to_int(v) return (v >= 1) and (v - v % 1) or (v <= -1) and   (-1*(v + (-1*v) % 1)) or 1 end
function v10_to_ratio(v) return (v >= 1) and math.floor(v) or (v >= -9) and 1/(-1*(math.floor(v)-1)) or 0 end
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
setup_hof_param(2, 'amp', make_divide(2))
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
setup_hof_param(45, 'caw1', v10_to_ratio)
setup_hof_param(46, 'caw2', v10_to_ratio)
setup_hof_param(47, 'caw3', v10_to_ratio)
setup_hof_param(48, 'caw4', v10_to_ratio)
setup_hof_param(49, 'ttype', make_divide(1))
param_list[81] = 'tempo'
c2[81] = function (ch, v) clock.tempo = (v+10.1) * 100 end
param_list[82] = 'update_time'
c2[82] = function (ch, v) 
	v = (v + 10) / 20 * (0.1 - 0.002) + 0.002 
	input[1]{mode = 'stream', time = v} 
end
function u16_to_v10(u16) return u16/16384*10 end
function get_digits(b1)
	local digits = {}
	for i = 1, 5 do digits[i] = b1 % 10; b1 = (b1 - digits[i]) / 10 end
	local action = (digits[5] * 10) + digits[4]
	local param = (digits[3] * 10) + digits[2]
	local ch = digits[1] % 5
	return digits, action, param, ch
end
function setup_input()
	input[1].stream = function (v)
		v = (math.min(math.max(v, -10), 10) - 5) * 2
		if act == 1 then set_ratio(channel, param_list[parameter], v) end
		;(c2[parameter] or bad_param)(channel,v)--KEEP SEMICOLON!
		for i = 1, 4 do if i ~= nil then update_synth(i) end end
	end
	input[1]{mode = 'stream', time = 0.003}
end
function setup_synth(ch, model, shape)
	function var_saw(shape)
		return loop { to(  dyn{amp=2}, dyn{cyc=1/440} * dyn{pw=1/2}, shape), to(0-dyn{amp=2}, dyn{cyc=1/440} * (1-dyn{pw=1/2}), shape) } 
	end	
	function bytebeat(shape)
		return loop { to(dyn{x=1}:step(dyn{pw=1}):wrap(-20,20) * dyn{amp=2}, dyn{cyc=1}, shape) }
	end
	function noise(shape)
		return loop { to(dyn{x=1}:mul(dyn{pw2=1}):step(dyn{pw=1}):wrap(-10,10) * dyn{amp=2}, dyn{cyc=1}/2, shape) } 
	end
	function FMstep(shape) 
		return loop { 
			to(  dyn{amp=2}, dyn{x=1}:step(dyn{pw2=1}):wrap(1,2) * dyn{cyc=1} * dyn{pw=1}, shape),
			to(0-dyn{amp=2}, dyn{x=1} * dyn{cyc=1} * (1-dyn{pw=1}), shape)
		}
	end
	function ASLsine(shape)
		return loop { to((dyn{x=0}:step(dyn{pw=0.314}):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, shape) }
	end
	function ASLharmonic(shape)
		return loop { to((dyn{x=0}:step(dyn{pw=1}):mul(-1):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, shape) }
	end
	states[ch].mdl = model
	if model == 1 or model == 2 then output[ch]( var_saw(shapes[shape]) )
	elseif model == 3 then output[ch]( bytebeat(shapes[shape]) )
	elseif model == 4 then output[ch]( noise(shapes[shape]) )
	elseif model == 5 then output[ch]( FMstep(shapes[shape]) )
	elseif model == 6 then output[ch]( ASLsine(shapes[shape]) )
	elseif model == 7 then output[ch]( ASLharmonic(shapes[shape]) ) end
end
function setup_i2c()
	ii.self.call1 = function (b1)
		digits, action, param, ch = get_digits(b1)
		process_action(digits, action, param, ch, 1)
	end
	ii.self.call2 = function (b1, v)
		digits, action, param, ch = get_digits(b1)
		v = (u16_to_v10(v) - 5) * 2
		v = math.min(math.max(v, -10), 10)
		print(" action "..action.." param "..param.." ch "..ch.." v "..v)
		process_action(digits, action, param, ch, 2, v)
	end
	ii.self.call3 = function (ch, note, amp)
		if ch == nil or note == nil or amp == nil then return end
		ch = ch % 5;
		if ch == 0 then
			set_state(1, 'nte', u16_to_v10(note), 3)
			set_state(1, 'amp', u16_to_v10(amp),  3)
			for i = 2,4 do
				if ratios[i].nte == 0 then set_state(i, 'nte', u16_to_v10(note), 3) end
				if ratios[i].amp == 0 then set_state(i, 'amp', u16_to_v10(amp),  3) end
				trigger_note(i)
			end
		else
			if ch ~= 1 then
				if ratios[ch].nte == 0 then set_state(ch, 'nte', u16_to_v10(note), 3) end
				if ratios[ch].amp == 0 then set_state(ch, 'amp', u16_to_v10(amp),  3) end
			else
				set_state(ch, 'nte', u16_to_v10(note), 3)
				set_state(ch, 'amp', u16_to_v10(amp),  3)
			end
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
				for i = 2, 4 do
					setup_ratio(i)
					print("Init ratio: "..i)
				end	
			elseif ch ~= 1 then
				setup_ratio(ch)
				print("Init ratio: "..ch)
			end
		elseif ch ~= 1 then
			if cmd == 1 then
				channel = ch; parameter = param; act = action
			else
				set_ratio(ch, param_list[param], v)
			end
			print("Ratio to Ch1, Param: "..param.." Channel: "..ch)
		else
			channel = 1; parameter = 0; act = 0
			print("Deselect")
		end
	elseif action == 0 then -- 0: set state
		if param == 86 then -- init
			if ch == 0 then
				for i = 1, 4 do
					setup_state(i); setup_synth(i, 1, 1)
					print("Init Channel: "..i)
				end	
			else
				setup_state(ch); setup_synth(ch, 1, 1)
				print("Init Channel: "..ch)
			end
		elseif param == 84 then -- reset tseq
			if ch == 0 then
				for i = 1, 4 do
					trig_enable(i, true, 41)
					print("CLK Reset Channel: "..i)
				end
			else
				trig_enable(ch, true, 41)
				print("CLK Reset Channel: "..ch)
			end
		elseif param == 40 then -- TRIG enable/disable
			if ch == 0 then
				for i = 1, 4 do
					trig_enable(i, false, 41)
					print("CLK ON/OFF Channel: "..i)
				end
			else
				trig_enable(ch, false, 41)
				print("CLK ON/OFF Channel: "..ch)
			end
		elseif param_list[param] ~= nil then -- set state 
			if cmd == 2 then
				set_state(ch, param_list[param], v, 2)
			else
				channel = ch; parameter = param; act = action
			end
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
function set_state(ch, key, v, cmd)
	local function check_ratio_zero(ch, key, value)
		if ratios[ch][key] == 0 then
			states[ch][key] = value
		else
			if key ~= 'nte' then
				states[ch][key] = states[1][key] * ratios[ch][key]
			end
		end
	end
	local cmd = cmd or 0
	if ch == 0 then
		if act == 1 then
			for i = 2,4 do
				check_ratio_zero(i, key, 0)
			end
		else -- setting all states
			for i = 1,4 do
				if i == 1 then
					states[i][key] = v
				else
					check_ratio_zero(i, key, v)
				end
			end
		end
	elseif ch ~= 1 then -- set a single channel 2-4
		if act == 1 then -- setting a ratio, updating a state
			if cmd == 3 then
				check_ratio_zero(ch, key, v)
			else
				check_ratio_zero(ch, key, 0)
			end
		else -- setting a state
			check_ratio_zero(ch, key, v)
		end
	elseif ch == 1 then
		states[ch][key] = v
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
			if key == 'nte' or key == 'efr' or key == 'afr' or key == 'lfr' 
			or key == 'tlenA' or key == 'trepA' or key == 'trepB' or key == 'tlenB' then
				ratios[chan][key] = v10_to_ratio(v)
			else
				ratios[chan][key] = math.floor(5*v)/10
			end
		end
	end
	if ch == 0 then for i = 2,4 do check_ratio(i, key) end
	elseif ch ~= 1 then check_ratio(ch, key) end
end
function setup_state(ch)
	states[ch] = {
		tlenA = 1, trepA = 2, tlenB = 2, trepB = 2, caw1 = 1, caw2 = 1, caw3 = 1, caw4 = 1, 
		ant = 0, aamp = 1, apw = 0, apw2 = 0, abit = 0, afr = 4, asy = -1, acr = 3, atype = 0, aph = 1, 
		lnt = 0, lamp = 0, lpw = 0, lpw2 = 0, lbit = 0, lfr = 5, lsy = 0,  lcr = 0, ltype = 1, lph = -1, 
		ent = 0, eamp = 0, epw = 0, epw2 = 0, ebit = 0, efr = 1, esy = -1, ecr = 4, etype = 0, eph = 1, 
		nte = 0, amp = 2,  pw = 0,  pw2 = 4,  bit = 0, mdl = 1,
	}
end
function setup_ratio(ch)
	ratios[ch] = {
		tlenA = 0, trepA = 0, tlenB = 0, trepB = 0, caw1 = 0, caw2 = 0, caw3 = 0, caw4 = 0, 
		ant = 0, aamp = 0, apw = 0, apw2 = 0, abit = 0, afr = 0, asy = 0, acr = 0, atype = 0, aph = 0, 
		lnt = 0, lamp = 0, lpw = 0, lpw2 = 0, lbit = 0, lfr = 0, lsy = 0, lcr = 0, ltype = 0, lph = 0, 
		ent = 0, eamp = 0, epw = 0, epw2 = 0, ebit = 0, efr = 0, esy = 0, ecr = 0, etype = 0, eph = 0, 
		nte = 0, amp = 0,  pw = 0,  pw2 = 0,  bit = 0, mdl = 0,
	}
end
function setup_clock(ch)
	clock_ID[ch] = { tlenA = nil }
	clock_on[ch] = { tlenA = 0 }
end
function acc(phase, freq, sec, looping)
	phase = phase + (freq * sec)
	phase = looping and ((1 + phase) % 2 - 1) or math.max(math.min(1, phase), -1)
	return phase
end
function peak(ph, pw, curve)
	local value = (ph < pw) and ((1 + ph) / (1 + pw))
		or (ph > pw) and ((1 - ph) / (1 - pw))
		or 1
	value = value ^ (2 ^ curve)
	return value
end
function update_synth(i)
	local s = states[i]
	local sec = input[1].time
	s.aph = acc(s.aph, s.afr, sec, is_positive(s.atype))
	local ampenv = peak(s.aph, s.asy, s.acr)
	s.eph = acc(s.eph, s.efr, sec, is_positive(s.etype))
	local modenv = peak(s.eph, s.esy, s.ecr)
	s.lph = acc(s.lph, s.lfr, sec, is_positive(s.ltype))
	local lfo = peak(s.lph, s.lsy, s.lcr)
	local note   = s.nte + (modenv * s.ent)  + (lfo * s.lnt)  + (ampenv * s.ant)
	local volume = (modenv * s.eamp * s.amp) + (lfo * s.lamp * s.amp) + (ampenv * s.aamp * s.amp)
	local pw     = s.pw  + (modenv * s.epw)  + (lfo * s.lpw)  + (ampenv * s.apw) 
	local pw2    = s.pw2 + (modenv * s.epw2) + (lfo * s.lpw2) + (ampenv * s.apw2) 
	local bitz   = s.bit + (modenv * s.ebit) + (lfo * s.lbit) + (ampenv * s.abit)
	local freq = 440
	if note > -8.03127 and note < 6.25643 then freq = math.min(math.max(267.9 * (2 ^ note), 1), 20000)
	elseif note >= 6.25643 then	freq = 20000 else freq = 1 end
	if i ~= 1 and ratios[i].nte ~= 0 then freq = freq * ratios[i].nte end
	local cyc = 1/(freq * caw_mult[i])
	if s.mdl == 2 then
		norm_cyc = cyc/0.1
		if math.random()*0.1 < norm_cyc then output[i].dyn.cyc = cyc + (cyc * 0.2 * math.random())
		else output[i].dyn.cyc = cyc + math.random()*0.002 end
	else output[i].dyn.cyc = cyc end
	output[i].dyn.amp = volume
	if bitz <= 0 then output[i].scale('none')
	else output[i].scale({}, 2, bitz * 3) end
	pw = math.min(math.max(pw, -1), 1)
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
function trigger_note(ch)
	if states[ch].eph >= states[ch].esy then states[ch].eph = -1 end
	if states[ch].aph >= states[ch].asy then states[ch].aph = -1 end
end
function trigger_seq(ch, param)
	local sq_caw = sequins{param+4,param+5,param+6,param+7}
	local sq_time = sequins{param, param+2}
	local sq_reps = sequins{param+1, param+3}
	local _time = states[ch][param_list[sq_time()]]
	local _reps = states[ch][param_list[sq_reps()]]
	local rep_ct = 0;
	while clock_on[ch][param_list[param]] == 1 do
		if rep_ct >= _reps then
			rep_ct = 0;
			_time = states[ch][param_list[sq_time()]]
			_reps = states[ch][param_list[sq_reps()]]
		end	
		rep_ct = rep_ct + 1
		if param == 41 then 
			cmult = states[ch][param_list[sq_caw()]]
			caw_mult[ch] = (cmult == 0) and 0.1 or cmult
			trigger_note(ch)
		end
		clock.sync(_time)
	end
end
function trig_enable(ch, reset, param)
	if reset == false then
		if clock_on[ch][param_list[param]] == 0 then
			clock_on[ch][param_list[param]] = 1
			clock_ID[ch][param_list[param]] = clock.run(trigger_seq, ch, param)
		else
			clock_on[ch][param_list[param]] = 0
			clock.cancel(clock_ID[ch][param_list[param]])
		end
	else
		clock_on[ch][param_list[param]] = 1
		clock.cancel(clock_ID[ch][param_list[param]])	
		clock_ID[ch][param_list[param]] = clock.run(trigger_seq, ch, param)
	end
end
function init()
	print("init!")
	clock.tempo = 300
	setup_state(1); setup_synth(1, 1, 1); setup_clock(1);
	for i = 2, 4 do setup_state(i); setup_ratio(i);	setup_synth(i, 1, 1); setup_clock(i) end	
	setup_i2c()
	setup_input()
	print("setup complete!")
end 