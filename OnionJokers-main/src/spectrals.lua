----- SPECTRALS:

-- The Clown
SMODS.Consumable {
    key = 'the_clown',
    set = 'Spectral',
    hidden = true,
    soul_set = 'Joker',
    soul_rate = 0.01,
    loc_txt = {
        name = 'The Clown',
        text = {
            "Create a {E:1,C:dark_edition}negative{}",
            "{C:rare}Rare{} Joker"
        }
    },
    cost = 6,
    atlas = "OnionConsumeables",
    pos = {x=6, y=0},
    soul_pos = {
        x=7,
        y=0,
        --draw = function(self, card, layer)
        --    self.children.floating_sprite:draw_shader(
        --        'foil',
        --        nil,
        --        self.ARGS.send_to_shader,
        --        nil,
        --        self.children.center
        --    )
        --end,
    },
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                SMODS.add_card({ set = 'Joker', rarity = 1,edition = "e_negative" })
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return G.jokers
    end,
    draw = function(self, card, layer)
        if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
            card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
        end
    end
}

--- solar flare (solar seal)
SMODS.Consumable {
    set = "Spectral",
    key = "solar_flare",
	config = {
        -- How many cards can be selected.
        max_highlighted = 1,
        -- the key of the seal to change to
        extra = 'onio_solar_seal',
    },
    loc_vars = function(self, info_queue, card)
        -- Handle creating a tooltip with seal args.
        info_queue[#info_queue+1] = G.P_SEALS[(card.ability or self.config).extra]
        -- Description vars
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'Solar Flare',
        text = {
            "Add a {C:attention}Solar Seal{}",
            "to {C:attention}#1#{} selected",
            "card in your hand"
        }
    },
    cost = 6,
    atlas = "OnionConsumeables",
    pos = {x=1, y=0},
    use = function(self, card, area, copier)
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true end }))
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                G.hand.highlighted[i]:juice_up(0.3, 0.5)
                G.hand.highlighted[i]:set_seal(card.ability.extra, nil, true)
                return true end }))
            
            delay(0.5)
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

--- 404 error (glitch seal)
SMODS.Consumable {
    set = "Spectral",
    key = "404_error",
	config = {
        -- How many cards can be selected.
        max_highlighted = 1,
        -- the key of the seal to change to
        extra = 'onio_glitch_seal',
    },
    loc_vars = function(self, info_queue, card)
        -- Handle creating a tooltip with seal args.
        info_queue[#info_queue+1] = G.P_SEALS[(card.ability or self.config).extra]
        -- Description vars
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'ERROR::NOT FOUND',
        text = {
            "Randomize the {C:attention}Enhancment{}",
            "and add a {C:attention}Glitch Seal{}",
            "to {C:attention}#1#{} selected",
            "card in your hand"
        }
    },
    cost = 6,
    atlas = "OnionConsumeables",
    pos = {x=3, y=0},
    use = function(self, card, area, copier)
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true end }))
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                G.hand.highlighted[i]:juice_up(0.3, 0.5)
                G.hand.highlighted[i]:set_seal(card.ability.extra, nil, true)
                G.hand.highlighted[i]:set_ability(pseudorandom_element(G.P_CENTER_POOLS.Enhanced,pseudoseed(tostring("glitch_404"))).key)
                return true end }))
            
        end
        delay(0.5)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

-- the rift
SMODS.Consumable {
    set = "Spectral",
    key = "rift",
	config = {
        -- How many cards can be selected.
        max_highlighted = 5,
    },
    loc_vars = function(self, info_queue, card)
        -- Handle creating a tooltip with seal args.
        -- Description vars
        return {vars = {}}
    end,
    loc_txt = {
        name = 'The Rift',
        text = {
            "Select up to {C:attention}5{} cards,",
            "{C:red}destroy{} them and {C:attention}level up{}",
            "the hand they make {C:attention}3{} times.",
        }
    },
    cost = 5,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    can_use = function(self, card)
        if #G.hand.highlighted <= 5 and #G.hand.highlighted > 0 then
            return true
        end
        return false
    end,
    use = function(self, card, area, copier)

        local text,disp_text,poker_hands = G.FUNCS.get_poker_hand_info(G.hand.highlighted)

        local i = indexOf(G.GAME.hands,text)
        
        -- display hand value before level up
        update_hand_text(
            {sound = 'button', volume = 0.4, pitch = 0.8, delay = 0.1}, 
            {
                handname=text,
                chips = G.GAME.hands[text].chips,
                mult = G.GAME.hands[text].mult, 
                level=G.GAME.hands[text].level
            }
        )
        -- level up the hand
        -- pass card to make tarot card do a little animation
        level_up_hand(card, text)
        level_up_hand(card, text)
        level_up_hand(card, text)

        -- set hand back to no special state
        update_hand_text(
            {sound = 'button', volume = 0.4, pitch = 1.1, delay = 0}, 
            {mult = 0, chips = 0, handname = '', level = ''}
        )
        
        delay(0.5)
        SMODS.destroy_cards(G.hand.highlighted)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

--- eternity
SMODS.Consumable {
    set = "Spectral",
    key = "eternity",
	config = {
        -- How many cards can be selected.
        max_highlighted = 1,
        -- the key of the seal to change to
        extra = 'onio_ouroboros_seal',
    },
    loc_vars = function(self, info_queue, card)
        -- Handle creating a tooltip with seal args.
        info_queue[#info_queue+1] = G.P_SEALS[(card.ability or self.config).extra]
        -- Description vars
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'Eternity',
        text = {
            "Add a {C:dark_edition}Ouroboros Seal{} to {C:attention}#1#{}",
            "selected card in hand and",
            "{C:red}Destroy{} all other cards",
        }
    },
    cost = 4,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    use = function(self, card, area, copier)
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true end }))
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                G.hand.highlighted[i]:juice_up(0.3, 0.5)
                G.hand.highlighted[i]:set_seal(card.ability.extra, nil, true)

                return true end }))
            
            if #G.hand.cards > 1 then
                for _,t in pairs(G.hand.cards) do
                    if t ~= G.hand.highlighted[i] then
                        t:start_dissolve()
                    end
                end
                
                --local t = pseudorandom_element(targets,pseudoseed("pacttarget"))
                --t:start_dissolve()
                --SMODS.destroy_cards({t})
                
                delay(0.5)
            end
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

--- the mirage
SMODS.Consumable {
    set = "Spectral",
    key = "mirage",
	config = {
        max_highlighted = 1,
    },
    loc_vars = function(self, info_queue, card)
        -- Handle creating a tooltip with seal args.
        info_queue[#info_queue+1] = G.P_CENTERS["m_onio_illusion"]
        -- Description vars
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'Mirage',
        text = {
            "Enhance {C:attention}#1#{} selected card",
            "into an {C:attention}Illusion Card"
        }
    },
    cost = 6,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    use = function(self, card, area, copier)
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                G.hand.highlighted[i]:flip()
                return true end }))
            delay(0.2)
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                G.hand.highlighted[i]:set_ability('m_onio_illusion', nil, true)
                return true end }))

             G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function()
                G.hand.highlighted[i]:flip()
                return true end }))
            
        end
        delay(0.5)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

-- the sarcophagus
SMODS.Consumable {
    set = "Spectral",
    key = "sarcophagus",
	config = {},
    loc_vars = function(self, info_queue, card)
        return {vars = {}}
    end,
    loc_txt = {
        name = 'The Sarcophagus',
        text = {
            "Create {C:attention}2{} {C:attention}Relic{} cards",
            "{C:red}-$2{} for each {C:attention}Relic{} card created",
        }
    },
    cost = 3,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                card:juice_up(0.3, 0.5)
                for i=1,2 do
                    if #G.consumeables.cards < G.consumeables.config.card_limit then
                        ease_dollars(-2, true)
                        local new_card = SMODS.add_card({set = "Relics"})
                        G.GAME.consumeable_buffer = 0
                    end
                end
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return true--G.consumeables and #G.consumeables.cards-1 < G.consumeables.config.card_limit
    end
}

