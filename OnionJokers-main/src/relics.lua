SMODS.ConsumableType {
    key = 'Relics',
    default = 'onio_urn',
    collection_rows = { 4, 5 },
    loc_txt = {
 		name = 'Relic',
 		collection = 'Relic Cards'
 	},
    discovered = true,
    primary_colour = HEX("c28246"),
    secondary_colour = HEX("b06933"),
    shop_rate = 0
}

function update_relic_museum(config, card)
    return math.min(5,config.max_highlighted + ternary(G.GAME.used_vouchers.v_onio_museum,1,0))
end

--the urn
SMODS.Consumable {
    discovered = true,
    set = "Relics",
    key = "urn",
	config = {
        -- How many cards can be selected.
        max_highlighted = 2,
        -- the key of the seal to change to
        extra = 'onio_burnt_seal',
    },
    loc_vars = function(self, info_queue, card)
        -- Handle creating a tooltip with seal args.
        info_queue[#info_queue+1] = G.P_SEALS[(card.ability or self.config).extra]
        -- Description vars
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'The Urn',
        text = {
            "Add a {C:attention}Burnt Seal{}",
            "to up to {C:attention}#1#{} selected",
            "cards in your hand"
        }
    },
    cost = 3,
    atlas = "OnionConsumeables",
    pos = {x=2, y=0},
    update = function(self, card, dt)
        card.ability.max_highlighted = update_relic_museum(self.config, card)
    end,
    can_use = function (self, card)
        return (#G.hand.highlighted > 0) and (#G.hand.highlighted <= card.ability.max_highlighted)
    end,
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

--the riches
SMODS.Consumable {
    discovered = true,
    set = 'Relics',
    key = 'riches',
    loc_txt = {
        name = 'The Riches',
        text = {
            "{C:red}Half {C:money}money{} and add {C:money,E:1}Gilded{}",
            "to a random {C:attention}Joker"
        }
    },
    cost = 8,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    soul_pos ={
        x = 7,
        y = 0,
        draw = function(self, card, layer)
            self.children.floating_sprite:draw_shader(
                'onio_gilded',
                nil,
                self.ARGS.send_to_shader,
                nil,
                self.children.center
            )
        end,
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_onio_gilded
        return { vars = {}}
    end,
    use = function(self, card, area, copier)
        ease_dollars(-1 * math.floor(G.GAME.dollars / 2.0), true)
        if G.jokers then
            local target = pseudorandom_element(G.jokers.cards,pseudoseed("gilded"))

            while target:get_edition() ~= nil do
                target = pseudorandom_element(G.jokers.cards,pseudoseed("gilded"..tostring(target)))
            end

            if target:get_edition() == nil then
                target:set_edition("e_onio_gilded", true)
                target:juice_up(0.3, 0.5)
                card:juice_up(0.3, 0.5)
            end
        end
    end,
    can_use = function(self, card)
        if G.jokers then
            if #G.jokers.cards > 0 then
                for i=1,#G.jokers.cards do
                    if G.jokers.cards[1]:get_edition() == nil then
                        return true
                    end
                end
            end
        end
        return false
    end,
    --draw = function(self, card, layer)
    --    if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
    --        card.children.center:draw_shader('onio_gilded', nil, card.ARGS.send_to_shader)
    --    end
    --end
}

--the timepiece
SMODS.Consumable {
    discovered = true,
    set = 'Relics',
    key = 'timepiece',
    loc_txt = {
        name = 'The Timepiece',
        text = {
            "Randomize the {C:attention}rank{} of",
            "and add a {C:attention}Cycle Seal{}",
            "to up to {C:attention}#1#{} selected cards"
        }
    },
    cost = 4,
    atlas = "OnionConsumeables",
    pos = {x=4, y=0},
    config = {
        max_highlighted = 5
    },
    loc_vars = function(self, info_queue, card)
        -- Handle creating a tooltip with seal args.
        info_queue[#info_queue+1] = G.P_SEALS["onio_cycle_seal"]
        -- Description vars
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    update = function(self, card, dt)
        card.ability.max_highlighted = update_relic_museum(self.config, card)
    end,
    can_use = function (self, card)
        return (#G.hand.highlighted > 0) and (#G.hand.highlighted <= card.ability.max_highlighted)
    end,
    use = function(self, card, area, copier)

        G.E_MANAGER:add_event(Event({func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            return true
        end }))

        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                local randrank = pseudorandom_element(get_rank_table(),pseudoseed("time"..tostring(i)))
                G.hand.highlighted[i]:juice_up(0.3, 0.5)
                G.hand.highlighted[i]:set_seal("onio_cycle_seal", nil, true)
                assert(SMODS.change_base(G.hand.highlighted[i], nil, randrank))
                return true
            end }))
        end
        delay(0.5)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

--the pact
SMODS.Consumable {
    discovered = true,
    set = "Relics",
    key = "pact",
	config = {
        -- How many cards can be selected.
        max_highlighted = 1,
        -- the key of the seal to change to
        extra = 'onio_abyssal_seal',
    },
    loc_vars = function(self, info_queue, card)
        -- Handle creating a tooltip with seal args.
        info_queue[#info_queue+1] = G.P_SEALS[(card.ability or self.config).extra]
        -- Description vars
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'The Pact',
        text = {
            "Add a {C:red}Abyssal Seal{} to {C:attention}#1#{}",
            "selected card in hand and",
            "{C:red}Destroy{} {C:attention}1{} card in hand"
        }
    },
    cost = 4,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    update = function(self, card, dt)
        card.ability.max_highlighted = update_relic_museum(self.config, card)
    end,
    can_use = function (self, card)
        return (#G.hand.highlighted > 0) and (#G.hand.highlighted <= card.ability.max_highlighted)
    end,
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
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2,func = function()
                local t = pseudorandom_element(G.hand.cards,pseudoseed("pacttarget"))
                if #G.hand.cards > 1 then
                    while t == G.hand.highlighted[i] do
                        t = pseudorandom_element(G.hand.cards,pseudoseed("pacttarget"..tostring(t:get_id())))
                    end
                    t:start_dissolve()
                    --local t = pseudorandom_element(targets,pseudoseed("pacttarget"))
                    --t:start_dissolve()
                    --SMODS.destroy_cards({t})
                    
                end
            return true end }))
            delay(0.5)
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

--the bundle
SMODS.Consumable {
    discovered = true,
    set = "Relics",
    key = "bundle",
	config = {amount = 5},
    loc_txt = {
        name = 'The Bundle',
        text = {
            "Create {C:attention}#1#{} random {C:attention}Tags{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.amount}}
    end,
    cost = 3,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        for i=1,card.ability.amount do
            add_tag(Tag(pseudorandom_element(get_keys(G.P_TAGS),pseudoseed("tag"))))
        end
    end
}

--the fossil
SMODS.Consumable {
    discovered = true,
    set = "Relics",
    key = "fossil",
	config = {
        -- How many cards can be selected.
        max_highlighted = 2,
    },
    loc_vars = function(self, info_queue, card)
        -- Handle creating a tooltip with seal args.
        info_queue[#info_queue+1] = G.P_CENTERS["m_stone"]
        -- Description vars
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'The Fossil',
        text = {
            "Select up to {C:attention}#1#{} cards, all cards",
            "in your {C:attention}full deck{} with those",
            "ranks become stone cards"
        }
    },
    cost = 3,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    update = function(self, card, dt)
        card.ability.max_highlighted = update_relic_museum(self.config, card)
    end,
    can_use = function (self, card)
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            if G.hand.highlighted[i]:get_id() < 0 then return false end
        end
        return (#G.hand.highlighted > 0) and (#G.hand.highlighted <= card.ability.max_highlighted)
    end,
    use = function(self, card, area, copier)

        local ranks = {}

        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do

            ranks[#ranks+1] = G.hand.highlighted[i]:get_id()

        end

        print(ranks)
        
        for _, c in pairs(G.playing_cards) do
            if indexOf(ranks,c:get_id()) ~= nil then
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                    c:juice_up()
                    c:set_ability('m_stone', nil, true)
                return true end }))
            end
        end

        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

--the portrait
SMODS.Consumable {
    discovered = true,
    set = "Relics",
    key = "portrait",
	config = {
        -- How many cards can be selected.
        max_highlighted = 5,
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'The Portrait',
        text = {
            "Add a {C:attention}Smile{} sticker to up",
            "to {C:attention}#1#{} selected cards in hand",
            "{C:inactive}(Counts as a {C:attention}face {C:inactive}card)"
        }
    },
    cost = 3,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    update = function(self, card, dt)
        card.ability.max_highlighted = update_relic_museum(self.config, card)
    end,
    can_use = function (self, card)
        return (#G.hand.highlighted > 0) and (#G.hand.highlighted <= card.ability.max_highlighted)
    end,
    use = function(self, card, area, copier)
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true end }))
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                G.hand.highlighted[i]:juice_up(0.3, 0.5)
                SMODS.Stickers.onio_smile:apply(G.hand.highlighted[i], true)
                return true end }))
            
            delay(0.5)
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

--the rosary
SMODS.Consumable {
    discovered = true,
    set = 'Relics',
    key = 'rosary',
    loc_txt = {
        name = 'The Rosary',
        text = {
            "{C:money}+$#1#{} for every rank in the ",
            "longest {C:attention}rank chain{} in hand"
        }
    },
    cost = 4,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    config = {},
    config = {
        money = 2
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.money}}
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 1.0,func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
        return true end }))

        local founds = {}
        local longest = 0
        local current_best = {}
        local current_longest = 0
        for i= 1, 14 do
            local found = false
            for j = 1, #G.hand.cards do
                if G.hand.cards[j]:get_id() == i then
                    found = true
                end
            end

            --current_longest = math.max(longest,current_longest)
            if found then
                if longest == 0 then
                    founds = {}
                end
                founds[i] = 1
                longest = longest + 1

                if longest >= current_longest then
                    current_best = founds
                    current_longest = longest
                end

            else
                longest = 0
            end

        end

        for i = 1, #G.hand.cards do
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                
                if current_best[G.hand.cards[i]:get_id()] then
                    if current_best[G.hand.cards[i]:get_id()] == 1 then
                        current_best[G.hand.cards[i]:get_id()] = 2
                        ease_dollars(card.ability.money)
                        card_eval_status_text(G.hand.cards[i], 'jokers', 1, nil, nil, {message = "+$"..tostring(card.ability.money), colour = G.C.MONEY})
                    end
                end

                --G.jokers.cards[i].sell_cost = 2 * G.jokers.cards[i].sell_cost
                --card_eval_status_text(G.jokers.cards[i], 'jokers', 1, nil, nil, {message = "X2 Sell", colour = G.C.MONEY})
            return true end }))
            
        end

    end,
    can_use = function(self, card)
        if #G.hand.cards > 0 then
            return true
        end
        return false
    end
}

--the crusifix
SMODS.Consumable {
    discovered = true,
    set = 'Relics',
    key = 'crusifix',
    loc_txt = {
        name = 'The Crusifix',
        text = {
            "Select {C:attention}#1#{} card, all {C:attention}unenhanced",
            "cards of that {C:attention}suit{} in hand",
            "gain a random {C:attention}Enhancement",
        }
    },
    cost = 4,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    config = {
        max_highlighted = 1,
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.max_highlighted}}
    end,
    update = function(self, card, dt)
        card.ability.max_highlighted = update_relic_museum(self.config, card)
    end,
    can_use = function (self, card)
        return (#G.hand.highlighted > 0) and (#G.hand.highlighted <= card.ability.max_highlighted)
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
        return true end }))

        local suits = {}
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            for _,j in pairs(get_suit_table()) do
                if G.hand.highlighted[i]:is_suit(j) then suits[j] = true end
            end
        end

        for i = 1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                local allow = false
                for j,_ in pairs(suits) do
                    if G.hand.cards[i]:is_suit(j) then allow = true end
                end
                if next(SMODS.get_enhancements(G.hand.cards[i])) then allow = false end
                if allow then
                    G.hand.cards[i]:juice_up(0.3, 0.5)
                    G.hand.cards[i]:set_ability(pseudorandom_element(G.P_CENTER_POOLS.Enhanced,pseudoseed(tostring("glitch_404"))).key, nil, true)
                end
                return true end }))
        end

    end
}

--the skull
SMODS.Consumable {
    discovered = true,
    set = 'Relics',
    key = 'skull',
    loc_txt = {
        name = 'The Skull',
        text = {
            "Create a {E:1,C:dark_edition}negative",
            "{C:tarot}perishable{} {C:attention}Mr.Bones"
        }
    },
    cost = 4,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["j_mr_bones"]
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
        return { vars = {}}
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            local new_joker = SMODS.add_card({set = 'Joker', edition = "e_negative", key = "j_mr_bones" })
            SMODS.Stickers.perishable:apply(new_joker, true)
        return true end }))
    end,
    can_use = function(self, card)
        return true
    end,
}                

--the dagger
SMODS.Consumable {
    discovered = true,
    set = 'Relics',
    key = 'dagger',
    loc_txt = {
        name = 'The Dagger',
        text = {
            "{C:red}Destroy{} the rightmost {C:attention}Joker",
            "and gain {X:money,C:white}X#1#{} its {C:attention}sell value"
        }
    },
    cost = 4,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    config = {
        money_mul = 4
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.money_mul}}
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            if not SMODS.is_eternal(G.jokers.cards[#G.jokers.cards], card) then
                ease_dollars(card.ability.money_mul * (G.jokers.cards[#G.jokers.cards].sell_cost), true)
                G.jokers.cards[#G.jokers.cards]:start_dissolve(nil, false)
            end
        return true end }))
    end,
    can_use = function(self, card)
        if #G.jokers.cards > 0 then
            if not SMODS.is_eternal(G.jokers.cards[#G.jokers.cards], card) then
                return true
            end
        end
        return false
    end,
} 

--the gauntlet
SMODS.Consumable {
    discovered = true,
    set = 'Relics',
    key = 'gauntlet',
    loc_txt = {
        name = 'The Gauntlet',
        text = {
            "{C:blue}+1 Hand{} per round",
            "make a random {C:attention}Joker{} {E:1,C:attention}eternal",
            "{C:inactive}(Must be compatible)"
        }
    },
    cost = 4,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    config = {
        money_mul = 4
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.money_mul}}
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
            ease_hands_played(1)
            local targets = {}
            for _,i in pairs(G.jokers.cards) do
                if i.config.center.eternal_compat and not SMODS.is_eternal(i, card) and not i.ability.perishable and not i.ability.onio_fragile then
                    targets[#targets+1] = i
                end
            end
            local tar = pseudorandom_element(targets,pseudoseed("gaunt"))
            tar:juice_up(0.3, 0.5)
            SMODS.Stickers.eternal:apply(tar, true)
            
        return true end }))
    end,
    can_use = function(self, card)
        if #G.jokers.cards > 0 then
            for _,i in pairs(G.jokers.cards) do
                if i.config.center.eternal_compat and not SMODS.is_eternal(i, card) and not i.ability.perishable and not i.ability.onio_fragile then
                    return true
                end
            end
        end
        return false
    end,
}

--the crystal
SMODS.Consumable {
    discovered = true,
    set = 'Relics',
    key = 'crystal',
    loc_txt = {
        name = 'The Crystal',
        text = {
            "create a {C:dark_edition}polychrome{}, {C:gold}gilded{},",
            "or rarely {C:dark_edition}negative{} {C:attention}Glass Card",
        }
    },
    cost = 4,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    config = {},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
        info_queue[#info_queue + 1] = G.P_CENTERS.e_onio_gilded
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
        info_queue[#info_queue+1] = G.P_CENTERS["m_glass"]
        return { vars = {}}
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            local suitt = pseudorandom_element(get_suit_table(),pseudoseed("suit"))
            local rankk = pseudorandom_element(get_rank_table(),pseudoseed("rank"))
            local id = tostring(tostring(rankk:sub(1,1)).."_"..tostring(rankk:sub(1,1))):upper()
            local new_card = create_playing_card({
                front = G.P_CARDS[id], 
                center = G.P_CENTERS.c_base}, G.hand, nil, nil, {G.C.SECONDARY_SET.Enhanced}
            )
            G.deck.config.card_limit = G.deck.config.card_limit + 1
            SMODS.change_base(new_card, suitt, rankk)
            new_card:set_ability(G.P_CENTERS.m_glass)
            new_card:set_edition(pseudorandom_element({"e_polychrome","e_polychrome","e_polychrome","e_onio_gilded","e_onio_gilded","e_negative"}), true)
            new_card:juice_up(0.3, 0.5)
        return true end }))
    end,
    can_use = function(self, card)
        if #G.hand.cards > 0 then
            return true
        end
        return false
    end,
}

--the amulet
SMODS.Consumable {
    discovered = true,
    set = 'Relics',
    key = 'amulet',
    loc_txt = {
        name = 'The Amulet',
        text = {
            "{C:attention}Double{} the {C:attention}sell value",
            "of all owned  {C:attention}Jokers"
        }
    },
    cost = 4,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    config = {},
    loc_vars = function(self, info_queue, card)
        return { vars = {}}
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
        return true end }))

        for i = 1, #G.jokers.cards do
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                --G.jokers.cards[i]:juice_up(0.03, 0.5)
                G.jokers.cards[i].sell_cost = 2 * G.jokers.cards[i].sell_cost
                card_eval_status_text(G.jokers.cards[i], 'jokers', 1, nil, nil, {message = "X2 Sell", colour = G.C.MONEY})
            return true end }))
            
            delay(0.5)
        end

    end,
    can_use = function(self, card)
        if #G.jokers.cards > 0 then
            return true
        end
        return false
    end,
}

--the ingot
SMODS.Consumable {
    discovered = true,
    set = "Relics",
    key = "ingot",
	config = {
        -- How many cards can be selected.
        max_highlighted = 4,
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_steel"]
        info_queue[#info_queue+1] = G.P_CENTERS["m_gold"]
        info_queue[#info_queue+1] = G.P_CENTERS["m_onio_chainmail"]
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'The Ingot',
        text = {
            "Enhances up to {C:attention}#1#{} selected cards",
            "into {C:attention}Steel{}, {C:attention}Gold{} or {C:attention}Chainmail Cards{}",
            "and {C:red}removes{} all {C:attention}editions{} & {C:attention}seals{}",
            "from selected cards"
        }
    },
    cost = 3,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    update = function(self, card, dt)
        card.ability.max_highlighted = update_relic_museum(self.config, card)
    end,
    can_use = function (self, card)
        return (#G.hand.highlighted > 0) and (#G.hand.highlighted <= card.ability.max_highlighted)
    end,
    use = function(self, card, area, copier)
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                G.hand.highlighted[i]:flip()
                return true end }))
            delay(0.2)
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                G.hand.highlighted[i]:juice_up(0.3, 0.5)
                G.hand.highlighted[i]:set_ability(pseudorandom_element({"m_steel","m_gold","m_onio_chainmail"},pseudoseed("ingot")), nil, true)
                G.hand.highlighted[i]:set_edition(nil)
                G.hand.highlighted[i]:set_seal(nil)
                return true end }))
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function()
                G.hand.highlighted[i]:flip()
                return true end }))
            
        end
        delay(0.5)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

--the scroll
SMODS.Consumable {
    discovered = true,
    set = "Relics",
    key = "scroll",
	config = {
        -- How many cards can be selected.
        max_highlighted = 4,
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_lucky"]
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'The Scroll',
        text = {
            "Enhances up to {C:attention}#1#{} selected cards",
            "into {C:attention}Lucky Cards{} then {C:red}destroys{}",
            "{C:attention}1{} random selected card"
        }
    },
    cost = 3,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    update = function(self, card, dt)
        card.ability.max_highlighted = update_relic_museum(self.config, card)
    end,
    can_use = function (self, card)
        return (#G.hand.highlighted > 0) and (#G.hand.highlighted <= card.ability.max_highlighted)
    end,
    use = function(self, card, area, copier)
        local target = pseudorandom_element(G.hand.highlighted,pseudoseed("scrollkill"))
        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true end }))
            
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                if G.hand.highlighted[i] ~= target then
                    G.hand.highlighted[i]:juice_up(0.3, 0.5)
                    G.hand.highlighted[i]:set_ability('m_lucky', nil, true)
                end
                return true end }))
            
            delay(0.5)
        end
        SMODS.destroy_cards({target})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    end
}

--the coin
SMODS.Consumable {
    discovered = true,
    set = 'Relics',
    key = 'coin',
    loc_txt = {
        name = 'The Coin',
        text = {
            "Lose {C:red}-$#3#",
            "{C:green}#1# in #2#{} chance to create a",
            "{C:gold}Gold {E:1,C:money}Gilded{} {}Ace of {C:diamonds}Diamonds",
            "with a {C:gold}Gold Seal{}"
        }
    },
    cost = 4,
    atlas = "OnionConsumeables",
    pos = {x=0, y=0},
    config = {
        cost = 5,
        chance = 1,
        odds = 3
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_onio_gilded
        info_queue[#info_queue+1] = G.P_CENTERS["m_gold"]
        info_queue[#info_queue+1] = G.P_SEALS["Gold"]
        return { vars = {
            (card.ability.chance * G.GAME.probabilities.normal) or G.GAME.probabilities.normal,
            card.ability.odds,
            card.ability.cost
        }}
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            ease_dollars(-card.ability.cost, true)
            if pseudorandom('sung') < ((card.ability.chance * G.GAME.probabilities.normal) / card.ability.odds) then
                local new_card = create_playing_card({
                        front = G.P_CARDS.D_A, 
                        center = G.P_CENTERS.c_base}, G.hand, nil, nil, {G.C.SECONDARY_SET.Enhanced}
                    )
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    SMODS.change_base(new_card, "Diamonds", "Ace")
                    new_card:set_ability(G.P_CENTERS.m_gold)
                    new_card:set_seal("Gold", nil, true)
                    new_card:set_edition("e_onio_gilded", true)
                    new_card:juice_up(0.3, 0.5)
            else
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        attention_text({
                            text = localize('k_nope_ex'),
                            scale = 1.3,
                            hold = 1.4,
                            major = card,
                            backdrop_colour = G.C.SECONDARY_SET.Tarot,
                            align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and
                                'tm' or 'cm',
                            offset = { x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and -0.2 or 0 },
                            silent = true
                        })
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.06 * G.SETTINGS.GAMESPEED,
                            blockable = false,
                            blocking = false,
                            func = function()
                                play_sound('tarot2', 0.76, 0.4)
                                return true
                            end
                        }))
                        play_sound('tarot2', 1, 0.4)
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
            end
            delay(0.5)
        return true end }))
    end,
    can_use = function(self, card)
        if #G.hand.cards > 0 then
            return true
        end
        return false
    end,
}

--the past
SMODS.Consumable {
    discovered = true,
    set = 'Relics',
    key = 'past',
    loc_txt = {
        name = 'The Past',
        text = {
            "{C:attention,E:1}-5 Ante{}",
            "{C:inactive}(Min {C:attention}Ante 0{C:inactive})"
        }
    },
    cost = 10,
    atlas = "OnionConsumeables",
    hidden = true,
    soul_set = 'Spectral',
    soul_rate = 0.01,
    pos = {x=0, y=0},
    soul_pos ={
        x = 7,
        y = 0,
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {}}
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            local loss = -1 * math.min(G.GAME.round_resets.blind_ante,5)
            ease_ante(loss)
            G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
            G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - loss

        return true end }))
    end,
    can_use = function(self, card)
        return true
    end,
}

