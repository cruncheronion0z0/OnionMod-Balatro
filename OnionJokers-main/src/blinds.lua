--------- BLINDS:

--- the twist
SMODS.Blind{
    key = "twist",
    loc_txt = {
         name = 'The Twist',
         text = { "All cards held in hand are",
        "flipped/unflipped when",
        "each hand is played",},
     },
    name = "The Twist",
    dollars = 5,
    mult = 2,
    boss= {min = 0, max = 6},
    boss_colour = HEX("297711"),
    pos = { x = 0, y = 0},
    vars = {},
    config = {},
    press_play = function(self)
        delay(0.5)
        for a,b in pairs(G.hand.cards) do
            b:flip()
        end
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {}}
    end,
}

--- the spiral
SMODS.Blind{
    key = "spiral",
    loc_txt = {
         name = 'The Spiral',
         text = { "Shuffle the enhancements,",
         "editions & seals",
         "of all played cards."},
     },
    name = "The Spiral",
    dollars = 4,
    mult = 2,
    boss= {min = 3, max = 10},
    boss_colour = HEX("297711"),
    pos = { x = 0, y = 0},
    vars = {},
    config = {},
    press_play = function(self)
        local enhancements = {}
        local seals = {}
        local editions = {}
        local total_sls = 0
        local total_enh = 0
        local total_edi = 0
        if #G.hand.highlighted > 1 then
            for a,b in ipairs(G.hand.highlighted) do
                b:juice_up(0.3,0.5)

                if b.seal then
                    seals[tostring(b.seal)] = (seals[tostring(b.seal)] or 0) + 1
                    total_sls = total_sls + 1
                end

                local enhan = nil
                for c=1, #G.P_CENTER_POOLS.Enhanced do
                    if SMODS.has_enhancement(b,tostring(G.P_CENTER_POOLS.Enhanced[c].key)) then enhan = G.P_CENTER_POOLS.Enhanced[c].key end
                end
                if enhan ~= nil then
                    enhancements[enhan] = (enhancements[enhan] or 0) + 1
                    total_enh = total_enh + 1
                end

                if b.edition ~= nil then
                    editions[tostring(b.edition.key)] = (editions[tostring(b.edition.key)] or 0) + 1
                    total_edi = total_edi + 1
                end
                
                b:set_seal(nil,nil,true)
                b:set_ability(G.P_CENTERS.c_base)
                b:set_edition(nil,true)
            end

            local invalids = {}
            while #invalids < total_sls do
                local possible_targets = {}
                for _,a in pairs(G.hand.highlighted) do
                    if indexOf(invalids,a) == nil then
                        possible_targets[#possible_targets+1] = a
                    end
                end
                local target = pseudorandom_element(possible_targets,pseudoseed("spiral_seal"))
                local seal = pseudorandom_element(get_keys(seals),pseudoseed("a"))
                target:set_seal(seal,true)
                seals[seal] = seals[seal] - 1
                if seals[seal] == 0 then
                    seals[seal] = nil
                end
                invalids[#invalids+1] = target
            end
            invalids = {}

            while #invalids < total_enh do
                local possible_targets = {}
                for _,a in pairs(G.hand.highlighted) do
                    if indexOf(invalids,a) == nil then
                        possible_targets[#possible_targets+1] = a
                    end
                end
                local target = pseudorandom_element(possible_targets,pseudoseed("spiral_enh"))
                local enh = pseudorandom_element(get_keys(enhancements),pseudoseed("a"))
                target:set_ability(enh)
                enhancements[enh] = enhancements[enh] - 1
                if enhancements[enh] == 0 then
                    enhancements[enh] = nil
                end
                invalids[#invalids+1] = target
            end
            invalids = {}

            while #invalids < total_edi do
                local possible_targets = {}
                for _,a in pairs(G.hand.highlighted) do
                    if indexOf(invalids,a) == nil then
                        possible_targets[#possible_targets+1] = a
                    end
                end
                local target = pseudorandom_element(possible_targets,pseudoseed("spiral_enh"))
                local edi = pseudorandom_element(get_keys(editions),pseudoseed("a"))
                target:set_edition(edi,true)
                editions[edi] = (editions[edi] or 1) - 1
                if editions[edi] == 0 then
                    editions[edi] = nil
                end
                invalids[#invalids+1] = target
            end

        end
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {}}
    end,
}

-- the slope
SMODS.Blind{
    key = "slope",
    loc_txt = {
         name = 'The Slope',
         text = { "Lose {C:attention}25%{} of current score",
         "before every hand played"
        }
     },
    name = "The Slope",
    dollars = 5,
    mult = 2,
    boss= {min = 0, max = 13},
    boss_colour = HEX("297711"),
    pos = { x = 0, y = 0},
    vars = {},
    config = {},
    press_play = function(self)
         G.E_MANAGER:add_event(Event({
            trigger = 'ease',
            blocking = false,
            ref_table = G.GAME,
            ref_value = 'chips',
            ease_to = G.GAME.chips - math.floor(G.GAME.chips/4),
            delay =  0.5,
            func = (function(t) return math.floor(t) end)
        }))
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {}}
    end,
}

--- magenta metronome
SMODS.Blind{
    key = "magenta_metronome",
    loc_txt = {
         name = 'Magenta Metronome',
         text = { "All {C:attention}odd{}/{C:attention}even{} cards are {C:red}debuffed{}",
        "switches after each hand",
        "{C:attention}played{} or {C:attention}discarded{}"},
     },
    name = "Magenta Metronome",
    dollars = 8,
    mult = 2,
    boss= {showdown = true},
    boss_colour = HEX("FF00FF"),
    pos = { x = 0, y = 0},
    config = {text1 = "even",text2="odd",is_currently_odd = true},
    set_blind = function(self)
        for i, v in pairs(G.hand.cards) do
            if (v:get_id() + bool_to_number(v:get_id() == 14)) % 2 ~= 0 and (v:get_id() <= 10 or v:get_id() == 14) and v:get_id() > 0 then
                v:set_debuff(true)
            else
                v:set_debuff(false)
            end
        end
    end,
    drawn_to_hand = function(self)
        G.GAME.blind.config.is_currently_odd = not G.GAME.blind.config.is_currently_odd
        for i, v in pairs(G.hand.cards) do
            if (v:get_id() + bool_to_number(v:get_id() == 14)) % 2 ~= bool_to_number(G.GAME.blind.config.is_currently_odd) and (v:get_id() <= 10 or v:get_id() == 14) and v:get_id() > 0 then
                v:set_debuff(true)
            else
                v:set_debuff(false)
            end
        end
    end
}

--- silver spatula
SMODS.Blind{
    key = "silver spatula",
    loc_txt = {
         name = 'Silver Spatula',
         text = { "All cards in hand are","face down & shuffed","after every hand played"},
     },
    name = "Silver Spatula",
    dollars = 8,
    mult = 2,
    boss= {showdown = true},
    boss_colour = HEX("8A8A8A"),
    pos = { x = 0, y = 0},
    config = {},
    press_play = function(self)
        delay(0.5)
        for a,b in pairs(G.hand.cards) do
            if b.facing ~= 'back' then b:flip() end
        end
        if #G.hand.cards > 1 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                           G.hand:shuffle('aajk')
                            play_sound('cardSlide1', 0.85)
                            return true
                        end,
                    }))
                    delay(0.15)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.hand:shuffle('aajk')
                            play_sound('cardSlide1', 1.15)
                            return true
                        end
                    }))
                    delay(0.15)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.hand:shuffle('aajk')
                            play_sound('cardSlide1', 1)
                            return true
                        end
                    }))
                    delay(0.5)
                    return true
                end
            }))
        end
    end
}

--- hazel hourglass