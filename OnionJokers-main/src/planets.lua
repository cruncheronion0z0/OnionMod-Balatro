--- PLANETS:

--- red eye
SMODS.Consumable {
    set = "Planet",
    key = "red_eye",
    --config = {},
    --loc_vars = function(self, info_queue, card)
    --    -- Handle creating a tooltip with seal args.
    --    info_queue[#info_queue+1] = G.P_SEALS[(card.ability or self.config).extra]
    --    -- Description vars
    --    return {vars = {(card.ability or self.config).max_highlighted}}
    --end,
    loc_txt = {
        name = "Red Eye",
        text = {
            "Level up {C:attention}2 {C:attention,E:1}random{}",
            "hands that contain a {C:attention}Flush{}."
        }
    },
    cost = 4,
    atlas = "OnionConsumeables",
    pos = {x=1, y=1},
    can_use = function(self, card) return true end,
    set_card_type_badge = function (self, card, badges)
        badges[#badges+1] = create_badge("Storm", G.C.SECONDARY_SET.Planet, G.C.White, 1.2 )
    end,
    use = function(self, card, area, copier)
        local Fhands = {"Flush", "Straight Flush", "Flush House", "Flush Five","onio_straight_flush_five","onio_straight_flush_house"}

        local to_remove = {}
        for i=1,#Fhands do
            if G.GAME.hands[Fhands[i]].visible == false then
                to_remove[#to_remove+1] = Fhands[i]
            end
        end
        for _,i in pairs(to_remove) do
            Fhands[indexOf(Fhands,i)] = nil
        end


        local hands = {}
        local second_hand = "none"
        hands[#hands+1] = pseudorandom_element(Fhands,pseudoseed("redeye"))
        second_hand = pseudorandom_element(Fhands,pseudoseed("redeye"))
        local i = 0
        while hands[1] == second_hand do
            second_hand = pseudorandom_element(Fhands,pseudoseed("redeye"..tostring(i)))
            i = i + 1
        end
        hands[#hands+1] = second_hand

        for _, v in ipairs(hands) do
            -- display hand value before level up 
            update_hand_text(
                {sound = 'button', volume = 0.4, pitch = 0.8, delay = 0.1}, 
                {
                    handname=localize(v, 'poker_hands'),
                    chips = G.GAME.hands[v].chips,
                    mult = G.GAME.hands[v].mult, 
                    level=G.GAME.hands[v].level
                }
            )
            -- level up the hand
            -- pass card to make tarot card do a little animation
            level_up_hand(card, v) 
            -- set hand back to no special state
            update_hand_text(
                {sound = 'button', volume = 0.4, pitch = 1.1, delay = 0}, 
                {mult = 0, chips = 0, handname = '', level = ''}
            )
        end   
    end
}

--- meteorite
SMODS.Consumable {
    set = "Planet",
    key = "meteorite_planet",
    --config = {},
    --loc_vars = function(self, info_queue, card)
    --    -- Handle creating a tooltip with seal args.
    --    info_queue[#info_queue+1] = G.P_SEALS[(card.ability or self.config).extra]
    --    -- Description vars
    --    return {vars = {(card.ability or self.config).max_highlighted}}
    --end,
    loc_txt = {
        name = "Meteorite",
        text = {
            "Upgrade the level of a random",
            "{C:attention}poker hand{} {C:attention}twice{}."
        }
    },
    cost = 5,
    atlas = "OnionConsumeables",
    pos = {x=2, y=1},
    can_use = function(self, card) return true end,
    set_card_type_badge = function (self, card, badges)
        badges[#badges+1] = create_badge("Rock", G.C.SECONDARY_SET.Planet, G.C.White, 1.2 )
    end,
    use = function(self, card, area, copier)
        local v = pseudorandom_element(G.GAME.hands,pseudoseed("meteorite"))
        while v.visible == false do
            v = pseudorandom_element(G.GAME.hands,pseudoseed("meteorite-"..tostring(v)))
        end
        local i = indexOf(G.GAME.hands,v)
        v = v.key
        -- display hand value before level up
        update_hand_text(
            {sound = 'button', volume = 0.4, pitch = 0.8, delay = 0.1}, 
            {
                handname=localize(i, 'poker_hands'),
                chips = G.GAME.hands[i].chips,
                mult = G.GAME.hands[i].mult, 
                level=G.GAME.hands[i].level
            }
        )
        -- level up the hand
        -- pass card to make tarot card do a little animation
        level_up_hand(card, i) 
        level_up_hand(card, i)
        -- set hand back to no special state
        update_hand_text(
            {sound = 'button', volume = 0.4, pitch = 1.1, delay = 0}, 
            {mult = 0, chips = 0, handname = '', level = ''}
        )  
    end
}

--- eclipse
SMODS.Consumable {
    set = "Planet",
    key = "eclipse_planet",
    --config = {},
    --loc_vars = function(self, info_queue, card)
    --    -- Handle creating a tooltip with seal args.
    --    info_queue[#info_queue+1] = G.P_SEALS[(card.ability or self.config).extra]
    --    -- Description vars
    --    return {vars = {(card.ability or self.config).max_highlighted}}
    --end,
    loc_txt = {
        name = "Eclipse",
        text = {
            "upgrade the level of the {C:attention}least{}",
            "{C:attention}played poker{} hand {C:attention}3{} times",
            "{C:inactive}(Ties are broken randomly)"
        }
    },
    cost = 5,
    atlas = "OnionConsumeables",
    pos = {x=3, y=1},
    can_use = function(self, card) return true end,
    set_card_type_badge = function (self, card, badges)
        badges[#badges+1] = create_badge("Solar Event", G.C.SECONDARY_SET.Planet, G.C.White, 1.2 )
    end,
    use = function(self, card, area, copier)
        local v = G.GAME.hands["High Card"]
        local lowest = 999999
        local lowest_ties = {}
        for _, j in pairs(G.GAME.hands) do
            if j.visible then
                if j.played < lowest then
                    lowest = j.played
                    v = j
                    lowest_ties = {j}
                else
                    if j.played == lowest then
                        lowest_ties[#lowest_ties + 1] = j
                    end
                end
            end
        end
        
        v = pseudorandom_element(lowest_ties,pseudoseed("eclipse"..tostring(v.played)))


        local i = indexOf(G.GAME.hands,v)
        v = v.key
        -- display hand value before level up
        update_hand_text(
            {sound = 'button', volume = 0.4, pitch = 0.8, delay = 0.1}, 
            {
                handname=localize(i, 'poker_hands'),
                chips = G.GAME.hands[i].chips,
                mult = G.GAME.hands[i].mult, 
                level=G.GAME.hands[i].level
            }
        )
        -- level up the hand
        -- pass card to make tarot card do a little animation
        level_up_hand(card, i) 
        level_up_hand(card, i)
        level_up_hand(card, i)

        -- set hand back to no special state
        update_hand_text(
            {sound = 'button', volume = 0.4, pitch = 1.1, delay = 0}, 
            {mult = 0, chips = 0, handname = '', level = ''}
        )
    end
}

--- wormhole
SMODS.Consumable {
    set = "Planet",
    key = "wormhole_planet",
    loc_txt = {
        name = "Wormhole",
        text = {
            "{C:red}remove a random joker.{}",
            "next time this card is used it instead",
            "gives you the {C:attention}joker{} back",
            "with a random {C:attention}edition{}.",
            "{C:inactive}(currrently {C:attention}#1#{})"
        }
    },
    cost = 5,
    atlas = "OnionConsumeables",
    pos = {x=4, y=1},
    loc_vars = function(self, info_queue, card)
        return {vars = {G.GAME.wormhole_joker["display_name"] or "Empty"}}
    end,
    can_use = function(self, card)

        if G.GAME.wormhole_joker["joker"] ~= "nothing" then
            -- gonna give
            if #G.jokers.cards < G.jokers.config.card_limit then
                return true
            end
            return false
        else
            -- gonna take
            valid_jokers = {}
            for _,i in pairs(G.jokers.cards) do
                if i.edition == nil then
                    valid_jokers[#valid_jokers + 1] = i
                end
            end
    
            if #valid_jokers > 0 then
                return true
            end
            return false
        end
        
        return false

    end,
    set_card_type_badge = function (self, card, badges)
        badges[#badges+1] = create_badge("Spacetime Rupture", G.C.SECONDARY_SET.Planet, G.C.White, 1.2 )
    end,
    use = function(self, card, area, copier)

        if G.GAME.wormhole_joker["joker"] == "nothing" then
            local target_joker = "nothing"
            if #G.jokers.cards > 0 then
                valid_jokers = {}
                for _,i in pairs(G.jokers.cards) do
                    if i.edition == nil then
                        valid_jokers[#valid_jokers + 1] = i
                    end
                end
                
                target_joker = pseudorandom_element(valid_jokers ,pseudoseed("wormhole"))
                G.GAME.wormhole_joker["joker"] = target_joker.config.center_key
                G.jokers:remove_card(target_joker)
                G.GAME.wormhole_joker["display_name"] = target_joker.label
                target_joker:start_dissolve()
                delay(0.5)
                --target_joker:remove()
            end
        else
            local new_joker = SMODS.add_card({set="Joker",area=G.jokers,key=G.GAME.wormhole_joker["joker"]})
            local table_editi = G.P_CENTER_POOLS.Edition
            table_editi[1] = nil
            local editi = pseudorandom_element(table_editi,pseudoseed("wormhole_edition")).key
            new_joker:set_edition(editi, true)
            G.GAME.wormhole_joker["joker"] = "nothing"
            G.GAME.wormhole_joker["display_name"] = "Empty"

        end
        
    end
}

--wormhole data/ func inject
local igo = Game.init_game_object
function Game:init_game_object()
    local ret = igo(self)
    ret.wormhole_joker = { joker = "nothing",display_name = "Empty" }
    return ret
end

-- rhea
SMODS.Consumable {
    key = "rhea_planet",
    set = "Planet",
    cost = 3,
    atlas = "OnionConsumeables",
    pos = { x = 7, y = 1 },
    config = { hand_type = 'onio_straight_five', softlock = true },
    loc_txt = {
        name = "Rhea",
        text = {
            "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
            "{C:attention}#2#",
            "{C:mult}+#3#{} Mult and",
            "{C:chips}+#4#{} chips",
        },
    },
    set_card_type_badge = function (self, card, badges)
        badges[#badges+1] = create_badge("Moon", G.C.SECONDARY_SET.Planet, G.C.White, 1.2 )
    end,
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                G.GAME.hands[card.ability.hand_type].level,
                localize(card.ability.hand_type, 'poker_hands'),
                G.GAME.hands[card.ability.hand_type].l_mult,
                G.GAME.hands[card.ability.hand_type].l_chips,
                colours = { (G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]) }
            }
        }
    end
}

-- titan
SMODS.Consumable {
    key = "titan_planet",
    set = "Planet",
    cost = 3,
    atlas = "OnionConsumeables",
    pos = { x = 5, y = 1 },
    config = { hand_type = 'onio_straight_flush_five', softlock = true },
    loc_txt = {
        name = "Titan",
        text = {
            "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
            "{C:attention}#2#",
            "{C:mult}+#3#{} Mult and",
            "{C:chips}+#4#{} chips",
        },
    },
    set_card_type_badge = function (self, card, badges)
        badges[#badges+1] = create_badge("Moon", G.C.SECONDARY_SET.Planet, G.C.White, 1.2 )
    end,
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                G.GAME.hands[card.ability.hand_type].level,
                localize(card.ability.hand_type, 'poker_hands'),
                G.GAME.hands[card.ability.hand_type].l_mult,
                G.GAME.hands[card.ability.hand_type].l_chips,
                colours = { (G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]) }
            }
        }
    end
}

--Iapetus
SMODS.Consumable {
    key = "iapetus_planet",
    set = "Planet",
    cost = 3,
    atlas = "OnionConsumeables",
    pos = { x = 8, y = 1 },
    config = { hand_type = 'onio_straight_house', softlock = true },
    loc_txt = {
        name = "Iapetus",
        text = {
            "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
            "{C:attention}#2#",
            "{C:mult}+#3#{} Mult and",
            "{C:chips}+#4#{} chips",
        },
    },
    set_card_type_badge = function (self, card, badges)
        badges[#badges+1] = create_badge("Moon", G.C.SECONDARY_SET.Planet, G.C.White, 1.2 )
    end,
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                G.GAME.hands[card.ability.hand_type].level,
                localize(card.ability.hand_type, 'poker_hands'),
                G.GAME.hands[card.ability.hand_type].l_mult,
                G.GAME.hands[card.ability.hand_type].l_chips,
                colours = { (G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]) }
            }
        }
    end
}

-- Juice
SMODS.Consumable {
    key = "juice_planet",
    set = "Planet",
    cost = 3,
    atlas = "OnionConsumeables",
    pos = { x = 6, y = 1 },
    config = { hand_type = 'onio_straight_flush_house', softlock = true },
    loc_txt = {
        name = "J.U.I.C.E.",
        text = {
            "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
            "{C:attention}#2#",
            "{C:mult}+#3#{} Mult and",
            "{C:chips}+#4#{} chips",
        },
    },
    set_card_type_badge = function (self, card, badges)
        badges[#badges+1] = create_badge("Spacecraft", G.C.SECONDARY_SET.Planet, G.C.White, 1.2 )
    end,
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                G.GAME.hands[card.ability.hand_type].level,
                localize(card.ability.hand_type, 'poker_hands'),
                G.GAME.hands[card.ability.hand_type].l_mult,
                G.GAME.hands[card.ability.hand_type].l_chips,
                colours = { (G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]) }
            }
        }
    end
}


