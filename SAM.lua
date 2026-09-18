function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function job_setup()
    state.WSSelection = M{['description'] = 'Selected Weapon skill'}
    state.WSSelection:options('fudo','jinpu','shoha')
    state.WSSelection:set('fudo')
    WeaponSkills = {['fudo'] = 'Fudo',['jinpu']='jinpu',['shoha']='shoha'}
	include('PrecastReadyCheck.lua')
	include('TPGate')
end

function user_setup()
    on_job_change()	
    send_command('bind ^` gs c cycle WSSelection')
    send_command('bind ~^` gs c cycleback WSSelection')
end

function user_unload()
    send_command('unbind ^` gs c cycle WSSelection')
    send_command('unbind ~^` gs c cycleback WSSelection')
end


function init_gear_sets()
    gear.BackTP = { name="Smertrios's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%',}}
    gear.BackPWS = { name="Smertrios's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Phys. dmg. taken-10%',}}

    sets.precast.FC = {}  -- Fast Cast Set

    -- sets.precast.RA = {}  -- Ranged delay reduction.  Ignore if uneeded, remove the first "--" to activate.

    sets.precast.JA["Warding Circle"] = {head="Wakido Kabuto +3"}
    sets.precast.JA["Third Eye"] = {legs="Sakonji Haidate +3"}
    sets.precast.JA["Meditate"] = {
        head="Wakido Kabuto +3",
        hands="Sakonji kote +3",
        back=gear.BackTP
    }
    sets.precast.JA["Seigan"] = {head="Kasuga Kabuto +3"}
    sets.precast.JA["Sekkanoki"] = {hands="Kasuga Kote +3"}
    sets.precast.JA["Blade Bash"] = {hands="Sakonji kote +3"}
    sets.precast.JA["Sengikori"] = {feet="Kas. Sune-Ate +3"}
    --sets.precast.JA["Meikyo Shisui"] = {feet="Sakonji sune-ate +3"}
        --[[sets.precast.JA["Hasso"] = { -- Must stay equiped to gain the benefit
        hands="Wakido Kote +3",
        legs="Kasuga Haidate +3",
        feet="Wakido Sune. +3"
    }]]

    sets.precast.WS = {
    ammo="Aurgelmir Orb",
    head="Mpaca's Cap",
    body="Sakonji Domaru +4",
    hands="Kasuga Kote +2",
    legs="Wakido Haidate +3",
    feet="Nyame Sollerets",
    neck="Moonbeam Nodowa",
    waist="Sailfi Belt +1",
    left_ear="Thrud Earring",
    right_ear={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +250',}},
    left_ring="Sroda Ring",
    right_ring="Epaminondas's Ring",
    back={ name="Smertrios's Mantle", augments={'STR+20','Accuracy+20 Attack+20','Weapon skill damage +10%',}},
    }

    sets.precast.WS['Tachi: Jinpu'] = set_combine(sets.precast.WS,{
        
    })

    sets.precast.WS['Raiden Thrust'] = set_combine(sets.precast.WS,{
        
    })
	sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS,{
    ammo="Ghastly Tathlum",
    head="Nyame Helm",
    body="Nyame Mail",
    hands="Nyame Gauntlets",
    legs="Nyame Flanchard",
    feet="Nyame Sollerets",
    neck="Moonbeam Nodowa",
    waist="Eschan Stone",
    left_ear="Friomisi Earring",
    right_ear="Moonshade Earring",
    back={ name="Smertrios's Mantle", augments={'STR+20','Accuracy+20 Attack+20','Weapon skill damage +10%',}},
    })
	


    -- sets.midcast.RA = {} -- Ranged TP Set.  Ignore if uneeded, remove the first "--" to activate.

    sets.defense.PDT = {
	ammo="Staunch Tathlum",
    head="Nyame Helm",
    body="Nyame Mail",
    hands="Nyame Gauntlets",
    legs="Kasuga Haidate +2",
    feet="Nyame Sollerets",
    neck="Moonbeam Nodowa",
    waist="Ioskeha Belt +1",
    left_ear="Eabani Earring",
    right_ear={ name="Kasuga Earring", augments={'System: 1 ID: 1676 Val: 0','Accuracy+6','Mag. Acc.+6',}},
    left_ring="Chirich Ring +1",
    right_ring="Chirich Ring +1",
    back={ name="Smertrios's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%',}},
    }
	
	sets.defense.MDT = {
	ammo="Aurgelmir Orb",
    head="Kasuga Kabuto +2",
    body="Kasuga Domaru +2",
    hands="Nyame Gauntlets",
    legs="Kasuga Haidate +2",
    feet="Nyame Sollerets",
    neck="Moonbeam Nodowa",
    waist="Ioskeha Belt +1",
    left_ear="Schere Earring",
    right_ear={ name="Kasuga Earring", augments={'System: 1 ID: 1676 Val: 0','Accuracy+6','Mag. Acc.+6',}},
    left_ring="Chirich Ring +1",
    right_ring="Chirich Ring +1",
    back={ name="Smertrios's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%',}},
    }

    sets.idle = {
    ammo="Aurgelmir Orb",
	head="Nyame Helm",
    body="Nyame Mail",
    hands="Nyame Gauntlets",
    legs="Nyame Flanchard",
    feet="Nyame Sollerets",
    neck="Moonbeam Nodowa",
    waist="Ioskeha Belt +1",
    left_ear="Schere Earring",
    right_ear={ name="Kasuga Earring", augments={'System: 1 ID: 1676 Val: 0','Accuracy+6','Mag. Acc.+6',}},
    left_ring="Paguroidea Ring",
    right_ring="Defending Ring",
    back={ name="Smertrios's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%',}},
    }

    sets.idle.Town = set_combine(sets.idle, {body="Councilor's Garb",})

    sets.engaged = {
    ammo="Aurgelmir Orb",
    head="Kasuga Kabuto +2",
    body="Kasuga Domaru +2",
    hands="Wakido Kote +3",
    legs="Kasuga Haidate +2",
    feet="Tatena. Sune. +1",
    neck="Moonbeam Nodowa",
    waist="Ioskeha Belt +1",
    left_ear="Schere Earring",
    right_ear={ name="Kasuga Earring", augments={'System: 1 ID: 1676 Val: 0','Accuracy+6','Mag. Acc.+6',}},
    left_ring="Chirich Ring +1",
    right_ring="Chirich Ring +1",
    back={ name="Smertrios's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%',}},
    }
end

function job_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'ws' then
        if cmdParams[2]:lower() == 'use' then
            send_command('input /ws "Tachi: '..WeaponSkills[state.WSSelection.value]..'" <t>')
        elseif  cmdParams[2]:lower() == 'set' then
            if state.WSSelection:contains(cmdParams[3]:lower()) then
                state.WSSelection:set(cmdParams[3]:lower())
            else
                add_to_chat(123,"Not a selectable Weaponskill")
            end
        end
    end
end

function on_job_change()
    set_macro_page(1, 1)
    send_command('wait 5;input /lockstyleset 1')
end