--- drumcrow
note_min = -8.03127 -- (-8.03127, 1Hz, 1sec) (-11.3532, 0.1Hz, 10sec) (-14.67513, 0.01Hz, 100sec) (-17.997, 0.001Hz, 1000sec)
max_freq = 7000
states = {}
caw_mult = {1, 1, 1, 1}
flaps = {1, 1, 1, 1}
channel = 1
parameter = 0
c2 = {}
act = 0
shapes = {'linear','sine','logarithmic','exponential','now','wait','over','under','rebound'}
param_list = {}
clock_ID = {}
clock_on = {0,0,0,0}
function setup_state(ch)
	states[ch] = {
		tlenA = 1, trepA = 2, tlenB = 2, trepB = 2, flaps = 4, caw1 = 1, caw2 = 1, caw3 = 1, caw4 = 1, 
		amfreq = 0, ante = 0, aamp = 1, apw = 0, apw2 = 0, abit = 0, afr = 4, asy = -1, acr = 3, atype = 0, aph = 1, 
		lmfreq = 0, lnte = 0, lamp = 0, lpw = 0, lpw2 = 0, lbit = 0, lfr = 5, lsy = 0,  lcr = 0, ltype = 1, lph = -1, 
		emfreq = 0, ente = 0, eamp = 0, epw = 0, epw2 = 0, ebit = 0, efr = 1, esy = -1, ecr = 4, etype = 0, eph = 1, 
		mfreq = 1, nte = 0, amp = 4, pw = 0, pw2 = 4, bit = 0, cawfr3 = 0, cawfr4 = 0, cawnte = 1, splash = 0, mdl = 1, 
	}
end
function v10_to_int(v) 
	v = v >= 0 and math.floor(v+0.5) or math.ceil(v-0.5)
	return (v >= 1) and v or (v <= -1) and v or 1 
end
function v10_to_ratio(v) 
	v = v >= 0 and math.floor(v+0.5) or math.ceil(v-0.5)
	return (v >= 1) and v or (v <= -1) and 1/(-1*v) or 1
end
function make_divide(divisor) return function (x) return x / divisor end end
function make_A_to_1(lower) return function (v) return (v+10)/20 + lower end end
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
setup_hof_param(10, 'mfreq', make_A_to_1(0.001))
setup_hof_param(11, 'nte', make_divide(1))
setup_hof_param(12, 'amp', make_divide(2))
setup_hof_param(13, 'pw', make_divide(10))
setup_hof_param(14, 'pw2', make_divide(1)) 
setup_hof_param(15, 'bit', make_divide(1))
setup_hof_param(16, 'cawfr3', make_divide(5))
setup_hof_param(17, 'cawfr4', make_divide(5))
setup_hof_param(18, 'cawnte', make_divide(1))
setup_hof_param(19, 'splash', make_divide(3))
setup_hof_param(20, 'emfreq', make_A_to_1(0))
setup_hof_param(21, 'ente', make_divide(1))
setup_hof_param(22, 'eamp', make_divide(3))
setup_hof_param(23, 'epw', make_divide(5))
setup_hof_param(24, 'epw2', make_divide(1))
setup_hof_param(25, 'ebit', make_divide(1))
setup_hof_param(26, 'efr', make_rectify_right(9.5, -0.7, 0.0000000002328))
setup_hof_param(27, 'esy', make_divide(1))
setup_hof_param(28, 'ecr', make_divide(2))
setup_hof_param(29, 'etype', make_divide(1))
setup_hof_param(30, 'lmfreq', make_A_to_1(0))
setup_hof_param(31, 'lnte', make_divide(1))
setup_hof_param(32, 'lamp', make_divide(3))
setup_hof_param(33, 'lpw', make_divide(5))
setup_hof_param(34, 'lpw2', make_divide(1))
setup_hof_param(35, 'lbit', make_divide(1))
setup_hof_param(36, 'lfr', make_rectify_left(-9.5, 1, 0.0000000002328))
setup_hof_param(37, 'lsy', make_divide(5))
setup_hof_param(38, 'lcr', make_divide(2))
setup_hof_param(39, 'ltype', make_divide(1))
setup_hof_param(40, 'amfreq', make_A_to_1(0))
setup_hof_param(41, 'ante', make_divide(1))
setup_hof_param(42, 'aamp', make_divide(3))
setup_hof_param(43, 'apw', make_divide(5))
setup_hof_param(44, 'apw2', make_divide(1))
setup_hof_param(45, 'abit', make_divide(1))
setup_hof_param(46, 'afr', make_rectify_right(9.5, -0.7, 0.0000000002328))
setup_hof_param(47, 'asy', make_divide(5))
setup_hof_param(48, 'acr', make_divide(2))
setup_hof_param(49, 'atype', make_divide(1))
setup_hof_param(51, 'tlenA', v10_to_ratio)
setup_hof_param(52, 'trepA', v10_to_int)
setup_hof_param(53, 'tlenB', v10_to_ratio)
setup_hof_param(54, 'trepB', v10_to_int)
param_list[55] = 'flaps'
c2[55] = function (ch, v)
	v = math.floor((((v+10)/20)*3.9+1))
	set_state(ch, 'flaps', v)
end
setup_hof_param(56, 'caw1', v10_to_ratio)
setup_hof_param(57, 'caw2', v10_to_ratio)
setup_hof_param(58, 'caw3', v10_to_ratio)
setup_hof_param(59, 'caw4', v10_to_ratio)
param_list[81] = 'tempo'
c2[81] = function (ch, v) 
	v = (v+10.1) * 100 
	clock.tempo = v
	channel = 1; parameter = 0; act = 0
	print("Set tempo: "..v..", deselect")
end
param_list[82] = 'update_time'
c2[82] = function (ch, v) 
	v = (v + 10) / 20 * (0.1 - 0.006) + 0.006 
	input[1]{mode = 'stream', time = v} 
end
param_list[83] = 'max_freq'
c2[83] = function (ch, v) 
	max_freq = (v + 10) / 20 * (20000 - 0.01) + 0.01 
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
		v = (v <= 0) and 0 or (v >= 10) and 10 or v
		v = (math.min(math.max(v, -10), 10) - 5) * 2
		;(c2[parameter] or bad_param)(channel,v)--KEEP SEMICOLON!
		for i = 1, 4 do update_synth(i) end
	end
	input[1]{mode = 'stream', time = 0.006}
end
function setup_synth(ch, model, shape)
	function var_saw(shape)
		return loop{
			to(dyn{amp=2}, dyn{cyc=1/440} * dyn{pw=1/2}, shape), 
			to(0-dyn{amp=2}, dyn{cyc=1/440} * (1-dyn{pw=1/2}), shape)} 
	end	
	function bytebeat(shape)
		return loop{
			to(dyn{x=1}:step(dyn{pw=1}):wrap(-10,10) * dyn{amp=2}, dyn{cyc=1}, shape)}
	end
	function noise(shape)
		return loop{
			to(dyn{x=1}:mul(dyn{pw2=1}):step(dyn{pw=1}):wrap(-5,5) * dyn{amp=2}, dyn{cyc=1}, shape)} 
	end
	function FMstep(shape) 
		return loop{
			to(  dyn{amp=2}, dyn{x=1}:step(dyn{pw2=1}):wrap(1,2) * dyn{cyc=1} * dyn{pw=1}, shape),
			to(0-dyn{amp=2}, dyn{x=1} * dyn{cyc=1} * (1-dyn{pw=1}), shape)
		}
	end
	function ASLsine(shape)
		return loop{
			to((dyn{x=0}:step(dyn{pw=0.314}):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, shape)}
	end
	function ASLharmonic(shape)
		return loop{
			to((dyn{x=0}:step(dyn{pw=1}):mul(-1):wrap(-3.14,3.14) + 0.101321 * dyn{x=0} * dyn{x=0} * dyn{x=0}) * dyn{amp=2}, dyn{cyc=1}, shape)}
	end
	function bytebeat5(shape)
		return loop{
			to(dyn{x=0}:step(dyn{pw=0.1}):wrap(0, 10) % dyn{pw2=1} * dyn{amp=2}, dyn{cyc=1}, shape)}
	end
	states[ch].mdl = model
		if model == 1 then output[ch]( var_saw(shapes[shape]) )
	elseif model == 2 then output[ch]( bytebeat(shapes[shape]) )
	elseif model == 3 then output[ch]( noise(shapes[shape]) )
	elseif model == 4 then output[ch]( FMstep(shapes[shape]) )
	elseif model == 5 then output[ch]( ASLsine(shapes[shape]) )
	elseif model == 6 then output[ch]( ASLharmonic(shapes[shape]) ) 
	elseif model == 7 then output[ch]( bytebeat5(shapes[shape]) ) 
	else output[ch]( var_saw(shapes[shape]) ) end
end
function setup_i2c()
	ii.self.call1 = function (b1)
		if b1 == nil then print("CAW!") return end
		digits, action, param, ch = get_digits(b1)
		process_action(digits, action, param, ch, 1)
	end
	ii.self.call2 = function (b1, v)
		if b1 == nil or v == nil then print("CAW!") return end
		digits, action, param, ch = get_digits(b1)
		v = u16_to_v10(math.min(math.max(v, -16384), 16384))
		print(" action "..action.." param "..param.." ch "..ch.." v "..v)
		process_action(digits, action, param, ch, 2, v)
	end
	ii.self.call3 = function (ch, note, amp)
		if ch == nil or note == nil or amp == nil then print("CAW!") return end
		ch   = ch % 5;
		note = math.min(math.max(note, -16384), 16384)
		amp  = math.min(math.max(amp, -16384), 16384)
		if ch == 0 then
			for i = 1,4 do 
				set_state(i, 'nte', u16_to_v10(note), 3)
				set_state(i, 'amp', u16_to_v10(amp), 3)
				trigger_note(i)
			end
		else 
			set_state(ch, 'nte', u16_to_v10(note), 3)
			set_state(ch, 'amp', u16_to_v10(amp), 3)
			trigger_note(ch)
		end
	end
end
function process_action(digits, action, param, ch, cmd, v)
	v = v or 0
	if action == 1 then -- 1: set new ASL construct (shape, model) keep act the same
		if ch == 0 then
			for i = 1, 4 do
				setup_synth(i, digits[2], digits[3])
			end
		else
			setup_synth(ch, digits[2], digits[3])
		end
		print("Setup Synth, Shape: "..digits[3].." Model: "..digits[2].." Channel: "..ch)
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
		elseif param == 85 then -- reset tseq
			if ch == 0 then
				for i = 1, 4 do
					trig_enable(i, true)
					print("CLK Reset Channel: "..i)
				end
			else
				trig_enable(ch, true)
				print("CLK Reset Channel: "..ch)
			end
		elseif param == 50 then -- TRIG enable/disable
			if ch == 0 then
				for i = 1, 4 do
					trig_enable(i, false)
					print("CLK ON/OFF Channel: "..i)
				end
			else
				trig_enable(ch, false)
				print("CLK ON/OFF Channel: "..ch)
			end
		elseif param_list[param] ~= nil then -- set state 
			if cmd == 2 then
				;(c2[param] or bad_param)(ch,v)
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
	local cmd = cmd or 0
	if ch == 0 then
		for i = 1,4 do states[i][key] = v end
	else
		states[ch][key] = v
	end
end	
function acc(phase, freq, sec, looping)
	phase = phase + (freq * sec)
	phase = looping and (1 + phase) % 2 - 1 or math.max(math.min(1, phase), -1)
	return phase
end
function peak(ph, pw, curve)
	local value = ph < pw and (1 + ph) / (1 + pw) or ph > pw and (1 - ph) / (1 - pw) or 1
	value = value ^ (2 ^ curve)
	return value
end
function update_synth(i)
	local s = states[i]
	local sec = input[1].time
	s.aph = acc(s.aph, s.cawfr4 > 0 and s.afr * caw_mult[i] / s.cawfr4 or s.afr, sec, s.atype > 0)
	local ampenv = peak(s.aph, s.asy, s.acr)
	s.lph = acc(s.lph, s.cawfr3 > 0 and s.lfr * caw_mult[i] * s.cawfr3 or s.lfr, sec, s.ltype > 0)
	local lfo = peak(s.lph, s.lsy, s.lcr)
	s.eph = acc(s.eph, s.efr, sec, s.etype > 0)
	local modenv = peak(s.eph, s.esy, s.ecr)
	local note   = s.nte + (modenv * s.ente)  + (lfo * s.lnte)  + (ampenv * s.ante)
	local volume = (modenv * s.eamp * s.amp) + (lfo * s.lamp * s.amp) + (ampenv * s.aamp * s.amp)
	local pw     = s.pw  + (modenv * s.epw)  + (lfo * s.lpw)  + (ampenv * s.apw) 
	local pw2    = s.pw2 + (modenv * s.epw2) + (lfo * s.lpw2) + (ampenv * s.apw2) 
	local bitz   = s.bit + (modenv * s.ebit) + (lfo * s.lbit) + (ampenv * s.abit)
	local freq = note > note_min and note < 6.25643 and math.min(math.max(267.9 * (2 ^ note), 1), max_freq) or (note >= 6.25643 and max_freq or 1)
	local cyc = 1/math.min(max_freq*(s.mfreq+(modenv*s.emfreq)+(lfo*s.lmfreq)+(ampenv*s.amfreq)), freq*(s.cawnte > 0 and caw_mult[i] or 1))
	output[i].dyn.cyc = s.splash > 0 and (math.random()*0.1 < cyc/0.1 and cyc + (cyc * 0.2 * math.random()*s.splash) or cyc + math.random()*0.002*s.splash) or cyc
	output[i].dyn.amp = math.min(math.max(volume, -10), 10)
	if bitz > 0 then output[i].scale({}, 2, bitz * 3) else output[i].scale('none') end
	pw = (math.min(math.max(pw, -1), 1) + 1) / 2
	if s.mdl == 2 or s.mdl == 5 or s.mdl == 6 then 
		output[i].dyn.pw = pw * pw2
	elseif s.mdl == 3 or s.mdl == 7 then
		output[i].dyn.pw = pw
		output[i].dyn.pw2 = pw2
	elseif s.mdl == 4 then
		output[i].dyn.pw = pw
		output[i].dyn.pw2 = pw2 / 50
	else 
		output[i].dyn.pw = pw 
	end
end
function trigger_note(ch)
	if states[ch].aph >= states[ch].asy then states[ch].aph = -1 end
	if states[ch].eph >= states[ch].esy then states[ch].eph = -1 end
end
function trigger_seq(ch)
	local sq_caw  = sequins{56,57,58,59}
	local sq_time = sequins{51,53}
	local sq_reps = sequins{52,54}
	local _time = states[ch][param_list[sq_time()]]
	local _reps = states[ch][param_list[sq_reps()]]
	local rep_ct = 0;
	while clock_on[ch] == 1 do
		if rep_ct >= _reps then
			rep_ct = 0;
			_time = states[ch][param_list[sq_time()]]
			_reps = states[ch][param_list[sq_reps()]]
			sq_caw:step(math.floor(states[ch].flaps)%4+1)
		end
		rep_ct = rep_ct + 1
		cmult = states[ch][param_list[sq_caw()]]
		caw_mult[ch] = (cmult == 0) and 0.1 or cmult
		trigger_note(ch)
		clock.sync(_time)
	end
end
function trig_enable(ch, reset)
	if reset == false then
		if clock_on[ch] == 0 then
			clock_on[ch] = 1
			clock_ID[ch] = clock.run(trigger_seq, ch)
		else
			clock_on[ch] = 0
			clock.cancel(clock_ID[ch])
		end
	else
		if clock_on[ch] == 1 then clock.cancel(clock_ID[ch]) end
		clock_ID[ch] = clock.run(trigger_seq, ch)
	end
end
function init()
	clock.tempo = 300
	setup_state(1); setup_synth(1, 1, 1);
	for i = 2, 4 do setup_state(i); setup_synth(i, 1, 1); end	
	setup_i2c()
	setup_input()
	print("setup complete!")
end 