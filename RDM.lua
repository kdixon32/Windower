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
    state.Buff.Saboteur = buffactive.saboteur or false
	include('PrecastReadyCheck.lua')
	include('TPGate')
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None', 'Normal')
    state.HybridMode:options('Normal', 'PhysicalDef', 'MagicalDef')
    state.CastingMode:options('Normal', 'Resistant')
    state.IdleMode:options('Normal', 'PDT', 'MDT')

    gear.default.obi_waist = "Sekhmet Corset"
    
    select_default_macro_book()
end


-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------
    
    -- Precast Sets
    
    -- Precast sets to enhance JAs
    sets.precast.JA['Chainspell'] = {body={ name="Viti. Tabard +3", augments={'Enhances "Chainspell" effect',}}}
    

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {
        head="Atrophy Chapeau +2",
        body="Atrophy Tabard +3",hands="Yaoyotl Gloves",
        back="Refraction Cape",legs="Hagondes Pants",feet="Hagondes Sabots"}
        
    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz['Healing Waltz'] = {}

    -- Fast cast sets for spells
    
    -- 80% Fast Cast (including trait) for all spells, plus 5% quick cast
    -- No other FC sets necessary.
    sets.precast.FC = {
	ammo="Impatiens",
    head="Atro. Chapeau +2",
    body={ name="Viti. Tabard +3", augments={'Enhances "Chainspell" effect',}},
    hands="Atrophy Gloves +3",
    legs={ name="Carmine Cuisses", augments={'Accuracy+15','Attack+10','"Dual Wield"+5',}},
    feet={ name="Carmine Greaves", augments={'Accuracy+10','DEX+10','MND+15',}},
    neck="Sanctity Necklace",
	waist="Embla Sash",
    left_ear="Malignance Earring",
	right_ear={ name="Lethargy Earring", augments={'System: 1 ID: 1676 Val: 0','Accuracy+8','Mag. Acc.+8',}},
    left_ring="Kishar Ring",
    right_ring="Weatherspoon Ring",
    back={ name="Sucellos's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+8','"Fast Cast"+10','Damage taken-1%',}}
	}

    sets.precast.FC.Impact = set_combine(sets.precast.FC, {head=empty,body="Twilight Cloak"})
       
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        head={ name="Viti. Chapeau +4", augments={'Enfeebling Magic duration','Magic Accuracy',}},neck="Asperity Necklace",ear1="Bladeborn Earring",ear2={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +250',}},
        body={ name="Viti. Tabard +3", augments={'Enhances "Chainspell" effect',}},hands="Atrophy Gloves +3",ring1="Sroda Ring",ring2="Epaminondas's Ring",
        back={ name="Sucellos's Cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}},waist="Sailfi Belt +1",legs="Lethargy Fuseau +2", feet="Leth. Houseaux +2"}

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, 
        {})

    sets.precast.WS['Sanguine Blade'] = {}
	
	sets.precast.WS['Aeolian Edge'] = {
	ammo="Demonry Stone",
    head="Leth. Chappel +2",
    body="Lethargy Sayon +2",
    hands="Atrophy Gloves +3",
    legs="Leth. Fuseau +2",
    feet="Leth. Houseaux +2",
    neck="Anu Torque",
    waist="Belisama's Rope +1",
    left_ear="Malignance Earring",
    right_ear="Friomisi Earring",
    left_ring="Jhakri Ring",
    right_ring="Rufescent Ring",
    back={ name="Sucellos's Cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}},
	}

    
    -- Midcast Sets
    
    sets.midcast.FastRecast = {
        head="Atrophy Chapeau +2",ear2="Loquacious Earring",
        body={ name="Viti. Tabard +3", augments={'Enhances "Chainspell" effect',}},hands="Gendewitha Gages",ring1="Prolix Ring",
        back="Swith Cape +1",waist="Witful Belt",legs="Hagondes Pants",feet="Hagondes Sabots"}

    sets.midcast.Cure = {main="Tamaxchi",sub="Genbu's Shield",
        head="Gendewitha Caubeen",neck="Colossus's Torque",ear1="Roundel Earring",ear2="Loquacious Earring",
        body={ name="Viti. Tabard +3", augments={'Enhances "Chainspell" effect',}},hands="Bokwus Gloves",ring1="Ephedra Ring",ring2="Sirona's Ring",
        back="Swith Cape +1",waist="Witful Belt",legs="Atrophy Tights",feet="Hagondes Sabots"}
        
    sets.midcast.Curaga = sets.midcast.Cure
    sets.midcast.CureSelf = {ring1="Kunaji Ring",ring2="Asklepian Ring"}

    sets.midcast['Enhancing Magic'] = {
		main="Pukulatmuj +1",
		head="Lethargy Chappel +2",
		body={ name="Viti. Tabard +3", augments={'Enhances "Chainspell" effect',}},
		hands="Atrophy Gloves +3",
		legs="Leth. Fuseau +2",
		feet="Leth. Houseaux +2",
		neck="Sanctity Necklace",
		waist="Embla Sash",
		left_ear="Loquac. Earring",
		right_ear={ name="Lethargy Earring", augments={'System: 1 ID: 1676 Val: 0','Accuracy+8','Mag. Acc.+8',}},
		left_ring="Jhakri Ring",
		right_ring="Shiva Ring",
		back={ name="Sucellos's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+8','"Fast Cast"+10','Damage taken-1%',}}
	}

    sets.midcast.Refresh = {body="Atrophy Tabard +3",legs="Lethargy Fuseau +2"}

    sets.midcast.Stoneskin = {waist="Siegel Sash"}
	
	sets.midcast.Phalanx = {main="Egeking"}
    
    sets.midcast['Enfeebling Magic'] = {   
		range = "Kaja Bow",	
		head="Atrophy Chapeau +2",
		body="Atrophy Tabard +3",
		hands="Lethargy Gantherots +1",
		legs="Leth. Fuseau +2",
		feet={ name="Vitiation Boots +3", augments={'Immunobreak Chance',}},
		neck="Sanctity Necklace",
		left_ear="Snotra Earring",
		right_ear="Malignance Earring",
		left_ring="Kishar Ring",
		right_ring="Weatherspoon Ring",
		back={ name="Sucellos's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+8','"Fast Cast"+10','Damage taken-1%',}}
	}

    sets.midcast['Dia III'] = set_combine(sets.midcast['Enfeebling Magic'], {head="Viti. Chapeau +4"})

    sets.midcast['Slow II'] = set_combine(sets.midcast['Enfeebling Magic'], {head="Viti. Chapeau +4"})
    
    sets.midcast['Elemental Magic'] ={ 
     	ammo="Witchstone",
		head="Leth. Chappel +2",
		body="Lethargy Sayon +2",
		hands="Atrophy Gloves +3",
		legs="Leth. Fuseau +2",
		feet="Leth. Houseaux +2",
		neck="Sanctity Necklace",
		left_ear="Friomisi Earring",
		left_ring="Jhakri Ring",
		right_ring="Shiva Ring",
		back={ name="Sucellos's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+8','"Fast Cast"+10','Damage taken-1%',}}
	}
        
    sets.midcast.Impact = set_combine(sets.midcast['Elemental Magic'], {head=empty,body="Twilight Cloak"})

    sets.midcast['Dark Magic'] = {main="Lehbrailg +2",sub="Mephitis Grip",ammo="Kalboron Stone",
        head="Atrophy Chapeau +2",neck="Weike Torque",ear1="Lifestorm Earring",ear2="Psystorm Earring",
        body="Vanir Cotehardie",hands="Gendewitha Gages",ring1="Prolix Ring",ring2="Sangoma Ring",
        back="Refraction Cape",waist="Goading Belt",legs="Bokwus Slops",feet="Bokwus Boots"}

    --sets.midcast.Stun = set_combine(sets.midcast['Dark Magic'], {})

    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {ring1="Excelsis Ring", waist="Fucho-no-Obi"})

    sets.midcast.Aspir = sets.midcast.Drain


    -- Sets for special buff conditions on spells.

    sets.midcast.EnhancingDuration = {hands="Atrophy Gloves +3",back="Estoqueur's Cape",feet="Leth. Houseaux +2"}
        
    sets.buff.ComposureOther = {
	head="Leth. Chappel +2",
	body="Lethargy Sayon +2",
    hands="Atrophy Gloves +3",
    legs="Leth. Fuseau +2",
    feet="Leth. Houseaux +2"}

    sets.buff.Saboteur = {hands="Leth. Gantherots +1"}
    

    -- Sets to return to when not performing an action.
    
    -- Resting sets
    sets.resting = {main="Chatoyant Staff",
        head={ name="Viti. Chapeau +4", augments={'Enfeebling Magic duration','Magic Accuracy',}},neck="Wiglen Gorget",
        body="Atrophy Tabard +3",hands="Serpentes Cuffs",ring1="Sheltered Ring",ring2="Paguroidea Ring",
        waist="Austerity Belt",legs="Nares Trews",feet="Chelona Boots +1"}
    

    -- Idle sets
    sets.idle = {main="Bolelabunga",sub="Genbu's Shield",ammo="Impatiens",
        head={ name="Viti. Chapeau +4", augments={'Enfeebling Magic duration','Magic Accuracy',},neck="Wiglen Gorget",ear1="Bloodgem Earring",ear2="Infused Earring",
        body="Atrophy Tabard +3",hands="Yaoyotl Gloves",ring1="Chirich Ring",ring2="Chirich Ring",
        back="Shadow Mantle",waist="Flume Belt",legs="Crimson Cuisses",feet="Leth. Houseaux +2"}
		}

    sets.idle.Town = {main="Bolelabunga",sub="Genbu's Shield",ammo="Impatiens",
        head="Atrophy Chapeau +2",neck="Wiglen Gorget",ear1="Bloodgem Earring",ear2="Infused Earring",
        body="Atrophy Tabard +3",hands="Atrophy Gloves +3",ring1="Chirich Ring",ring2="Chirich Ring",
        back="Shadow Mantle",waist="Flume Belt",legs="Crimson Cuisses",feet="Leth. Houseaux +2"}
    
    sets.idle.Weak = {
	ammo="Demonry Stone",
	head="Malignance Chapeau",
	body="Lethargy Sayon +2",
	hands="Malignance Gloves",
	legs="Malignance Tights",
    feet="Leth. Houseaux +2",
	neck="Loricate Torque +1",
    waist="Flume Belt",
	left_ear="Eabani Earring",
    right_ear="Suppanomimi",
    left_ring="Chirich Ring",
    right_ring="Chirich Ring",
    back={ name="Sucellos's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10',}},
	}

    sets.idle.PDT = {
	ammo="Demonry Stone",
	head="Malignance Chapeau",
	body="Lethargy Sayon +2",
	hands="Malignance Gloves",
	legs="Malignance Tights",
    feet="Malignance Boots",
	neck="Loricate Torque +1",
    waist="Flume Belt",
	left_ear="Eabani Earring",
    right_ear="Suppanomimi",
    left_ring="Chirich Ring",
    right_ring="Chirich Ring",
    back={ name="Sucellos's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10',}},
	}

    sets.idle.MDT = {
	ammo="Demonry Stone",
	head="Malignance Chapeau",
	body="Lethargy Sayon +2",
	hands="Malignance Gloves",
	legs="Leth. Fuseau +2",
    feet="Leth. Houseaux +2",
	neck="Loricate Torque +1",
    waist="Flume Belt",
	left_ear="Eabani Earring",
    right_ear="Suppanomimi",
    left_ring="Chirich Ring",
    right_ring="Chirich Ring",
    back={ name="Sucellos's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10',}},
	}
    
    
    -- Defense sets
    sets.defense.PDT = {
	ammo="Demonry Stone",
    head="Malignance Chapeau",
	body="Lethargy Sayon +2",
	hands="Malignance Gloves",
	legs="Malignance Tights",
    feet="Malignance Boots",
	neck="Loricate Torque +1",
    waist="Flume Belt",
	left_ear="Eabani Earring",
    right_ear="Suppanomimi",
    left_ring="Chirich Ring",
    right_ring="Chirich Ring",
    back={ name="Sucellos's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10',}},
	}

    sets.defense.MDT = {	
	ammo="Demonry Stone",
	head="Leth. Chappel +2",
	body="Lethargy Sayon +2",
	hands="Malignance Gloves",
	legs="Leth. Fuseau +2",
    feet="Leth. Houseaux +2",
	neck="Loricate Torque +1",
    waist="Flume Belt",
	left_ear="Eabani Earring",
    right_ear="Suppanomimi",
    left_ring="Chirich Ring",
    right_ring="Chirich Ring",
    back={ name="Sucellos's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10',}},
	}

    sets.Kiting = {legs="Crimson Cuisses"}

    sets.latent_refresh = {waist="Fucho-no-obi"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion
    
    -- Normal melee group
    sets.engaged = {
    main="Naegling",
    sub="Machaera +2",
    ammo="Ginsen",
    head="Malignance Chapeau",
    body="Lethargy Sayon +2",
    hands="Malignance Gloves",
    legs="Malignance Tights",
    feet="Malignance Boots",
    neck="Anu Torque",
    waist="Windbuffet Belt",
    left_ear="Eabani Earring",
    right_ear="Sherida Earring",
    left_ring="Chirich Ring",
    right_ring="Chirich Ring",
    back={ name="Sucellos's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10',}},
	}

    sets.engaged.PhysicalDef = {
	main="Naegling",
    sub="Ternion Dagger +1",
	ammo="Demonry Stone",
	head="Leth. Chappel +2",
	body="Lethargy Sayon +2",
	hands="Malignance Gloves",
	legs="Malignance Tights",
    feet="Malignance Boots",
	neck="Loricate Torque +1",
    waist="Windbuffet Belt",
	left_ear="Eabani Earring",
    right_ear="Suppanomimi",
    left_ring="Chirich Ring",
    right_ring="Chirich Ring",
    back={ name="Sucellos's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10',}},
	}

end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Enfeebling Magic' and state.Buff.Saboteur then
        equip(sets.buff.Saboteur)
    elseif spell.skill == 'Enhancing Magic' then
        equip(sets.midcast.EnhancingDuration)
        if buffactive.composure and spell.target.type == 'PLAYER' then
            equip(sets.buff.ComposureOther)
        end
    elseif spellMap == 'Cure' and spell.target.type == 'SELF' then
        equip(sets.midcast.CureSelf)
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'Offense Mode' then
        if newValue == 'None' then
            enable('main','sub','range')
        else
            disable('main','sub','range')
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if player.mpp < 51 then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    
    return idleSet
end

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
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
    if player.sub_job == 'DNC' then
        set_macro_page(1, 1)
    elseif player.sub_job == 'NIN' then
        set_macro_page(1, 1)
    elseif player.sub_job == 'THF' then
        set_macro_page(1, 1)
    else
        set_macro_page(1, 1)
    end
	send_command('wait 5;input /lockstyleset 1')
end

