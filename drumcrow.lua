--- teletyping drums
--[[
deleted setup_synths() function 
setup_synth() is used to define the oscillator which always runs
state is used to define LFO, ENV, TIMBRE parameters
then update_synth is used to update the LFO, ENV, TIMBRE, NOTE, parameters
can we combine the synth_setup and update_synth and state parameters into something cleaner

fixed i in setup_synths, changed to ch
MAYBE: change variable names to be clearer?
TODO: rewrite so digit places for ch is the same for each i2c call in setup_i2c
TODO: what do the output dyn vars do in INIT()?
TODO: how does update_synth()?! acc? peak? 
okay so I think the outputs are always oscillating and outputing
just call c3 to trigger volume envelopes


| desc               | fn | ...args             |
|--------------------|----|---------------------|
| ch play            | C1 | 01-04               |

| ch play @ amp      | C2 | 05-08, amp (+rtrg)  |
| ch frq set (leg)   | C2 | 11-14, frq          |
| ch tmb set         | C2 | 15-18, tmb          |
| ch env sym (A:D)   | C2 | 25-28, sym          |
| ch env crv         | C2 | 31-34, exp          |
| ch env>tmb         | C2 | 35-38, dep          |
| ch env>frq         | C2 | 41-44, dep          |
| ch lfo spd (Hz*10) | C2 | 45-48, Hz*10 (+rst) |
| ch lfo sym (R:F)   | C2 | 51-54, sym          |
| ch lfo crv         | C2 | 55-58, exp          |
| ch lfo>tmb         | C2 | 61-64, dep          |
| ch lfo>frq         | C2 | 65-68, dep          |
| set frq slew       | C2 | 71-74, frq          |
| set tmb slew       | C2 | 75-78, frq          |
| set mod slew       | C2 | 81-84, frq          |
| select "engine"    | C2 | 85-88, p/s/n        |
| load preset #      | C2 | 91-94, pset 0-9     |
| save preset #      | C2 | 95-98, pset 0-9     |

| play frq, amp      | C3 | 01-04, frq, amp     |
| play preset, amp   | C3 | 11-14, frq, amp     |
--]]

local states = {}
local ch = 1
local cmd = 20
local presets = {}
local updating = false
local c2 = {}


local bad_cmd = function (ch, value, cmd) 
    print("CAW!")
end

-- | ch play @ frq      | C2 | 01-04, frq          |
c2[00] = function (ch, tt_value)
    states[ch].nte = u16_to_v10(tt_value)
    trigger_note(ch)
end
-- | ch play @ amp      | C2 | 05-08, amp (+rtrg)  |
-- | ch frq set (leg)   | C2 | 11-14, frq          |
-- | ch tmb set         | C2 | 15-18, tmb          |
    -- there is a bug w/ model 1 when pw = 16250
    -- detuned, undertones, sounds SICK
    -- DO NOT FIX IT YET
c2[14] = function (ch, v5)
    --set_state(ch, 'pw', tt_value / 16384)
    set_state(ch, 'pw', v5 / 5)
end
-- | ch env frq (Hz*10) | C2 | 21-24, Hz*10 (-lp)  |
c2[20] = function (ch, v5)
    --set_state(ch, 'efr', 2 ^ u16_to_v10(0 - tt_value))
    v5 = 2 ^ (0 - v5)
    set_state(ch, 'efr', v5)
end
-- | ch env sym (A:D)   | C2 | 25-28, sym          |
c2[24] = function (ch, v5)
    --set_state(ch, 'esy', tt_value / 16384)
    set_state(ch, 'esy', v5 / 5)
end
-- | ch env crv         | C2 | 31-34, exp          |
-- | ch env>tmb         | C2 | 35-38, dep          |
c2[34] = function (ch, v5)
    --set_state(ch, 'epw', tt_value / 16384)
    set_state(ch, 'epw', v5 / 5)
end
-- | ch env>frq         | C2 | 41-44, dep          |
c2[40] = function (ch, v5)
    --set_state(ch, 'ent', u16_to_v10(tt_value))
    set_state(ch, 'ent', v5)
end
-- | ch lfo spd (Hz*10) | C2 | 45-48, Hz*10 (+rst) |
c2[44] = function (ch, v5)
    --set_state(ch, 'lfr', 2 ^ u16_to_v10(tt_value))
    set_state(ch, 'lfr', 2 ^ v5)
end
-- | ch lfo sym (R:F)   | C2 | 51-54, sym          |
c2[50] = function (ch, v5)
    --set_state(ch, 'lsy', tt_value / 16384)
    set_state(ch, 'lsy', v5 / 5)
end
-- | ch lfo crv         | C2 | 55-58, exp          |
-- | ch lfo>tmb         | C2 | 61-64, dep          |
-- | ch lfo>frq         | C2 | 65-68, dep          |
c2[64] = function (ch, v5)
    --set_state(ch, 'lnt', u16_to_v10(tt_value))
    set_state(ch, 'lnt', v5)
end
-- | set frq slew       | C2 | 71-74, frq          |
-- | set tmb slew       | C2 | 75-78, frq          |
-- | set mod slew       | C2 | 81-84, frq          |
-- | select "engine"    | C2 | 85-88, p/s/n        |
c2[84] = function (ch, v5)
    --setup_synth(ch, tt_value)

    v5 = math.min(math.abs(v5), 5)
    setup_synth(ch, math.min(math.floor(v5 / 5 * 3) + 1), 3)
end
-- | load preset #      | C2 | 91-94, pset 0-9     |
-- | save preset #      | C2 | 95-98, pset 0-9     |



-- -32768 to 32767
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

-- input 1 stream to update all the synths in a loop
function setup_input()
    print("INPUT OK.")
	-- read input voltage 1, map input 0..+10V to -10..+10 internally
	-- call c2 to update the states
	-- use the state array to update the synth
	-- loop
    input[1].stream = function (v)
        if     v <=  0 then v = -10
		elseif v >= 10 then v =  10
        else   v = (v - 5) * 2
        end 
        ;(c2[cmd] or bad_cmd)(ch,v,cmd)--KEEP SEMICOLON!
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

-- initialize sound engine functions to state array
function setup_synth(output_index, model)
    -- variable saw wave
	function var_saw () 
		return loop {
			to(  dyn{amp=2}, dyn{cyc=1/440} *    dyn{pw=1/2} ),
			to(0-dyn{amp=2}, dyn{cyc=1/440} * (1-dyn{pw=1/2}))
		} 
	end
	
	-- pulse width modulation
    function pwm () 
		return loop {
			to(  dyn{amp=2},                              0  ),
		    to(  dyn{amp=2}, dyn{cyc=1/440} *    dyn{pw=1/2} ),
		    to(0-dyn{amp=2},                              0  ),
		    to(0-dyn{amp=2}, dyn{cyc=1/440} * (1-dyn{pw=1/2}))
		} 
	end

    -- a = pw2
    -- c = pw
    -- https://w.wiki/tV5
    -- m and c are relatively prime,
    -- a-1 is divisible by all prime factors of m,
    -- a-1 is divisible by 4 if m is divisible by 4.
	-- X(n+1) = (aX.n + c) mod m
	-- linear congruential generator (LCG)
	-- generates sequence of pseudo-random numbers
    function lcg() 
		return loop {
			to(dyn{x = 1}
				: mul(dyn{pw2 = 4037})
				: step(dyn{pw = 21032})
				: wrap(-32768,  32768 )/32768 * dyn{amp = 2}, 0),
			to(dyn{x = 1} / 32768 * dyn{amp=2}, dyn{cyc = 1/440} / 2)
		} 
	end

	-- assign fucntions and models to state array
    states[output_index].mdl = model
    output[output_index].action = ({ var_saw, pwm, lcg })[model]()
    output[output_index]()
end

-- initialize i2c function calls for teletype
function setup_i2c()
	-- CROW.C1 1xy -- set ch x to engine y
	-- CROW.C1 0xy -- set command and channel
	-- cmd changes what parameter input 1 voltage changes
	-- 114 = 1 select engine, 1 channel, 4 engine
	-- want channel / value / command
    ii.self.call1 = function (b1)
        if b1 > 100 then
			-- set a channel's synth model, local definition of channel
            local eng = b1 % 10
            local ch = ((b1 - eng) % 100) / 10
            print("setting ch "..ch.." to eng "..eng)
            setup_synth(ch, eng)
        else
			-- set (channel, command) destination for input 1 voltage
			-- 042 = 0 select command, 2 channel, 40 command
            ch = (b1 % 10 % 4)
            ch = (ch == 0 and 4) or ch
            cmd = b1 - ch
            print("input 1 mapping to ch "..ch.." command "..cmd)
        end
    end
	
	-- CROW.C2 x y -- set sound engine parameter using TT
	-- 041 V 10
	-- set channel 1, command 40, value V 10
    ii.self.call2 = function (b1, value)
        ch = (b1 % 10 % 4)
        ch = (ch == 0 and 4) or ch
        param = b1 - ch
		value = (u16_to_v10(value) - 5) * 2
        print("setting param to "..param.." on ch "..ch.." value "..value)
		if     param == 14 then set_state(ch, 'pw', value / 5)
		elseif param == 20 then 
			value = 2 ^ (0 - value)
			set_state(ch, 'efr', value)
		elseif param == 24 then set_state(ch, 'esy', value / 5)
		elseif param == 34 then set_state(ch, 'epw', value / 5)
		elseif param == 40 then set_state(ch, 'ent', value)
		elseif param == 44 then set_state(ch, 'lfr', 2 ^ value)
		elseif param == 50 then set_state(ch, 'lsy', value / 5)
		elseif param == 64 then set_state(ch, 'lnt', value)
		elseif param == 84 then 
			value = math.min(math.abs(value), 5)
			setup_synth(ch, math.min(math.floor(value / 5 * 3) + 1), 3)
		else
		end
    end
	
	-- CROW.C3 x y z -- play (freq, amp) or (preset, amp)
    ii.self.call3 = function (ch, note, vol)
    -- | play frq, amp      | C3 | 01-04, frq, amp     |
    -- | play preset, amp   | C3 | 11-14, frq, amp     |
        if ch == nil or note == nil or vol == nil or ch < 1 or ch > 4 then 
            return 
        end
        local v8 = u16_to_v10(note)
        local amp = u16_to_v10(vol)
        states[ch].nte = v8
        states[ch].amp = amp
        trigger_note(ch)
    end
	
	-- CROW.C4 x y z t
	-- currently unused
	-- ii.self.call4 = function(ch, note, vol, t)
		-- print("Whereof one cannot speak, thereof one must be silent");
	-- end
	-- test comment for git
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
		-- what are all these variable names?
        nte = 0, -- note (for frequency calculation)
        amp = 2, -- amplitude of oscillator
        pw  = 0, -- pulse width variable 1
        pw2 = 4037, -- pulse width variable 2
        mdl = 1, -- model number
		
        -- I think these are slew
        nsl = 16384, -- not referenced elsewhere
        psl = 16384, -- not referenced elsewhere
        msl = 16384, -- not referenced elsewhere
		
        -- this crashes when I set it negative (or 0?)		
		-- ENVELOPE
        efr = 100, -- frequency
		esy = -1, -- pulse width or symmetry
		ecr = 4, -- not referenced elsewhere (cycle rate?)
		epw = 0, -- pulse width
		ent = 0, -- note 
		eph = 1, -- phase 
        
		-- LFO
		lfr = 5, -- frequency 
		lsy = 0, -- symmetry
		lcr = 0, -- not reference elsewhere (cycle rate?)
		lpw = 0, -- pulse width
		lnt = 0, -- note
		lph = -1 -- phase
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

-- accumulates phase? uhh?
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
end

-- get state parameters, set output
function update_synth(i)
    local s = states[i]
    local sec = input[1].time

    -- ENVELOPES
    s.eph = acc(s.eph, s.efr, sec, false)
    local ampenv = peak(s.eph, s.esy, 3) 
    local modenv = peak(s.eph, s.esy, 4)

    -- LFO
    s.lph = acc(s.lph, s.lfr, sec, true)
    local lfo = peak(s.lph, s.lsy, s.lcr)

    -- FREQ
    local note = s.nte + (modenv * s.ent) + (lfo * s.lnt)
    local freq = v8_to_freq(note)
    if freq <= 0 then freq = 0.0000000001 end
    local cyc = 1/freq
    if cyc <= 0 then cyc = 0.0000000001 end
    output[i].dyn.cyc = cyc

    -- AMP
    output[i].dyn.amp = ampenv * s.amp

    -- TIMBRE
    if s.mdl == 3 then
        --local pw = s.pw + (env * s.epw) + (lfo * s.lpw)
        --pw = math.max(-1, math.min(pw, 1))
        --pw = (pw + 1) / 2
        local pw = s.pw
        output[i].dyn.pw = math.abs(pw * 16384)
        output[i].dyn.pw2 = s.pw2
    else
        local pw = s.pw + (modenv * s.epw) + (lfo * s.lpw)
        pw = math.max(-1, math.min(pw, 1))
        pw = (pw + 1) / 2
        output[i].dyn.pw = pw
    end
end

-- INIT
function init()
    updating = false
	
	channels = 4 -- ch
	for i = 1, channels do
		setup_state(i)
		setup_synth(i, 1)
	end
	
	-- initialize the amp and cyc dynamic variables for oscillators
	output[1].dyn.amp = 5
    output[2].dyn.amp = 0.25
    output[3].dyn.amp = 0.3
    output[4].dyn.amp = 0.3
    output[3].dyn.cyc = 1/2000
	
	setup_i2c()
	
	-- start output
    output[1]()
    output[2]()
    output[3]()
    output[4]()

	-- start updating synths
	setup_input()
end 