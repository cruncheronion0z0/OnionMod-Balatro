----- TAROTS:

--path
SMODS.Consumable {
    set = "Tarot",
    key = "path",
	config = {
        max_highlighted = 2,
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_onio_skip"]
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'The Path',
        text = {
            "Convert up to {C:attention}#1#{} selected",
            "cards into {C:attention}Skip{} cards."
        }
    },
    cost = 3,
    atlas = "OnionConsumeables",
    pos = {x=0, y=2},
    use = function(self, card, area, copier)
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true end }))
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                G.hand.highlighted[i]:juice_up(0.3, 0.5)
                G.hand.highlighted[i]:set_ability("m_onio_skip")
                return true end }))
            
            delay(0.5)
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

--the communion
SMODS.Consumable {
    set = "Tarot",
    key = "communion",
	config = {
        max_highlighted = 3,
    },
    loc_vars = function(self, info_queue, card)
        local r = "None selected"
        if G.hand then
            if #G.hand.highlighted > 0 then
                if #G.hand.highlighted > (card.ability or self.config).max_highlighted then
                    r = "Too many selected"
                else
                    local rankk = 0
                    for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
                        local j = G.hand.highlighted[i].base.id
                        rankk = rankk + j
                    end
                    rankk = math.floor(0.5 + (rankk / #G.hand.highlighted))
                    r = tostring(get_rank_table()[rankk-1])
                end
            end
        end
        return {vars = {(card.ability or self.config).max_highlighted,r}}
    end,
    loc_txt = {
        name = 'The Communion',
        text = {
            "Average the ranks of up to",
            "{C:attention}#1#{} selected cards.",
            "{C:inactive}({C:attention}Aces{C:inactive} high, Currently {C:attention}#2#{C:inactive})"
        }
    },
    cost = 3,
    atlas = "OnionConsumeables",
    pos = {x=0, y=2},
    use = function(self, card, area, copier)

        local rankk = 0
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            rankk = rankk + G.hand.highlighted[i].base.id
        end
        rankk = math.floor(0.5 + (rankk / #G.hand.highlighted))

        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true end }))
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                G.hand.highlighted[i]:juice_up(0.3, 0.5)
                assert(SMODS.change_base(G.hand.highlighted[i], nil, get_rank_table()[rankk-1]))
                return true end }))
            
            delay(0.5)
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

--the stargazer
SMODS.Consumable {
    set = "Tarot",
    key = "stargazer",
	config = {
        most_played = "High Card",
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {
            most_played_hand()
        }}
    end,
    loc_txt = {
        name = 'The Stargazer',
        text = {
            "Create a {C:planet}Planet{} card for your",
            "{C:attention}most{} played poker hand.",
            "{C:inactive}(Must have room, currently {C:attention}#1#{C:inactive}.)"
        }
    },
    cost = 3,
    atlas = "OnionConsumeables",
    pos = {x=0, y=2},
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                if G.consumeables.config.card_limit > #G.consumeables.cards-1 then
                    play_sound('timpani')
                    local _planet = nil
                    for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                        if v.config.hand_type == most_played_hand() then
                            _planet = v.key
                        end
                    end
                    if _planet then
                        SMODS.add_card({ key = _planet })
                    end
                    G.GAME.consumeable_buffer = 0
                    card:juice_up(0.3, 0.5)
                end
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return G.consumeables and #G.consumeables.cards-1 < G.consumeables.config.card_limit
    end
}

--the armor
SMODS.Consumable {
    set = "Tarot",
    key = "armour",
	config = {
        max_highlighted = 1,
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_onio_chainmail"]
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'The Armour',
        text = {
            "Convert {C:attention}#1#{} selected a",
            "into a {C:attention}Chainmail{} card."
        }
    },
    cost = 3,
    atlas = "OnionConsumeables",
    pos = {x=0, y=2},
    use = function(self, card, area, copier)
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true end }))
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                G.hand.highlighted[i]:juice_up(0.3, 0.5)
                G.hand.highlighted[i]:set_ability("m_onio_chainmail")
                return true end }))
            
            delay(0.5)
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

-- spirit
SMODS.Consumable {
    set = "Tarot",
    key = "spirit",
	config = {
        max_highlighted = 2,
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_onio_ethereal"]
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'The Spirit',
        text = {
            "Make up to {C:attention}#1#{} selected",
            "cards {E:1,C:inactive}Ethereal{}."
        }
    },
    cost = 3,
    atlas = "OnionConsumeables",
    pos = {x=0, y=2},
    use = function(self, card, area, copier)
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true end }))
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                G.hand.highlighted[i]:juice_up(0.3, 0.5)
                G.hand.highlighted[i]:set_ability("m_onio_ethereal")
                return true end }))
            
            delay(0.5)
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

--the wanderer

--the relic

--the maze

--the mirror 

--the third eye


