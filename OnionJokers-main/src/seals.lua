--------- SEALS:

-- burnt seal
SMODS.Seal {
    name = "BurntSeal",
    key = "burnt_seal",
    badge_colour = HEX("4a1e1e"),
	config = { money=6,remaining=3,total=3  },
    loc_txt = {
        label = 'Burnt Seal',
        name = 'Burnt Seal',
        text = {
            '{C:money}+$#1#{} when this card is destroyed.',
            'increase by {C:money}+$2{} every {C:attention}#3#{} discards.',
            "{C:inactive}({C:attention}#2#{C:inactive} remaining.)"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.seal.money,card.ability.seal.remaining,card.ability.seal.total} }
    end,
    atlas = 'OnionSeals',
    pos = {x=1, y=0},
    calculate = function(self, card, context)

        if context.discard then
            if context.other_card == card then
                card.ability.seal.remaining = card.ability.seal.remaining - 1
                context.other_card.ability.seal.remaining = card.ability.seal.remaining
                if card.ability.seal.remaining <= 0 then
                    card.ability.seal.remaining = card.ability.seal.total
                    context.other_card.ability.seal.remaining = card.ability.seal.remaining
                    card.ability.seal.money = card.ability.seal.money + 2
                    
                    return {
                        message = "Upgraded!",
                        colour = G.C.MONEY
                    }
                else
                    return {
                        message = tostring(card.ability.seal.total - card.ability.seal.remaining).."/"..tostring(card.ability.seal.total),
                        colour = G.C.MONEY
                    }
                end
            end
        end

        if context.remove_playing_cards then
            for _, v in pairs(context.removed) do
                if v == card then
                    return {dollars = card.ability.seal.money}
                end
            end
        end

    end
}

-- solar seal
SMODS.Seal {
    name = "SolarSeal",
    key = "solar_seal",
    badge_colour = HEX("0345fc"),
	config = {odds = 3},
    loc_txt = {
        label = 'Solar Seal',
        name = 'Solar Seal',
        text = {
            '{C:green}#1# in #2#{} chance to {C:attention}level up{} the',
            'played {C:attention}poker hand{} before scoring.'
        }
    },
    atlas = 'OnionSeals',
    pos = {x=0, y=0},
    loc_vars = function(self, info_queue)
        return { vars = {''..(G.GAME and G.GAME.probabilities.normal or 1),self.config.odds} }
    end,
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.play then

            if pseudorandom('solar_seal') < (G.GAME.probabilities.normal / self.config.odds) then
                return {level_up = 1,message="Level Up!",color=G.C.blue}
            end
        end
    end
}

--- glitch seal
SMODS.Seal {
    name = "GlitchSeal",
    key = "glitch_seal",
    badge_colour = HEX("d321ff"),
	config = {},
    loc_txt = {
        label = 'Glitch Seal',
        name = 'Glitch Seal',
        text = {
            "{C:attention}discard{} this card to",
            "randomize its {C:dark_edition}edition{}."
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = {self.config.chance} }
    end,
    --draw = function(self, card, layer)
    --    if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
    --        G.shared_seals[card.seal].role.draw_major = card
    --        G.shared_seals[card.seal]:draw_shader('polychrome', nil, card.ARGS.send_to_shader, nil, card.children.center)
    --    end
    --end,
    atlas = 'OnionSeals',
    pos = {x=2, y=0},
    calculate = function(self, card, context)
        if context.discard and not next(SMODS.find_card("j_onio_corrupted_joker")) then
            if context.other_card == card then
                
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.25,
                    func = (function()
                        local editi = pseudorandom_element(G.P_CENTER_POOLS.Edition,pseudoseed("gseal")).key
                        local i = "1"
                        if card.edition == nil then
                            while editi == "e_base" do 
                                editi = pseudorandom_element(G.P_CENTER_POOLS.Edition,pseudoseed(i)).key
                                i = i + "1"
                            end
                        else
                            while editi == "e_base" or editi == card.edition.key do 
                                editi = pseudorandom_element(G.P_CENTER_POOLS.Edition,pseudoseed(i)).key
                                i = i + "1"
                            end
                        end

                        if editi == "e_negative" then
                            if not negative_less_likely() then
                                editi = pseudorandom_element(G.P_CENTER_POOLS.Edition,pseudoseed(i.."42")).key
                            end
                        end

                        card:set_edition(editi, true)
                        card:juice_up(0.3, 0.5)
                        delay(0.5)
                        return {
                            message = tostring(editi)
                        }
                    end)
                }))
                delay(0.25)
            end
        end
    end
}

--- abyssal seal
SMODS.Seal {
    name = "Abyssal Seal",
    key = "abyssal_seal",
    loc_txt = {
        label = 'Abyssal Seal',
        name = 'Abyssal Seal',
        text = {
            'This card gains {X:mult,C:white}+X#1#{} {C:mult}Mult{} after scoring.',
            "Destroy this card after discarding it {C:attention}#3#{} times.",
            "{C:inactive}(Currently {C:red}#2#/#3#{C:inactive}.)"
        }
    },
    badge_colour = HEX("210109"),
    atlas = 'OnionSeals',
    pos = {x=3, y=0},
    config = {mult_gain=0.1,times_discarded=0,times_total=3},
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.seal.mult_gain,
                card.ability.seal.times_discarded,
                card.ability.seal.times_total
            }
        }
    end,
    calculate = function(self, card, context)

        if context.main_scoring and context.cardarea == G.play then
            card.ability.perma_x_mult = card.ability.perma_x_mult + card.ability.seal.mult_gain
            card:juice_up(0.15, 0.25)
            return {
                message = "Upgraded!",
            }
        end

         if context.discard then
            if context.other_card == card then
                card.ability.seal.times_discarded = card.ability.seal.times_discarded + 1
                context.other_card.ability.seal.times_discarded = card.ability.seal.times_discarded
                if card.ability.seal.times_discarded >= card.ability.seal.times_total then
                    --SMODS.destroy_cards({card})
                    --card:start_dissolve()
                    
                    G.E_MANAGER:add_event(Event({trigger = 'after',delay = 1.5,func = function()
                        --card:start_dissolve()
                        --table.remove(G.playing_cards,indexOf(G.playing_cards,card))
                        --card = nil
                    return true end }))

                    return {
                        remove = true,
                        message = tostring(card.ability.seal.times_discarded).."/"..tostring(card.ability.seal.times_total),
                        colour = G.C.RED
                    }
                else
                    return {
                        remove = false,
                        message = tostring(card.ability.seal.times_discarded).."/"..tostring(card.ability.seal.times_total),
                        colour = G.C.RED
                    }
                end
            end
        end

    end
}

-- cycle seal
SMODS.Seal {
    name = "CycleSeal",
    key = "cycle_seal",
    badge_colour = HEX("00d900"),
    loc_txt = {
        label = 'Cycle Seal',
        name = 'Cycle Seal',
        text = {
            "when this card is {C:red}discarded",
            "increase this card's {C:attention}rank{}",
            "by {C:attention}1{} for every card in",
            "the {C:red}discarded{} hand."
        }
    },
    config = {value=1},
    loc_vars = function(self, info_queue)
        return { vars = {self.config.value} }
    end,
    atlas = 'OnionSeals',
    pos = {x=4, y=0},
    calculate = function(self, card, context)
        if context.pre_discard and context.cardarea == G.hand then
            self.config.value = #G.hand.highlighted
        end
        if context.discard then
            if context.other_card == card then
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay=0.0,
                    func = (function()
                        local rank_table = get_rank_table()
                        local i = tonumber(tonumber(indexOf(rank_table,card.base.value)) + self.config.value)
                        if card.base.value == "onio_Effigy" then
                            i = 1
                        end
                        while i >= 14 do
                            i = i - 13
                        end
                        local rank = rank_table[i] 
                        assert(SMODS.change_base(card, nil, rank))
                        card:juice_up(0.15, 0.25)
                        --self.config.value = self.config.value + 1
                        
                        return true
                    end)
                }))

                return {
                    message = "Rank Up!"
                }
            end

        end
    end
}

-- ouroboros seal
SMODS.Seal {
    name = "OuroborosSeal",
    key = "ouroboros_seal",
    badge_colour = HEX("c38773"),
    always_scores = true,
    debuff = false,
	config = {ouro_trigs = 0,current_prog=0,prog_cap=3},
    loc_txt = {
        label = 'Ouroboros Seal',
        name = 'Ouroboros Seal',
        text = {
            'When {C:red}destroyed{} create a perfect copy.',
            'Retrigger this card {C:attention}#1#{} additional times.',
            "{C:attention}+1{} retrigggers every {C:attention}3{} destructions.",
            "{C:inactive}(Currently {C:attention}#2#/#3#{C:inactive}.)"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.seal.ouro_trigs,card.ability.seal.current_prog,card.ability.seal.prog_cap} }
    end,
    atlas = 'OnionSeals',
    pos = {x=6, y=0},
    in_pool = function(self, args)
        return false
    end,
    calculate = function(self, card, context)
        --card.debuff = false
        --SMODS.debuff_card(card, 'prevent_debuff', "bandage_seal")

        if context.repetition then
            return {
                repetitions = card.ability.seal.ouro_trigs,
                card = card,
            }
        end


        if context.remove_playing_cards then
            for _, v in pairs(context.removed) do
                if v == card then
                    local ret = {remove = false}
                    G.E_MANAGER:add_event(Event({
                        func=function()
                        local copied = copy_card(v)
                        
                        -- heres where the deck shenanigans happen

                        copied:add_to_deck()
                        copied.ability.seal.current_prog = card.ability.seal.current_prog + 1
                        if copied.ability.seal.current_prog >= copied.ability.seal.prog_cap then
                            copied.ability.seal.current_prog = 0
                            copied.ability.seal.ouro_trigs = copied.ability.seal.ouro_trigs + 1
                        end
                        G.deck.config.card_limit = G.deck.config.card_limit + 1
                        table.insert(G.playing_cards, copied)
                        G.hand:emplace(copied)
                        return true
                        end
                    }))

                    if card.ability.seal.current_prog == card.ability.seal.prog_cap - 1 then
                        ret = {
                            card = card,
                            message = "+1 Retriggers!",
                            remove = false
                        }
                    else
                        ret = {
                            card = card,
                            message = tostring(card.ability.seal.current_prog + 1).."/"..tostring(card.ability.seal.prog_cap),
                            remove = false
                        }
                    end


                    return ret
                end
            end
        end

    end
}


