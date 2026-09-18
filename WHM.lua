-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
    
    -- Load and initialize the include file.
    include('Mote-Include.lua')
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    state.Buff['Afflatus Solace'] = buffactive['Afflatus Solace'] or false
    state.Buff['Afflatus Misery'] = buffactive['Afflatus Misery'] or false
	include('PrecastReadyCheck.lua')
	include('TPGate')
	barStatus = {}
	barStatus.list = S{'Barparalyzra', 'Barpoisonra'}
	
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None', 'Normal')
    state.CastingMode:options('Normal', 'Resistant')
    state.IdleMode:options('Normal', 'PDT')

    select_default_macro_book()
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Precast Sets

    -- Fast cast sets for spells
    sets.precast.FC = {
		main={ name="Grioavolr", augments={'"Fast Cast"+6','MP+5','Mag. Acc.+10','"Mag.Atk.Bns."+12',}},
		sub="Vivid Strap",
		ammo="Impatiens",
		head="Ebers Cap +2",
		body="Inyanga Jubbah +2",
		hands="Gende. Gages +1",
		legs="Ayanmo Cosciales +1",
		feet="Regal Pumps +1",
		neck="Cleric's Torque",
		waist="Embla Sash",
		left_ear="Malignance Earring",
		right_ear="Loquac. Earring",
		left_ring="Kishar Ring",
		right_ring="Lebeche Ring",
		back={ name="Alaunus's Cape", augments={'"Fast Cast"+10',}}
		}
        
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})

    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {head="Umuthi Hat"})

    sets.precast.FC['Healing Magic'] = set_combine(sets.precast.FC, {legs="Orison Pantaloons +2"})

    sets.precast.FC.StatusRemoval = sets.precast.FC['Healing Magic']

    sets.precast.FC.Cure = set_combine(sets.precast.FC['Healing Magic'], {main="Tamaxchi",sub="Genbu's Shield",ammo="Impatiens"})
    sets.precast.FC.Curaga = sets.precast.FC.Cure
    sets.precast.FC.CureSolace = sets.precast.FC.Cure
    -- CureMelee spell map should default back to Healing Magic.
    
    -- Precast sets to enhance JAs
    sets.precast.JA.Benediction = {body="Piety Briault"}

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}
    
    
    -- Weaponskill sets

    -- Default set for any weaponskill that isn't any more specifically defined
    gear.default.weaponskill_neck = "Asperity Necklace"
    gear.default.weaponskill_waist = ""
    sets.precast.WS = {
	sub="Archduke's Shield",
    ammo="White Tathlum",
    head="Aya. Zucchetto +2",
    body="Piety Bliaut +3",
    hands="SV Gauntlets +1",
    legs="Piety Pantaln. +2",
    feet="SV Gaiters +1",
    neck="Lissome Necklace",
    waist="Eschan Stone",
    left_ear="Malignance Earring",
    right_ear="Moonshade Earring",
    left_ring="Rajas Ring",
    right_ring="Metamorph Ring",
    back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Phys. dmg. taken-10%',}},}
    
    sets.precast.WS['Flash Nova'] = {}
    

    -- Midcast Sets
    
    sets.midcast.FastRecast = {
        head="Ebers Cap +2",ear2="Loquacious Earring",
        body="Vanir Cotehardie",hands="Dynasty Mitts",ring1="Prolix Ring",
        back="Swith Cape +1",waist="Goading Belt",legs="Gendewitha Spats",feet="Gendewitha Galoshes"}
    
    -- Cure sets
    gear.default.obi_waist = "Goading Belt"
    gear.default.obi_back = "Mending Cape"

    sets.midcast.CureSolace = {main="Chatoyant Staff",
    sub="Mensch Strap",
    ammo="Impatiens",
    head={ name="Vanya Hood", augments={'MP+50','"Fast Cast"+10','Haste+2%',}},
    body="Ebers Bliaut +2",
    hands="Theo. Mitts +2",
    legs="Ebers Pant. +2",
    feet="Inyan. Crackows +2",
    neck="Cleric's Torque",
    waist="Olympus Sash",
    left_ear="Nourish. Earring +1",
	right_ear="Mendicant's Earring",
    left_ring="Janniston Ring",
    right_ring="Metamorph Ring",
    back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Phys. dmg. taken-10%',}}
	}

    sets.midcast.Cure = {    
	main="Chatoyant Staff",
    sub="Mensch Strap",
    ammo="Impatiens",
    head={ name="Vanya Hood", augments={'MP+50','"Fast Cast"+10','Haste+2%',}},
    body="Ebers Bliaut +2",
    hands="Theo. Mitts +2",
    legs="Ebers Pant. +2",
    feet="Inyan. Crackows +2",
    neck="Cleric's Torque",
    waist="Olympus Sash",
    left_ear="Nourish. Earring +1",
	right_ear="Mendicant's Earring",
    left_ring="Janniston Ring",
    right_ring="Metamorph Ring",
    back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Phys. dmg. taken-10%',}}
	}

    sets.midcast.Curaga = {    
	main="Chatoyant Staff",
    sub="Mensch Strap",
    ammo="Impatiens",
    head={ name="Vanya Hood", augments={'MP+50','"Fast Cast"+10','Haste+2%',}},
    body="Theo. Bliaut +1",
    hands="Theo. Mitts +2",
    legs="Ebers Pant. +2",
    feet="Inyan. Crackows +2",
    neck="Cleric's Torque",
    waist="Olympus Sash",
    left_ear="Nourish. Earring +1",
	right_ear="Mendicant's Earring",
    left_ring="Inyanga Ring",
    right_ring="Metamorph Ring",
    back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Phys. dmg. taken-10%',}}
	}

    sets.midcast.CureMelee = {ammo="Incantor Stone",
        head="Gendewitha Caubeen",neck="Orison Locket",ear1="Lifestorm Earring",ear2="Orison Earring",
        body="Vanir Cotehardie",hands="Bokwus Gloves",ring1="Prolix Ring",ring2="Sirona's Ring",
        back="Tuilha Cape",waist=gear.ElementalObi,legs="Orison Pantaloons +2",feet="Piety Duckbills +1"}

    sets.midcast.Cursna = {
	main="Chatoyant Staff",
    sub="Mensch Strap",
    ammo="Impatiens",
    head={ name="Vanya Hood", augments={'MP+50','"Fast Cast"+10','Haste+2%',}},
    body="Ebers Bliaut +2",
    hands="Inyan. Dastanas +2",
    legs="Th. Pantaloons +2",
    feet="Regal Pumps +1",
    neck="Debilis Medallion",
    waist="Bishop's Sash",
    left_ear="Mimir Earring",
    right_ear="Mendi. Earring",
    left_ring="Menelaus's Ring",
    right_ring="Haoma's Ring",
    back={ name="Alaunus's Cape", augments={'"Fast Cast"+10',}},}

    sets.midcast.StatusRemoval = {
        head="Ebers Cap +2",legs="Ebers Pant. +2"}

    -- 110 total Enhancing Magic Skill; caps even without Light Arts
    sets.midcast['Enhancing Magic'] = {
	main={ name="Gada", augments={'Enh. Mag. eff. dur. +5','STR+4','Mag. Acc.+6','"Mag.Atk.Bns."+9',}},
    sub="Deliverance +1",
    ammo="Impatiens",
    head="Ebers Cap +2",
    body="Ebers Bliaut +2",
    hands="Ebers Mitts",
    legs="Inyanga Shalwar +2",
    feet="Theo. Duckbills +2",
    neck="Warder's Charm",
    waist="Embla Sash",
    left_ear="Eabani Earring",
    right_ear="Mimir Earring",
    left_ring="Inyanga Ring",
    right_ring="Metamorph Ring",
    back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Phys. dmg. taken-10%',}}
	}

    sets.midcast.Stoneskin = {
    main={ name="Gada", augments={'Enh. Mag. eff. dur. +5','STR+4','Mag. Acc.+6','"Mag.Atk.Bns."+9',}},
    sub="Deliverance +1",
    ammo="Impatiens",
    head="Ebers Cap +2",
    body="Ebers Bliaut +2",
    hands="Ebers Mitts",
    legs="Shedir Seraweels",
    feet="Theo. Duckbills +2",
    neck="Warder's Charm",
    waist="Embla Sash",
    left_ear="Eabani Earring",
    right_ear="Mimir Earring",
    left_ring="Inyanga Ring",
    right_ring="Metamorph Ring",
    back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Phys. dmg. taken-10%',}}
	}
	sets.midcast.Aquaveil = {
	main={ name="Gada", augments={'Enh. Mag. eff. dur. +5','STR+4','Mag. Acc.+6','"Mag.Atk.Bns."+9',}},
    sub="Deliverance +1",
    ammo="Impatiens",
    head="Ebers Cap +2",
    body="Ebers Bliaut +2",
    hands="Ebers Mitts",
    legs="Shedir Seraweels",
    feet="Theo. Duckbills +2",
    neck="Warder's Charm",
    waist="Embla Sash",
    left_ear="Eabani Earring",
    right_ear="Mimir Earring",
    left_ring="Inyanga Ring",
    right_ring="Metamorph Ring",
    back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Phys. dmg. taken-10%',}},
	}
    sets.midcast.Auspice = {
	main={ name="Gada", augments={'Enh. Mag. eff. dur. +5','STR+4','Mag. Acc.+6','"Mag.Atk.Bns."+9',}},
    sub="Deliverance +1",
    ammo="Impatiens",
    head="Ebers Cap +2",
    body="Ebers Bliaut +2",
    hands="Ebers Mitts",
    legs="Inyanga Shalwar +2",
    feet="Theo. Duckbills +2",
    neck="Warder's Charm",
    waist="Embla Sash",
    left_ear="Eabani Earring",
    right_ear="Mimir Earring",
    left_ring="Inyanga Ring",
    right_ring="Metamorph Ring",
    back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Phys. dmg. taken-10%',}},}

    sets.midcast.BarElement = {
	main={ name="Gada", augments={'Enh. Mag. eff. dur. +5','STR+4','Mag. Acc.+6','"Mag.Atk.Bns."+9',}},
    sub="Deliverance +1",
    ammo="Impatiens",
    head="Ebers Cap +2",
    body="Ebers Bliaut +2",
    hands="Ebers Mitts",
    legs="Inyanga Shalwar +2",
    feet="Theo. Duckbills +2",
    neck="Warder's Charm",
    waist="Embla Sash",
    left_ear="Eabani Earring",
    right_ear="Mimir Earring",
    left_ring="Inyanga Ring",
    right_ring="Metamorph Ring",
    back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Phys. dmg. taken-10%',}},}
	sets.midcast.barStatus = {
		main={ name="Gada", augments={'Enh. Mag. eff. dur. +5','STR+4','Mag. Acc.+6','"Mag.Atk.Bns."+9',}},
		
		
	}

    sets.midcast.Regen = {
	main={ name="Gada", augments={'Enh. Mag. eff. dur. +5','STR+4','Mag. Acc.+6','"Mag.Atk.Bns."+9',}},
    sub="Deliverance +1",
    ammo="Impatiens",
    head="Inyanga Tiara +2",
    body="Piety Bliaut +3",
    hands="Ebers Mitts +1",
    legs="Th. Pantaloons +2",
    feet="Theo. Duckbills +2",
    neck="Cleric's Torque",
    waist="Embla Sash",
    left_ear="Eabani Earring",
    right_ear="Mimir Earring",
    left_ring="Inyanga Ring",
    right_ring="Metamorph Ring",
    back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Phys. dmg. taken-10%',}},}

    sets.midcast.Protectra = {ring1="Sheltered Ring",feet="Piety Duckbills +1"}

    sets.midcast.Shellra = {ring1="Sheltered Ring",legs="Piety Pantaloons +1"}


    sets.midcast['Divine Magic'] = {}

    sets.midcast['Dark Magic'] = {}

    -- Custom spell classes
    sets.midcast.MndEnfeebles = {}

    sets.midcast.IntEnfeebles = {}

    
    -- Sets to return to when not performing an action.
    
    -- Resting sets
    sets.resting = {}
    

    -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)
    sets.idle = {    
    ammo="Impatiens",
    head="Inyanga Tiara +2",
    body="Ebers Bliaut +2",
    hands="Inyanga Dastanas +2",
    legs="Inyanga Shalwar +2",
    feet="Inyan. Crackows +2",
    neck="Warder's Charm",
    waist="Carrier's Sash",
    left_ear="Eabani Earring",
	right_ear="Loquacious Earring",
    left_ring="Inyanga Ring",
    right_ring="Metamorph Ring",
    back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Phys. dmg. taken-10%',}}
	}

    sets.idle.PDT = {}

    sets.idle.Town = {}
    
    sets.idle.Weak = {}
    
    -- Defense sets

    sets.defense.PDT = {}

    sets.defense.MDT = {}

    sets.Kiting = {feet="Herald's Gaiters"}

    sets.latent_refresh = {waist="Fucho-no-obi"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion
    
    -- Basic set for if no TP weapon is defined.
    sets.engaged = {
	main="Kaja Rod",
    sub="Archduke's Shield",
    ammo="White Tathlum",
    head="Aya. Zucchetto +2",
    body="SV Separates +1",
    hands="SV Gauntlets +1",
    legs="SV Loincloth +1",
    feet="SV Gaiters +1",
    neck="Lissome Necklace",
    waist="Windbuffet Belt +1",
    left_ear="Alabaster Earring",
    right_ear="Eabani Earring",
    left_ring="Rajas Ring",
    right_ring="Inyanga Ring",
    back={ name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Phys. dmg. taken-10%',}},
	}


    -- Buff sets: Gear that needs to be worn to actively enhance a current player buff.
    sets.buff['Divine Caress'] = {hands="Orison Mitts +2",back="Mending Cape"}
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if spell.english == "Paralyna" and buffactive.Paralyzed then
        -- no gear swaps if we're paralyzed, to avoid blinking while trying to remove it.
        eventArgs.handled = true
    end
    
    if spell.skill == 'Healing Magic' then
        gear.default.obi_back = "Mending Cape"
    else
        gear.default.obi_back = "Toro Cape"
    end
end


function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Apply Divine Caress boosting items as highest priority over other gear, if applicable.
    if spellMap == 'StatusRemoval' and buffactive['Divine Caress'] then
        equip(sets.buff['Divine Caress'])
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'Offense Mode' then
        if newValue == 'Normal' then
            disable('main','sub','range')
        else
            enable('main','sub','range')
        end
    end
end


-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Custom spell mapping.
function job_get_spell_map(spell, default_spell_map)
    if spell.action_type == 'Magic' then
        if (default_spell_map == 'Cure' or default_spell_map == 'Curaga') and player.status == 'Engaged' then
            return "CureMelee"
        elseif default_spell_map == 'Cure' and state.Buff['Afflatus Solace'] then
            return "CureSolace"
        elseif spell.skill == "Enfeebling Magic" then
            if spell.type == "WhiteMagic" then
                return "MndEnfeebles"
            else
                return "IntEnfeebles"
            end
        end
    end
end


function customize_idle_set(idleSet)
    if player.mpp < 51 then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    return idleSet
end

-- Called by the 'update' self-command.
function job_update(cmdParams, eventArgs)
    if cmdParams[1] == 'user' and not areas.Cities:contains(world.area) then
        local needsArts = 
            player.sub_job:lower() == 'sch' and
            not buffactive['Light Arts'] and
            not buffactive['Addendum: White'] and
            not buffactive['Dark Arts'] and
            not buffactive['Addendum: Black']
            
        if not buffactive['Afflatus Solace'] and not buffactive['Afflatus Misery'] then
            if needsArts then
                send_command('@input /ja "Afflatus Solace" <me>;wait 1.2;input /ja "Light Arts" <me>')
            else
                send_command('@input /ja "Afflatus Solace" <me>')
            end
        end
    end
end


-- Function to display the current relevant user state when doing an update.
function display_current_job_state(eventArgs)
    display_current_caster_state()
    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    set_macro_page(1, 1)
end

