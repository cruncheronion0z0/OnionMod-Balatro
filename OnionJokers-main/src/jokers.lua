--------- JOKERS:

-- Jumping Jacks
SMODS.Joker {
	key = 'jumping_jacks',
	loc_txt = {
		name = 'Jumping Jacks',
		text = {
			"Each scored {C:attention}Jack{} gives {C:mult}+#1#{} Mult and {C:chips}+#3#{} Chips.",
			"Increases Chip gain by {C:chips}+#2#{} Chip when a {C:attention}Jack{} is scored."
		}
	},
	config = { extra = { mult = 5, chip_gain = 1, chips = 0,} },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.chip_gain, card.ability.extra.chips } }
	end,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 11 then
                if not context.blueprint then
				    card.ability.extra.chips = card.ability.extra.chips + 1
                    return {
                        message_card = card,
                        message = 'Upgraded!',
                        colour = G.C.CHIPS,
                        chips = card.ability.extra.chips - 1,
                        mult = card.ability.extra.mult
                    }
                else
                    return {
                        message_card = card,
                        colour = G.C.CHIPS,
                        chips = card.ability.extra.chips,
                        mult = card.ability.extra.mult
                    }
                end
			end
        end
	end
}

-- Straightjacket
SMODS.Joker {
	key = 'straightjacket',
	loc_txt = {
		name = 'Straightjacket',
		text = {
			"Gains {C:mult}+5 Mult{} if the scoring hand contains",
            "both a {C:attention}Straight{} and a {C:attention}Jack{}.",
            "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult)"
		}
	},
	config = { extra = { mult = 0} },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	calculate = function(self, card, context)

        -- give mult
        if context.joker_main then
			return {
				mult = card.ability.extra.mult,
				--message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
			}
		end

        -- upgrade on jack & straight
        if context.before then
            if next(context.poker_hands['Straight']) and not context.blueprint then
                local jack = nil;
                for _, v in pairs(context.scoring_hand) do
                    if v:get_id() == 11 and (jack == nil or jack.debuff) then jack = v end
                end
                if jack then
                    --jack:juice_up();
                    card.ability.extra.mult = card.ability.extra.mult + 5
                    return {
                        message = 'Upgraded!',
                        colour = G.C.Mult,
                        card = card
                    }
                end
            end
		end
	end
}

-- Crown Jewels
SMODS.Joker {
	key = 'crown_jewels',
	loc_txt = {
		name = 'Crown Jewels',
		text = {
			"Each scored {C:attention}King{} or {C:attention}Queen{}",
            "of {V:1}Diamonds{} gives {C:money}$#1#{}"
		}
	},
	config = { extra = { money_gain = 2} },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 2, y = 0 },
	cost = 4,
	loc_vars = function(self, info_queue, card)
		return {
            vars = { card.ability.extra.money_gain,
            colours = { G.C.SUITS["Diamonds"] } -- sets the colour of the text affected by `{V:1}`
            }
        }
	end,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 12 or context.other_card:get_id() == 13 then
                if context.other_card:is_suit("Diamonds") then
                    return {
                        message_card = card,
                        dollars = card.ability.extra.money_gain,
                    }
                end
			end
        end
	end
}

-- Company Stock
SMODS.Joker {
	key = 'company_stock',
	loc_txt = {
		name = 'Company Stock',
		text = {
			"Gains between {C:money}-$2{} and {C:money}+$3{}",
            "{C:attention}sell value{} at end",
            "of a {C:attention}non-boss blind{}.",
            "Gain {C:money}sell value{} as {C:money}${}",
            "when {C:attention}boss blind{} is defeated.",
		}
	},
	config = { extra = { money_at_boss = 0} },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 3, y = 0 },
	cost = 8,
    -- inital sell is always 1
    sell_cost = 1,
	loc_vars = function(self, info_queue, card)
		return {vars = { card.ability.extra.money_at_boss,}
        }
	end,
	calculate = function(self, card, context)
		if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then

            if G.GAME.blind.boss then
                card.ability.extra.money_at_boss = card.sell_cost
            else
                card.ability.extra.money_at_boss = 0
                local change = pseudorandom_element({-2,-1,1,2,3},pseudoseed("companystock"))
                card.sell_cost = math.max(0,card.sell_cost)
                while card.sell_cost + change <= 1 do
                    local change = pseudorandom_element({-1,-1,-1,-1,1,1,1,2,3},pseudoseed("companystock"))
                end
                card.sell_cost = math.max(0,card.sell_cost + change)
                return {
                    message = "+"..tostring(change).." Price!",
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
	end,
    calc_dollar_bonus = function(self, card)
		local bonus = card.ability.extra.money_at_boss
		if bonus > 0 then return bonus end
	end
}

--- Bingo Sheet
SMODS.Joker {
	key = 'bingo_sheet',
	loc_txt = {
		name = 'Bingo Sheet',
		text = {
			"{C:money}+$#1#{} at end of round if each of the displayed",
            "ranks was scored this round atleast once.",
            "Currently: {V:1}#2#{}, {V:2}#3#{}, {V:3}#4#{}, {V:4}#5#{} & {V:5}#6#{}",
			"{C:inactive}(Ranks are randomized at start of round.)"
		}
	},
	config = { extra = { reward_money = 20,
                        rank1 = 2,
                        rank2 = 3,
                        rank3 = 6,
                        rank4 = 9,
                        rank5 = 12,
                        completion_list={false,false,false,false,false},
                        colours = { G.C.RED, G.C.RED, G.C.RED, G.C.RED, G.C.RED }
                    } },
    unlocked = true,  
    discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
    eternal_compat = true, 
    rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 4, y = 0 },
	cost = 8,
	loc_vars = function(self, info_queue, card)
		return { vars = {
            card.ability.extra.reward_money,
            get_rank_table()[card.ability.extra.rank1-1],
            get_rank_table()[card.ability.extra.rank2-1],
            get_rank_table()[card.ability.extra.rank3-1],
            get_rank_table()[card.ability.extra.rank4-1],
            get_rank_table()[card.ability.extra.rank5-1],
            card.ability.extra.completion_list,
            colours = card.ability.extra.colours
            }
        }
	end,
	calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then

            --get valid ranks in deck
            --TODO: how should this handle < 5 unique ranks in deck? 
            --if < 5 possible, will need to consider in no duplicate checker
            local ranks = {}
            for _, v in pairs(G.playing_cards) do
                if indexOf(ranks,v:get_id()) == nil then
                    ranks[#ranks + 1] = v:get_id()
                end
            end

            --the inital seed is the 2 arbitrary ones out of the last ones combined
            local seed_mod = tostring(card.ability.extra.rank5) .. tostring(card.ability.extra.rank3)
            local used_ranks = {}
            local rank_count = 0

            print(inspect(ranks))
            while rank_count < 5 do

                local rank = pseudorandom_element(ranks,pseudoseed(seed_mod))
                if indexOf(ranks,rank) ~= nil and #ranks >= 5 then
                    ranks[indexOf(ranks,rank)] = nil
                end
                used_ranks[rank_count] = rank
                rank_count = rank_count + 1

            end
            print("XX")
            print(inspect(used_ranks))

            table.sort(used_ranks,sort_by_rank)

            card.ability.extra.rank1 = used_ranks[0]
            card.ability.extra.rank2 = used_ranks[1]
            card.ability.extra.rank3 = used_ranks[2]
            card.ability.extra.rank4 = used_ranks[3]
            card.ability.extra.rank5 = used_ranks[4]
            
            card.ability.extra.colours = { G.C.RED, G.C.RED, G.C.RED, G.C.RED, G.C.RED }
            card.ability.extra.completion_list = {false,false,false,false}
            card.ability.extra.completion_list[0] = false

            print(inspect(card.ability.extra.completion_list))

            return {
                card = card,
                message = "Ranks Changed!"
            }
        end

		if context.individual and context.cardarea == G.play and not context.blueprint then
            
            local any_rank_found = false
            --(card.ability.extra.completion_list[0] == false) and 
            if (card.ability.extra.completion_list[0] == false) and (context.other_card:get_id() == card.ability.extra.rank1) then
                card.ability.extra.completion_list[0] = true
                any_rank_found = true
            end
            if (card.ability.extra.completion_list[1] == false) and (context.other_card:get_id() == card.ability.extra.rank2) then
                card.ability.extra.completion_list[1] = true
                any_rank_found = true
            end
            if (card.ability.extra.completion_list[2] == false) and (context.other_card:get_id() == card.ability.extra.rank3) then
                card.ability.extra.completion_list[2] = true
                any_rank_found = true
            end
            if (card.ability.extra.completion_list[3] == false) and (context.other_card:get_id() == card.ability.extra.rank4) then
                card.ability.extra.completion_list[3] = true
                any_rank_found = true
            end
            if (card.ability.extra.completion_list[4] == false) and (context.other_card:get_id() == card.ability.extra.rank5) then
                card.ability.extra.completion_list[4] = true
                any_rank_found = true
            end

            --local new_color_set = card.ability.extra.colours
            --{ G.C.RED, G.C.RED, G.C.RED, G.C.RED, G.C.RED }
            --card.ability.extra.completion_list[0] ? G.C.GREEN : G.C.RED,
            card.ability.extra.colours = {
                ternary(card.ability.extra.completion_list[0],G.C.GREEN,G.C.RED),
                ternary(card.ability.extra.completion_list[1],G.C.GREEN,G.C.RED),
                ternary(card.ability.extra.completion_list[2],G.C.GREEN,G.C.RED),
                ternary(card.ability.extra.completion_list[3],G.C.GREEN,G.C.RED),
                ternary(card.ability.extra.completion_list[4],G.C.GREEN,G.C.RED),            
            }
            
            local count = 0
            count = count + ternary(card.ability.extra.completion_list[0],1,0)
            count = count + ternary(card.ability.extra.completion_list[1],1,0)
            count = count + ternary(card.ability.extra.completion_list[2],1,0)
            count = count + ternary(card.ability.extra.completion_list[3],1,0)
            count = count + ternary(card.ability.extra.completion_list[4],1,0)
            if any_rank_found then
                return {
                    message_card = card,
                    message = tostring(get_rank_table()[context.other_card:get_id()-1])..' Found!', 
                    extra = {
                        message_card = card,
                        message = tostring(count)..'/5',
                        colour = ternary(count >= 5,G.C.GREEN,G.C.FILTER)
                    }
                }
            end


        end
	end,

    calc_dollar_bonus = function(self, card)
		local bonus = card.ability.extra.reward_money
		if card.ability.extra.completion_list[0] == true then 
            if card.ability.extra.completion_list[1] == true then 
                if card.ability.extra.completion_list[2] == true then 
                    if card.ability.extra.completion_list[3] == true then 
                        if card.ability.extra.completion_list[4] == true then 
                            return bonus 
                        end
                    end
                end
            end
        end
	end

}

-- chisel
SMODS.Joker {
	key = 'chisel',
	loc_txt = {
		name = 'Chisel',
		text = {
			"scoring {C:attention}stone cards{}",
            "permanently gain {C:chips}+#1# Chips{}",
            "Removes {C:attention}stone enhancement{}"
		}
	},
    enhancement_gate = "m_stone",
	config = {extra= {gain = 20}},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_stone"]
        return {vars = {card.ability.extra.gain}}
    end,
	calculate = function(self, card, context)

        if context.before and context.main_eval and not context.blueprint then
            for _, scored_card in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(scored_card, "m_stone") and not scored_card.debuff and not scored_card.vampired then

                    scored_card.ability.perma_bonus = scored_card.ability.perma_bonus + card.ability.extra.gain
                    scored_card.vampired = true
                    
                    scored_card:set_ability('c_base', nil, true)
                    card_eval_status_text(scored_card, 'jokers', 1, nil, nil, {message = "Chiseled!", colour = G.C.CHIPS})
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            scored_card:juice_up()
                            card:juice_up()
                            scored_card.vampired = nil
                            return true
                        end
                    }))
                end
            end

        end


	end
}

-- stoner
SMODS.Joker {
	key = 'stoner',
	loc_txt = {
		name = 'Stoner',
		text = {
			"{C:green}#1# in #2#{} chance to create a",
            "{C:attention}stone card{} with a random {C:attention}seal {C:red}or {C:attention}edition{} and",
            "draw it to hand if the scoring hand is {C:attention}high card{}.",
            "{C:attention}Gaurenteed{} to trigger if the {C:attention}first hand",
            "of the round is a {C:attention}high card{}"
		}
	},
	config = {odds = 4},
    unlocked = true,  
    discovered = true,
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_stone"]
        return { vars = {''..(G.GAME and G.GAME.probabilities.normal or 1),card.ability.odds} }
    end,
	calculate = function(self, card, context)

        --TODO: fix highcard detection (check if 1 size limiter changed anything)

        if context.before and context.scoring_name == "High Card" then
            if G.GAME.current_round.hands_played < 1 or pseudorandom('stoner') <= (G.GAME.probabilities.normal / card.ability.odds) then
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 1.0,func = function()
                    local new_card = create_playing_card({
                        front = G.P_CARDS.S_A, 
                        center = G.P_CENTERS.c_base}, G.hand, nil, nil, {G.C.SECONDARY_SET.Enhanced}
                    )
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    new_card:set_ability(G.P_CENTERS.m_stone)
                    SMODS.change_base(new_card, pseudorandom_element(get_suit_table(),pseudoseed("stoners")), pseudorandom_element(get_rank_table(),pseudoseed("stonerr")))
                    rand_seals = G.P_CENTER_POOLS.Seal
                    rand_editi = G.P_CENTER_POOLS.Edition
                    --remove base edition from pool
                    rand_editi[1] = nil
                    if pseudorandom_element({true,true,false,false,false},pseudoseed("coinflip")) then
                        local edi = pseudorandom_element(rand_editi,pseudoseed("stoner_add")).key
                        if not negative_less_likely() then
                            edi = pseudorandom_element(rand_editi,pseudoseed("stoner_add2")).key
                        end 
                        new_card:set_edition(edi, true)
                    else
                        new_card:set_seal(pseudorandom_element(rand_seals,pseudoseed("stoner_add")).key, nil, true)
                    end
                return true end }))


                return {
                    message = "Stoned!",
                    colour = G.C.Green,
                }
            end
        end
	end
}

-- sidewalk chalk
SMODS.Joker {
	key = 'sidewalk_chalk',
	loc_txt = {
		name = 'Sidewalk Chalk',
		text = {
			"Scoring {C:attention}stone cards{} have a",
            "{C:green}#1# in #2#{} chance to {C:attetnion}permanently{} gain",
            "either {C:chips}+25 Chips{}, {C:mult}+5 Mult{}, or {X:mult,C:white}+0.25X{} {C:mult}Mult{}."
		}
	},
    enhancement_gate = "m_stone",
	config = {odds=2},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 3, y = 1 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_stone"]
        return {vars = {''..(G.GAME and G.GAME.probabilities.normal or 1),card.ability.odds}}
    end,
	calculate = function(self, card, context)

        if context.individual and context.cardarea == G.play then
            if SMODS.has_enhancement(context.other_card, "m_stone") and not context.other_card.debuff then
                if pseudorandom('sidewalk') < (G.GAME.probabilities.normal / card.ability.odds) then
                    upgrade = pseudorandom_element({"chips","mult","mult","mult mult","mult mult"},pseudoseed("sidewalk_upgrade"))
                    if upgrade == "chips" then
                        context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + 25
                    else 
                        if upgrade == "mult" then
                            context.other_card.ability.perma_mult = context.other_card.ability.perma_mult + 5
                        else
                            context.other_card.ability.perma_x_mult = context.other_card.ability.perma_x_mult + 0.25
                        end
                    end
                    card:juice_up(0.3, 0.5)
                    context.other_card:juice_up(0.3, 0.5)
                    return {
                        message_card = context.other_card,
                        message = "Upgraded!"
                    }
                end
            end
        end
	end

}

-- Sisyphus
SMODS.Joker {
	key = 'sisyphus',
	loc_txt = {
		name = 'Sisyphus',
		text = {
            "Gains {X:mult,C:white}X#2#{} {C:mult}Mult{} when {C:attention}stone cards{} are scored.",
            "Loses {X:mult,C:white}X#3#{} {C:mult}Mult{} per {C:attention}discarded card{}.",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{} {C:mult}Mult{}{C:inactive}.)"
		}
	},
    enhancement_gate = "m_stone",
	config = {current_mult_mult = 1.0,mult_mult_gain=0.2,mult_mult_loss=0.05},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 8,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_stone"]
        return {vars = {
            card.ability.current_mult_mult,
            card.ability.mult_mult_gain,
            card.ability.mult_mult_loss
        }}
    end,
	calculate = function(self, card, context)

        if context.joker_main then
            return {xmult = card.ability.current_mult_mult}
        end
        
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if SMODS.has_enhancement(context.other_card, "m_stone") and not context.other_card.debuff then
                card.ability.current_mult_mult = card.ability.current_mult_mult + card.ability.mult_mult_gain
                card:juice_up(0.3, 0.5)
                context.other_card:juice_up(0.3, 0.5)
                return {
                    message = "+X"..tostring(card.ability.mult_mult_gain),
                    colour = G.C.RED,
                    message_card = card
                }
            end
        end

        if context.discard and not context.blueprint then
            card.ability.current_mult_mult = math.max(1.0,card.ability.current_mult_mult - card.ability.mult_mult_loss)
            return {
                message = "-X"..tostring(card.ability.mult_mult_loss),
                colour = G.C.RED,
                message_card = card
            }
        end


	end
}

-- whiteboard
SMODS.Joker {
	key = 'whiteboard',
	loc_txt = {
		name = 'Whiteboard',
		text = {
            "{X:mult,C:white}X#1#{} {C:mult}Mult{} if none of the",
            "scoring cards have any {C:attention}enhancements{}."
		}
	},
	config = {mult_mult = 3.0},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 2, y = 1 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.mult_mult,
        }}
    end,
	calculate = function(self, card, context)
        if context.joker_main then
            local allow = true
            for _,a in pairs(context.scoring_hand) do
                for b=1, #G.P_CENTER_POOLS.Enhanced do
                    if SMODS.has_enhancement(a,tostring(G.P_CENTER_POOLS.Enhanced[b].key)) then allow = false end
                end
            end
            if allow then
                return {xmult = card.ability.mult_mult}
            end
        end
	end
}

-- Woodchipper
SMODS.Joker {
	key = 'woodchipper',
	loc_txt = {
		name = 'Woodchipper',
		text = {
			"gains {X:chips,C:white}X#2#{} for every {C:attention}consumable{} or {C:attention}joker{} sold.",
            "{C:inactive}(Currently {X:chips,C:white}X#1#{}{C:chips} chips{C:inactive}.)"
		}
	},
	config = {chip_mult=1.0,chip_gain=0.15},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true,
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.chip_mult, card.ability.chip_gain} }
	end,
	calculate = function(self, card, context)

        if context.joker_main then
            return {xchips = card.ability.chip_mult}
        end
        if context.selling_card and not context.blueprint then
            card.ability.chip_mult = card.ability.chip_mult + card.ability.chip_gain
            return {
                message = "Upgraded!",
                colour = G.C.CHIPS,
                card = card
            }
        end

	end
}

-- unfinished joker
SMODS.Joker {
	key = 'unfish_joker',
	loc_txt = {
		name = 'Unfinished Joker',
		text = {
            "{X:mult,C:white}X1{} {C:mult}Mult",
            "{X:mult,C:white}+X#2#{} for every {C:attention}unscored{}",
            "card in the played hand.",
		}
	},
	config = {mult_mult = 1.0,mult_gain=0.5},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 1, y = 1 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.mult_mult,
            card.ability.mult_gain,
        }}
    end,
	calculate = function(self, card, context)
        if context.joker_main then
            card.ability.mult_mult = 1 + ((#G.play.cards - #context.scoring_hand) * card.ability.mult_gain)
            return {xmult = card.ability.mult_mult}
        end
	end
}

-- Strength in numbers
SMODS.Joker {
	key = 'str_in_nums',
	loc_txt = {
		name = 'Strength In Numbers',
		text = {
            "If all of the cards in {C:attention}hand",
            "{C:attention}and scored{} are {C:attention}numbered{} cards",
            "all scored cards gain {C:mult}+1 Mult{}",
            "for every {C:attention}2{} cards scored.",
            "{C:inactive}(2-10, No A,K,Q or J)"
		}
	},
	config = {},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 1 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        return {vars = {}}
    end,
	calculate = function(self, card, context)

        if context.individual and context.cardarea == G.play then
            local has_face = false
            for _,c in pairs(context.scoring_hand) do
                if c:is_face() or c:get_id() == 14 then has_face = true end
            end
            for _,c in pairs(G.hand.cards) do
                if c:is_face() or c:get_id() == 14 then has_face = true end
            end

            if has_face == false then
                local num = math.floor(#context.scoring_hand / 2.0)
                    if num > 0 then
                    context.other_card.ability.perma_mult = context.other_card.ability.perma_mult + num
                    card:juice_up(0.3, 0.5)
                    context.other_card:juice_up(0.3, 0.5)
                    return {
                        message_card = context.other_card,
                        message = "Upgraded!",
                        colour = G.C.MULT
                    }
                end
            end
        end
	end
}

-- Black Jack
SMODS.Joker {
	key = 'black_jack',
	loc_txt = {
		name = 'Black Jack',
		text = {
			"{C:mult}+#1# Mult{} if the {C:attention}rank{} of all",
            "scoring cards adds to {C:attention}exactly 21{}",
            "{C:mult}+#2# Mult{} if they add to {C:attention}below 21{}.",
            "{C:inactive}({C:attention}Aces{}{C:inactive} count as 1.)"
		}
	},
	config = {
        perfect_mult = 40,
        below_mult = 10,
        colours = { G.C.SUITS["Spades"],G.C.SUITS["Clubs"] },
        total_rank = 0
    },
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 4,
	loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.perfect_mult,
            card.ability.below_mult,
            card.ability.jack_mult,
            colours = card.ability.colours,
            card.ability.total_rank
            }
        }
    end,
	calculate = function(self, card, context)

        if context.before and not context.blueprint then
            card.ability.total_rank = 0
            for _,i in pairs(context.scoring_hand) do
                if i.debuff == false then
                    local rank_value = i:get_id()
                    if rank_value >= 11 and rank_value < 14 then
                        rank_value = 10
                    end
                    if rank_value == 14 then
                        rank_value = 1
                    end
                    if rank_value >= 0 then 
                        card.ability.total_rank = card.ability.total_rank + rank_value
                    end
                end
            end
        end

        if context.joker_main then
            print(card.ability.total_rank)
            local the_mult = 0
            if card.ability.total_rank == 21 then
                the_mult = card.ability.perfect_mult
            end
            if card.ability.total_rank < 21 then
                the_mult = card.ability.below_mult
            end
            return {mult = the_mult}
        end


	end
}

-- HATE
SMODS.Joker {
	key = 'hate_brick',
	loc_txt = {
		name = "HATE",
		text = {
            "{C:red}Destroys #2#{} card#3# in hand",
            "when blind is deafeated",
            "{C:red}+1 destroyed cards{} when",
            "boss blind is defeated."
		}
	},
	config = { extra = {targets={},max_targets=1}},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true,
    eternal_compat = true, 
    rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = {
            card.ability.extra.targets,
            card.ability.extra.max_targets,
            ternary(card.ability.extra.max_targets > 1,"s","")
        }}
	end,
	calculate = function(self, card, context)

        if context.end_of_round and context.cardarea == G.jokers then
            local gains = {}

            for i=1,math.min(card.ability.extra.max_targets,5,#G.hand.cards) do
                local temp_target = pseudorandom_element(G.hand.cards,pseudoseed("hate_joker"))
                local i = 0
                while indexOf(card.ability.extra.targets,temp_target) ~= nil do
                    i = i + 1
                    temp_target = pseudorandom_element(G.hand.cards,pseudoseed("hate_joker"..tostring(i)))
                end
                card.ability.extra.targets[#card.ability.extra.targets + 1] = temp_target
                delay(0.25)
                temp_target:start_dissolve()
                gains[#gains+1] = {
                    message_card = temp_target,
                    message = "HATE",
                    colour = G.C.RED
                }

            end

            if G.GAME.blind.boss and not context.blueprint then
                if card.ability.extra.max_targets < 5 then
                    card.ability.extra.max_targets = card.ability.extra.max_targets + 1
                    gains[#gains+1] = {
                        card = context.destroying_card,
                        message = "Upgraded!",
                        colour = G.C.RED,
                        remove = true
                    }
                else
                    gains[#gains+1] = {
                        card = context.destroying_card,
                        message = "MAX HATRED",
                        colour = G.C.RED,
                        remove = true
                    }
                end
            end

            --message nesting
            local return_value =  {}
            local g = reverse_table_num(gains)
            for _,i in pairs(g) do
                if indexOf(g,i) == 1 then
                    return_value = i
                else
                    local copy = return_value
                    i.extra = copy
                    return_value = i
                end
            end

            if return_value ~= {} then
                return return_value
            end
        end
	end
}

-- Nuclear Shadow
SMODS.Joker {
	key = 'nuclear_shadow',
	loc_txt = {
		name = 'Nuclear Shadow',
		text = {
            "Create a {C:dark_edition}Negative Tag{} when scoring",
            "more than {X:attention,C:white}X#1#{} the {C:attention}blind size{}.",
            "{X:attention,C:white}X#2#{} threshold if triggered in",
            "the first played hand of a blind."
		}
	},
	config = {requirement = 2.0,punish = 2.0},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTER_POOLS.Tag[3]
        return {vars = {
            card.ability.requirement, card.ability.punish
        }}
    end,
	calculate = function(self, card, context)
        if context.end_of_round and context.cardarea == G.jokers then
            if G.GAME.chips >= (G.GAME.blind.chips * card.ability.requirement) then

                if G.GAME.current_round.hands_played == 1 then 
                    G.E_MANAGER:add_event(Event({trigger = 'after',delay = 1.0,func = function()
                        add_tag(Tag('tag_negative'))
                        play_sound('generic1', 0.6 + math.random() * 0.1, 0.8)
                        play_sound('holo1', 1.1 + math.random() * 0.1, 0.4)
                        return true
                    end}))
                    card.ability.requirement = card.ability.requirement * card.ability.punish
                    return {
                        message = "Nuked & Scaled!",
                        colour =  G.C.Red
                    }
                else
                    G.E_MANAGER:add_event(Event({trigger = 'after',delay = 1.0,func = function()
                        add_tag(Tag('tag_negative'))
                        play_sound('generic1', 0.6 + math.random() * 0.1, 0.8)
                        play_sound('holo1', 1.1 + math.random() * 0.1, 0.4)
                        return true
                    end}))

                    return {
                        message = "Nuked!",
                        colour =  G.C.BLACK
                    }
                end
                
            --else
            --    if G.GAME.current_round.hands_played == 1 then 
            --        card.ability.requirement = card.ability.requirement * card.ability.punish
            --        return {
            --            message = "Scaled!",
            --            colour =  G.C.Red
            --        }
            --    end
            end
        end
	end
}

-- All in
SMODS.Joker {
	key = 'all_in',
	loc_txt = {
		name = 'All In',
		text = {
            "When blind is selected {C:red}lose{} all but {C:attention}1{} {C:blue}hand{}",
            "and gain {C:green}+#1# hand size{} for every {C:blue}hand{} lost"
		}
	},
	config = {size_per=3},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.size_per,
        }}
    end,
	calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then 
            local i = (G.GAME.round_resets.hands - 1)
            G.hand.config.card_limit = G.GAME.starting_params.hand_size + (i * card.ability.size_per)
            G.GAME.current_round.hands_left = 1
            return {
                card = card,
                message = "+"..tostring(i * card.ability.size_per).." Cards",
                colour = G.C.GREEN
            }
        end
        --if context.end_of_round and not context.blueprint then
        --    G.hand:change_size(-1 * (G.GAME.round_resets.hands + 1) * card.ability.size_per)
        --end
	end
}

-- Jackpot
SMODS.Joker {
	key = 'jackpot',
	loc_txt = {
		name = 'Jackpot',
		text = {
            "{C:green}#5# in #2#{} chance to {C:red}self destruct{}",
            "and gain {C:money}$#3#{} at end of round.",
            "increase the probability",
            "by {C:attention}1{} when a {C:attention}jack{} is scored."
		}
	},
	config = {chance=1,odds = 100,reward=100,has_won=false,display_chance=1},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
    eternal_compat = false,
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.chance,card.ability.odds,card.ability.reward,card.ability.has_won,card.ability.display_chance}}
    end,
	calculate = function(self, card, context)

        card.ability.display_chance = (card.ability.chance * G.GAME.probabilities.normal)

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:get_id() == 11 then
                card.ability.chance = card.ability.chance + 1
                return {
                    message_card = card,
                    message = "Upgraded!",
                    colour = G.C.GREEN
                }
            end
        end

        if context.destroying_card and context.destroying_card.area == G.jokers and not context.blueprint then
            if card == context.destroying_card then
                return {
                    message_card = card,
                    message = "WINNER!",
                    colour = G.C.GREEN,
                    remove = true
                }
            end
        end

	end,
    calc_dollar_bonus = function(self, card)
        if pseudorandom('jackpot') < ((card.ability.chance * G.GAME.probabilities.normal) / card.ability.odds) then
            card.ability.has_won = true
            card:start_dissolve()
            G.jokers:remove_card(card)
            return card.ability.reward
        end
    end
}

-- Hopscotch
SMODS.Joker {
	key = 'hopscotch',
	loc_txt = {
		name = 'Hopscotch',
		text = {
			"{C:money}+$#1#{} when {C:attention}skipping{}",
            "a blind."
		}
	},
	config = {reward=8},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 4, y = 1 },
	cost = 4,
	loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.reward}}
    end,
	calculate = function(self, card, context)

        if context.skip_blind then
            return {
                dollars = card.ability.reward
            }
        end
	end
}

-- bonfire
SMODS.Joker {
	key = 'bonfire',
	loc_txt = {
		name = 'Bonfire',
		text = {
			"Loses {C:mult}1 Mult{} per card purchased.",
            "Gain {C:mult}Mult{} equal to {C:attention}double{} the",
            "{C:attention}sell value{} of sold {C:attention}jokers{} or {C:attention}consumeables{}",
            "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult)"
		}
	},
	config = { mult = 0 },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true,
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.mult } }
	end,
	calculate = function(self, card, context)

        if context.joker_main then
			return {
				mult = card.ability.mult,
			}
		end

        if context.buying_card  and not context.blueprint then
            if card.ability.mult > 0 then
                card.ability.mult = card.ability.mult - 1
                return {
                    message = '-1',
                    colour = G.C.MULT,
                    card = card
                }
            end
		end

        if context.selling_card and context.cardarea == G.jokers and not context.blueprint then
            card.ability.mult = card.ability.mult + (context.card.sell_cost * 2)
            return {
                message = "Upgraded!",
                colour = G.C.MULT,
                card = card
            }
        end
	end
}

-- will
SMODS.Joker {
	key = 'will',
	loc_txt = {
		name = 'Will',
		text = {
			"Add the base {C:chips}chip{} value of {C:attention}destroyed{}",
            "cards to this jokers {C:mult}Mult{}.",
            "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult)"
		}
	},
	config = { mult = 0},
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true,
    perishable_compat = true,
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.mult } }
	end,
	calculate = function(self, card, context)

        if context.joker_main then
			return {
				mult = card.ability.mult,
			}
		end

        if context.remove_playing_cards and not context.blueprint then
            local add = 0
            for i=1,#context.removed do
                local value = context.removed[i].base.id
                if value > 10 and value ~= 14 then
                    value = 10
                end
                if value == 14 then
                    value = 11
                end
                add = add + value
            end
            card.ability.mult = card.ability.mult + add
            return {
                message = "Upgraded!",
                colour = G.C.MULT,
                message_card = card
            }
        end
	end
}

-- Detective
SMODS.Joker {
	key = 'detective',
	loc_txt = {
		name = 'Detective',
		text = {
            "Scored cards that this joker has",
            "seen {C:attention}previously{} this {C:attention}Ante{} give {C:mult}+#2# Mult{}."
		}
	},
	config = {
        scored_cards = {},
        mult_gain = 8
    },
    unlocked = true,  
    discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.scored_cards,
            card.ability.mult_gain
        }}
    end,
	calculate = function(self, card, context)

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if indexOf(card.ability.scored_cards,context.other_card) == nil then
                card.ability.scored_cards[#card.ability.scored_cards + 1] = context.other_card
                return {
                    card = card,
                    message="Discovered!"
                }
            else
                return {   
                    card = card,
                    mult = card.ability.mult_gain,
                }
            end
        end

        if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
            if G.GAME.blind.boss then
                card.ability.scored_cards = {}
                return {
                    message_card = card,
                    message = "Reset!",
                    colour = G.C.RED
                }
            end
        end
	end
}

-- Sweet & Sour Sauce
SMODS.Joker {
	key = 'sweet_sour_sauce',
	loc_txt = {
		name = 'Sweet & Sour Sauce Packet',
		text = {
			"{X:attention,C:white}X#2#{} {C:attention}blind requirement{}",
            "{X:money,C:white}X#1#{} initial blind reward {C:money}${}"
		}
	},
	config = { extra = { money_mult = 3, blind_mult = 1.5} },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true,
	eternal_compat = true, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 2, y = 2 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		return {
            vars = {
                card.ability.extra.money_mult,
                card.ability.extra.blind_mult,
            }
        }
	end,
	calculate = function(self, card, context)
        -- reverse blind saucing is sold mid-round
        if context.selling_self and not context.blueprint then
            if G.GAME.blind.chips > 0 then
                G.GAME.blind.chips = math.ceil(G.GAME.blind.chips / card.ability.extra.blind_mult)
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                SMODS.juice_up_blind()

                if G.GAME.chips > G.GAME.blind.chips then
                    G.STATE = G.STATES.HAND_PLAYED
                    G.STATE_COMPLETE = true
                    end_round()
                end

                return {
                    card = card,
                    message = "Unsauced!"
                }
            end
        end
        if context.setting_blind and not context.blueprint then
            delay(0.5)
            G.GAME.blind.chips = math.floor(G.GAME.blind.chips * card.ability.extra.blind_mult)
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            G.GAME.blind.dollars = G.GAME.blind.dollars * card.ability.extra.money_mult
            SMODS.juice_up_blind()
            return {
                card = card,
                message = "Sauced!",
            }
        end
	end
}

-- Hot Sauce Packet
SMODS.Joker {
	key = 'hot_sauce_packet',
	loc_txt = {
		name = 'Hot Sauce Packet',
		text = {
			"{X:attention,C:white}X#3#{} {C:attention}blind requirement{}",
            "{C:money}+$#4#{} for every {C:attention}#1#%{} scored {C:attention}over{}",
            "the {C:attention}blind requirement{} at end of the round.",
            "{C:inactive}(Max of {C:money}+$#2#{}{C:inactive}.)",
		}
	},
	config = { extra = { percent_threshold = 20, money_max = 20, blind_mult = 1.5,money_per_trigger = 1} },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 3, y = 2 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		return {
            vars = {
                card.ability.extra.percent_threshold,
                card.ability.extra.money_max,
                card.ability.extra.blind_mult,
                card.ability.extra.money_per_trigger
            }
        }
	end,
	calculate = function(self, card, context)
        -- reverse blind spicing is sold mid-round
        if context.selling_self and not context.blueprint then
            if G.GAME.blind.chips > 0 then
                G.GAME.blind.chips = math.ceil(G.GAME.blind.chips / card.ability.extra.blind_mult)
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                SMODS.juice_up_blind()

                if G.GAME.chips > G.GAME.blind.chips then
                    G.STATE = G.STATES.HAND_PLAYED
                    G.STATE_COMPLETE = true
                    end_round()
                end

                return {
                    card = card,
                    message = "Unspiced!"
                }
            end
        end
        if context.setting_blind and not context.blueprint then
            
            delay(0.5)
            G.GAME.blind.chips = math.floor(G.GAME.blind.chips * card.ability.extra.blind_mult)
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            --G.GAME.blind.dollars = G.GAME.blind.dollars * 3
            G.GAME.blind.dollar_text = "H"
            SMODS.juice_up_blind()
            return {
                card = card,
                message = "Spiced!",
                colour = G.C.RED
            }
        end
	end,
    calc_dollar_bonus = function(self, card)
        local percent_over = math.floor(100 * ((G.GAME.chips / G.GAME.blind.chips) - 1))
        local bonus = math.min(card.ability.extra.money_max,card.ability.extra.money_per_trigger * math.floor(percent_over / card.ability.extra.percent_threshold))
        if bonus > 0 then
            return bonus
        end
    end
}

-- Exit Sign
SMODS.Joker {
	key = 'exit_sign',
	loc_txt = {
		name = 'Exit Sign',
		text = {
			"{C:attention}Sell{} this joker to instantly",
            "{C:attention}win{} the current blind",
            "and {C:red} set money to {C:money}$0{}.",
            "{C:inactive}(does {C:red}not{}{C:inactive} work on boss blinds)"
		}
	},
	config = { extra = { } },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = false, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 4, y = 2 },
	cost = 6,
    sell_cost = 0,
	loc_vars = function(self, info_queue, card)
		return {vars = {}}
	end,
	calculate = function(self, card, context)
        sell_cost = 0
        card.sell_cost = 0
        self.sell_cost = 0
        if context.selling_self and not context.blueprint then
            if G.GAME.blind.chips > 0 then
                if G.GAME.blind.boss == false then
                    G.GAME.chips = G.GAME.blind.chips
                    ease_dollars(-G.GAME.dollars, true)
                    G.GAME.dollars = 0
                    G.STATE = G.STATES.HAND_PLAYED
                    G.STATE_COMPLETE = true
                    end_round()
                    return {
                        card = card,
                        message = "Exited!",
                        colour = G.C.GREEN
                    }
                end
            end
        end
	end
}

-- Sticker Sheet
SMODS.Joker {
	key = 'sticker_sheet',
	loc_txt = {
		name = 'Sticker Sheet',
		text = {
			"{C:green}#1# in #2#{} chance to add a" ,
            "random {C:attention}seal{} to a random",
            "card in the {C:attention}scoring{} hand."
		}
	},
	config = {chance=1,odds = 2},
    unlocked = true,  
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
        return {vars = {''..(G.GAME and G.GAME.probabilities.normal or 1),card.ability.odds}}
    end,
	calculate = function(self, card, context)

        if context.before and not context.blueprint then
            if pseudorandom('sticker') < (G.GAME.probabilities.normal / card.ability.odds) then

                local valid_targets = {}
                for a,b in pairs(context.scoring_hand) do
                    if b.seal == nil then
                        valid_targets[#valid_targets+1] = b
                    end
                end
                if #valid_targets > 0 then
                    local chosen_card = pseudorandom_element(valid_targets,pseudoseed("sticker_sheet"))
                    chosen_card:juice_up(0.3, 0.5)
                    card:juice_up(0.3, 0.5)
                    local seall = pseudorandom_element(G.P_CENTER_POOLS.Seal,pseudoseed("sticker_sheet_seal"))
                    chosen_card:set_seal(seall.key,nil,true)
                    return {
                        message_card = chosen_card,
                        message = "Sticked!",
                        colour = G.C.GREEN
                    }
                end
            end
        end

	end
}

-- Patchwork joker
SMODS.Joker {
	key = 'patchwork',
	loc_txt = {
		name = 'Patchwork Joker',
		text = {
            "{C:mult}+#1# Mult{} for every unique",
            "rank held in hand."
		}
	},
	config = { mult = 5},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.mult } }
	end,
	calculate = function(self, card, context)

        if context.individual and context.cardarea == G.hand and not context.end_of_round then

            local index_of_self = indexOf(G.hand.cards,context.other_card)
            if index_of_self ~= nil and context.other_card.debuff == false then

                local lowest_index = 9999999
                for a,b in pairs(G.hand.cards) do
                    if b:get_id() == context.other_card:get_id() and b.debuff == false then
                        lowest_index = math.min(indexOf(G.hand.cards,b),lowest_index)
                    end
                end

                if index_of_self == lowest_index then
                    return {
                        mult = card.ability.mult,
                    }
                end
            end
		end
	end
}

-- last stand
SMODS.Joker {
	key = 'last_stand',
	loc_txt = {
		name = 'Last Stand',
		text = {
            "{X:mult,C:white}X#1#{} {C:mult}Mult{} on the {C:blue}final hand{} of the round",
            "if you have no {C:red}discards{} remaining.",
            "{X:mult,C:white}X Mult{} is equal to {X:attention,C:white}X0.75{}",
            "the current {C:attention}ante{}."
		}
	},
	config = { mult_mult = 0 },
    unlocked = true,
    discovered = true, 
    blueprint_compat = true,
    perishable_compat = true, 
    eternal_compat = true,
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.mult_mult } }
	end,
	calculate = function(self, card, context)
        card.ability.mult_mult = G.GAME.round_resets.ante * 0.75
        if context.joker_main then
            card.ability.mult_mult = G.GAME.round_resets.ante * 0.75
            if  G.GAME.current_round.hands_left == 0 and G.GAME.current_round.discards_left == 0 then
                return {
                    xmult =  card.ability.mult_mult,
                }
            end
		end
	end
}

-- Russian roulette
SMODS.Joker {
	key = 'russian_roulette',
	loc_txt = {
		name = 'Russian Roulette',
		text = {
            "{X:mult,C:white}X#3#{} {C:mult}Mult{}",
            "{C:green}#1# in #2#{} chance to instead",
            "{C:red}destroy{} this joker.",
            "{C:attention}probability{} & {X:mult,C:white}XMult{} increases by",
            "{C:attention}1{} when blind is defeated"
		}
	},
	config = {chance=0,odds = 6,mult_mult=1,will_kill = false},
    unlocked = true,
    discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
    eternal_compat = false,
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = {card.ability.chance,card.ability.odds,card.ability.mult_mult,card.ability.will_kill} }
	end,
	calculate = function(self, card, context)
        
        if context.end_of_round and context.cardarea == G.jokers then
            card.ability.chance = card.ability.chance + 1
            card.ability.mult_mult = card.ability.mult_mult + 1
            return {
                message = "Risk up!"
            }
        end

        if context.joker_main and not context.blueprint then
            if pseudorandom('russian_roulette') < ((card.ability.chance * G.GAME.probabilities.normal) / card.ability.odds) then
                card:juice_up(0.3, 0.4)
                card:start_dissolve()
            else
                return {
                    xmult = card.ability.mult_mult
                }
            end
		end
	end
}

-- 3D Glasses
SMODS.Joker {
	key = '3d_glasses',
	loc_txt = {
		name = '3D Glasses',
		text = {
            "{X:chips,C:white}X#1#{} {C:chips}Chips{} or {X:mult,C:white}X#1#{} {C:mult}Mult{} depending on if",
            --"{C:chips}Chips{} or {C:mult}Mult{} depending on if",
            "remaining {C:blue}hands{} or {C:red}discards{} are higher."
		}
	},
	config = {mult=2},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true,
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 6, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = {
            card.ability.mult,
            }
        }
	end,
	calculate = function(self, card, context)

        if context.joker_main then

            local C = 1 + ((card.ability.mult - 1) * bool_to_number(G.GAME.current_round.hands_left >= G.GAME.current_round.discards_left))
            local M = 1 + ((card.ability.mult - 1) * bool_to_number(G.GAME.current_round.discards_left >= G.GAME.current_round.hands_left))
            
            return {
                xchips = C,
                xmult = M
            }
		end
        
	end
}

-- Birthday Card
SMODS.Joker {
	key = 'birthday_card',
	loc_txt = {
		name = 'Birthday Card',
		text = {
			"{C:green}#1# in #2#{} chance to give {C:money}$#3#{}",
            "at the end of every {C:attention}blind{}.",
            "{C:attention}payout{} decreases by {C:money}$1{} at the",
            "end of every {C:attention}blind{}.",
		}
	},
	config = { extra = {
        chance=1,
        odds = 2,
        money = 10
    } },
    unlocked = true,
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = false,
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 6, y = 1 },
	cost = 4,
	loc_vars = function(self, info_queue, card)
		return {vars = { 
            card.ability.extra.chance,
            card.ability.extra.odds,
            card.ability.extra.money
            }
        }
	end,
    calculate = function(self, card, context)
		if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then

            --NOTE: no boss req
            card.ability.extra.money = card.ability.extra.money - 1

            if card.ability.extra.money <= 0 then
                card:start_dissolve()
                G.jokers:remove_card(card)
                return {
                    card = target,
                    message = "Old!"
                }
            else
                return {
                    message = "Aged!"
                }
            end
        end
	end,
    calc_dollar_bonus = function(self, card)
        if card.ability.extra.money > 0 and pseudorandom('bday_card') < ((card.ability.extra.chance * G.GAME.probabilities.normal) / card.ability.extra.odds) then
            return card.ability.extra.money
        end
	end
}

--- Loan Shark
SMODS.Joker {
	key = 'loan_shark',
	loc_txt = {
		name = 'Loan Shark',
		text = {
			"{C:money}+$#1#{} when {C:attention}boss blind{} is defeated.",
            "Lose {C:money}-$#2#{} per {C:attention}hand{} played."
		}
	},
	config = { extra = {
        boss_money = 15,
        hand_cost = 2
    } },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 7, y = 1 },
	cost = 5,
    sell_cost = 0,
	loc_vars = function(self, info_queue, card)
		return {vars = { 
            card.ability.extra.boss_money,
            card.ability.extra.hand_cost,
            card.ability.extra.Sboss_money
            }
        }
	end,
    calculate = function(self, card, context)
		if context.joker_main then
            return {
                dollars = -1 * card.ability.extra.hand_cost
            }
        end
    end,
    calc_dollar_bonus = function(self, card)
        if G.GAME.blind.boss then
            return card.ability.extra.boss_money
        end
	end
}

--- Fine Wine
SMODS.Joker {
	key = 'fine_wine',
	loc_txt = {
		name = 'Fine Wine',
		text = {
			"{C:attention}double{} this joker's {C:attention}sell value{}",
            "when {C:attention}boss blind{} is defeated.",
		}
	},
	config = { extra = {} },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = true,
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
    sell_cost = 1,
	cost = 4,
    sell_cost = 1,
	loc_vars = function(self, info_queue, card)
		return {vars = {}
        }
	end,
	calculate = function(self, card, context)
		if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
            
            if G.GAME.blind.boss then
                card.sell_cost = card.sell_cost * 2
                return {
                    message = "Aged!"
                }
            end
        end
	end
}

--- C4
SMODS.Joker {
	key = 'c4_bomb',
	loc_txt = {
		name = 'C4',
		text = {
            "Gains {X:mult,C:white}+X#2#{} {C:mult}Mult{} when blind is selected.",
            "{C:red}destroy{} all cards in hand when the blind is defeated",
            "{C:attention}unless{} a {C:attention}high card{} of {C:attention}#3#{} was played during the blind.",
            "{V:1}#6#{}",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{} {C:mult}Mult{}{C:inactive}, rank is randomized each blind.)"
		}
	},
	config = {mult_mult=1.0,mult_gain=0.5,display_rank="Ace",chosen_rank=14,has_played=false,display_played="Has not been played yet this round.",colours = {G.C.RED}},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true,
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		return { vars = {
            card.ability.mult_mult,
            card.ability.mult_gain,
            card.ability.display_rank,
            card.ability.chosen_rank,
            card.ability.has_played,
            card.ability.display_played,
            colours = card.ability.colours
            }
        }
	end,
	calculate = function(self, card, context)

        if context.setting_blind and not context.blueprint then
            card.ability.mult_mult = card.ability.mult_mult + card.ability.mult_gain
            card.ability.colours = {G.C.RED}
            card.ability.chosen_rank = pseudorandom_element(get_rank_table(),pseudoseed("c4"))
            card.ability.display_rank = tostring(card.ability.chosen_rank)
            card.ability.has_played = false
            card.ability.display_played = "Has not been yet played this round."
            return {
                card = card,
                message = "Ticking!",
                colour = G.C.RED
            }
        end

        if context.before and context.scoring_name == "High Card" and not context.blueprint then
            local has_rank = nil;
            for _, v in pairs(context.scoring_hand) do
                if get_rank_table()[v:get_id() - 1] == card.ability.chosen_rank then has_rank = v end
            end
            if has_rank ~= nil then

                card.ability.has_played = true
                card.ability.display_played = "Has been played this round."
                card.ability.colours = {G.C.GREEN}

                return {
                    message = "Defused!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end

        if context.after and not context.blueprint and card.ability.has_played == false then
            return {
                card = card,
                message = "Tick...",
                colour = G.C.RED
            }
        end

        if context.joker_main then
            return {
                xmult = card.ability.mult_mult
            }
		end

        if context.end_of_round and context.cardarea == G.jokers then
            
            if card.ability.has_played == false then
                for _, v in pairs(G.hand.cards) do
                    --v:start_dissolve()
                    G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.0,func = function()
                        v:start_dissolve()
                        return true
                    end}))
                end
                return {
                    card = card,
                    message = "Detonated!",
                    colour = G.C.Red
                }
            end
        end
        
	end
}

--- Golden Ratio
SMODS.Joker {
	key = 'golden_ratio',
	loc_txt = {
		name = 'Golden Ratio',
		text = {
			"Earn {C:money}+$#4#{} for every {C:attention}discarded{} card",
            "with a rank within the next ",
            "{C:attention}4 digits{} of the {C:attention}golden ratio{}.",
            "{C:attention}digit depth{} increases by {C:attention}2{} after each hand played.",
            "{C:inactive}({C:attention}face{}{C:inactive} cards are {C:attention}0{}{C:inactive}, {C:attention}Aces{}{C:inactive} & {C:attention}Tens{}{C:inactive} are {C:attention}1{}{C:inactive}.){}",
            "Next 4 digits: {C:attention}#1#{}"
		}
	},
	config = {
        next_display = "1, 6, 1, 8",
        phi_jank_string = "161803398874989484820458683436563811772030917980576286213544862270526046281890244970720720418939113748475408807538689175212663386222353693179318006076672635443338908659593958290563832266131992829026788067520876689250171169620703222104321626954862629631361443814975870122034080588795445474924618569536486444924104432077134494704956584678850987433944221254487706647809158846074998871240076521705751797883416625624940758906970400028121042762177111777805315317141011704666599146697987317613560067087480710131795236894275219484353056783002287856997829778347845878228911097625003026961561700250464338243776486102838312683303724292675263116533924731671112115881863851331620384005222165791286675294654906811317159934323597349498509040947621322298101726107059611645629909816290555208524790352406020172799747175342777592778625619432082750513121815628551222480939471234145170223735805772786160086883829523045926478780178899219902707769038953219681986151437803149974110692608867429622675756052317277752035361393621076738937645560606059216589466759551900400555908950229530942312482355212212415444006470340565734797663972394949946584578873039623090375033993856210242369025138680414577995698122445747178034173126453220416397232134044449487302315417676893752103068737880344170093954409627955898678723209512426893557309704509595684401755519881921802064052905518934947592600734852282101088194644544222318891319294689622002301443770269923007803085261180754519288770502109684249362713592518760777884665836150238913493333122310533923213624319263728910670503399282265263556209029798642472759772565508615487543574826471814145127000602389016207773224499435308899909501680328112194320481964387675863314798571911397815397807476150772211750826945863932045652098969855567814106968372884058746103378105444390943683583581381131168993855576975484149144534150912954070050194775486163075422641729394680367319805861833918328599130396072014455950449779212076124785645916160837059498786006970189409886400764436170933417270919143365013715766011480381430626238051432117348151005590134561011800790506381421527093085880928757034505078081454588199063361298279814117453392731208092897279222132980642946878242748740174505540677875708323731097591511776297844328474790817651809778726841611763250386121129143683437670235037111633072586988325871033632223810980901211019899176841491751233134015273384383723450093478604979294599158220125810459823092552872124137043614910205471855496118087642657651106054588147560443178479858453973128630162544876114852021706440411166076695059775783257039511087823082710647893902111569103927683845386333321565829659773103436032322545743637204124406408882673758433953679593123221343732099574988946995656473600729599983912881031974263125179714143201231127955189477817269141589117799195648125580018455065632952859859100090862180297756378925999164994642819302229355234667475932695165421402109136301819472270789012208728736170734864999815625547281137347987165695274890081443840532748378",
        current_index = 2,
        money_per = 8
    },
    unlocked = true,
    discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 9,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_gold"]
        info_queue[#info_queue+1] = G.P_SEALS["Gold"]
        return {vars = {
                card.ability.next_display,
                card.ability.phi_jank_string,
                card.ability.current_index,
                card.ability.money_per
            }
        }
    end,
	calculate = function(self, card, context)

        if context.after and not context.blueprint then
            local four_index = tostring(string.sub(card.ability.phi_jank_string,card.ability.current_index,card.ability.current_index + 4));
            card.ability.current_index = card.ability.current_index + 1

            card.ability.next_display = ""
            for i=1,4 do
                card.ability.next_display = tostring(card.ability.next_display)..string.sub(tostring(four_index),i,i)
                if i < 4 then
                    card.ability.next_display = tostring(card.ability.next_display)..", "
                end
            end

            return {
                message_card = card,
                message = "Depth Increased!",
                colour = G.C.GOLD,
            }
        end

        if context.discard and not context.blueprint then
            local the_rank = context.other_card:get_id();
            if the_rank == 14 or the_rank == 10 then
                the_rank = 1
            end
            if context.other_card:is_face() then
                the_rank = 0
            end

            if string.find(card.ability.next_display,tostring(the_rank)) ~= nil then

                card:juice_up(0.3, 0.5)
                --G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                    --context.other_card:flip()
                    --context.other_card:juice_up(0.3, 0.5)
                    --context.other_card:set_seal("Gold", nil, true)
                    --context.other_card:set_ability(G.P_CENTERS.m_gold)
                    --context.other_card:flip()
                    --return true
                --end }))
                return {
                    message_card = card,
                    colour = G.C.GOLD,
                    dollars = card.ability.money_per
                }
            end
        end


	end
}

--- 6 shooter
SMODS.Joker {
	key = 'six_shooter',
	loc_txt = {
		name = 'Six Shooter',
		text = {
            "Each scored {C:attention}6{} gives {X:mult,C:white}X#1#{} {C:mult}Mult{}.",
            "{C:inactive}({}{C:attention}#2#{}{C:inactive} uses per ante, {}{C:attention}#3#{}{C:inactive} uses left).",
		}
	},
	config = {mult_mult=3,max_shots = 6, amount_left = 6},
    unlocked = true,
    discovered = true, 
    blueprint_compat = false,
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = {
            card.ability.mult_mult,
            card.ability.max_shots,
            card.ability.amount_left
            } 
        }
	end,
	calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 6 then
                if card.ability.amount_left > 0 then
                    card.ability.amount_left = card.ability.amount_left - 1
                    return {
                        card = card,
                        message = tostring(card.ability.amount_left).." left!",
                        xmult = card.ability.mult_mult
                    }
                else
                    return {
                        message_card = card,
                        message = "Empty",
                        color = G.C.Inactive
                    }
                end
			end
        end
        if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
            if G.GAME.blind.boss then
                card.ability.amount_left = card.ability.max_shots
                return {
                    message_card = card,
                    message = "Reloaded!"
                }
            end
        end
    end
}

--- stonehenge
SMODS.Joker {
	key = 'stonehenge',
	loc_txt = {
		name = 'Stonehenge',
		text = {
			"Each scoring {C:attention}stone card{} gives {X:mult,C:white}X#1#{} {C:mult}Mult{}.",
            "Increases by {X:mult,C:white}X#2#{} {C:mult}Mult{} if the scoring",
            "hand contains atleast {C:attention}4 stone cards{}."
		}
	},
    enhancement_gate = "m_stone",
	config = {
        mult_mult = 1,
        mult_gain = 0.2
    },
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_stone"]
        return {vars = {
            card.ability.mult_mult,
            card.ability.mult_gain
        }}
    end,
	calculate = function(self, card, context)

        if context.before and not context.blueprint then
            local count = 0;
            for _, v in pairs(context.scoring_hand) do
                if SMODS.has_enhancement(v, "m_stone") then count = count + 1 end
            end
            if count >= 4 then
                card.ability.mult_mult = card.ability.mult_mult + card.ability.mult_gain
                return {
                    message_card = card,
                    message = "Upgraded!",
                    colour = G.C.MULT
                }
            end
        end

        if context.individual and context.cardarea == G.play then
            if SMODS.has_enhancement(context.other_card, "m_stone") and not context.other_card.debuff then
                return {
                    xmult = card.ability.mult_mult
                }
            end
        end


	end
}

--- Tax Doccument
SMODS.Joker {
	key = 'tax_doccument',
	loc_txt = {
		name = 'Tax Doccument',
		text = {
			"{C:red}Lose{} {C:attention}half{} the {C:attention}initial payout{} of",
            "blinds as {C:money}${} at the start of every blind.",
            "This joker gains {C:chips}+#1# Chips{} for",
            "every {C:money}${} lost this way.",
            "{C:inactive}(Currently {C:chips}+#2# Chips{C:inactive}.)",
            "{C:inactive}(Gains {C:money}sell value{C:inactive} equal to lost {C:money}${C:inactive})"
		}
	},
	config = {
        chips_per_dollar = 20,
        current_chips = 0
    },
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.chips_per_dollar,
            card.ability.current_chips
        }}
    end,
	calculate = function(self, card, context)

        if context.setting_blind and not context.blueprint then
            local number = math.floor(G.GAME.blind.dollars / 2)
            card.ability.current_chips = card.ability.current_chips + (number * card.ability.chips_per_dollar)
            card.sell_cost = card.sell_cost + number
            return {
                card = card,
                message = "+"..tostring(number * card.ability.chips_per_dollar),
                colour = G.C.CHIPS,
                dollars = -1 * number
            }
        end

        if context.joker_main then
            return {
                chips = card.ability.current_chips
            }
		end



	end
}

-- Palace Grounds
SMODS.Joker {
	key = 'palace_grounds',
	loc_txt = {
		name = 'Palace Grounds',
		text = {
			"Gain {C:money}+$#1#{} and increase",
            "payout by {C:money}$#2#{} if the",
            "scoreding hand contains a",
            "{C:attention}Full House{} made of only",
            "{C:attention}Queens{}, {C:attention}Kings{} or {C:attention}Jacks{}."
		}
	},
	config = { money_given = 0, money_gain = 1 },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.money_given, card.ability.money_gain } }
	end,
	calculate = function(self, card, context)

        if context.before then
            if next(context.poker_hands['Full House']) then---or next(context.poker_hands['Flush House']) then
                local ranks = {11,12,13};
                local valid = true
                for _, v in pairs(context.scoring_hand) do
                    if indexOf(ranks,v.base.id) == nil then valid = false end
                end
                if valid then
                    card.ability.money_given = card.ability.money_given + card.ability.money_gain
                    return {
                        dollars = card.ability.money_given,
                        card = card,
                        message = "Upgraded!",
                        colour = G.C.MONEY
                    }
                end
            end

		end

	end
}

--- Domino
SMODS.Joker {
	key = 'domino',
	loc_txt = {
		name = 'Domino',
		text = {
            "{C:money}$#1#{} for every pair held in hand",
            "at the end of every round."
		}
	},
	config = {money_per_pair=3},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true,
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 5, y = 1 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
		return { vars = {
            card.ability.money_per_pair
            }
        }
	end,
	calculate = function(self, card, context)

        if context.end_of_round and context.individual then
            
            local ranks_seen = {}
            for _, v in pairs(G.hand.cards) do
                ranks_seen[v:get_id()] = (ranks_seen[v:get_id()] or 0) + 1
            end
            if ranks_seen[context.other_card:get_id()] ~= nil then
                if tonumber(ranks_seen[context.other_card:get_id()]) >= 2 then

                    local cards_of_this_rank = {}
                    for a, b in pairs(G.hand.cards) do
                        if b.base.id == context.other_card.base.id then
                            cards_of_this_rank[#cards_of_this_rank + 1] = b
                        end
                    end

                    if indexOf(cards_of_this_rank,context.other_card) == 1 then
                        return {
                            dollars = card.ability.money_per_pair
                        }
                    end
                end
            end
        end
        
	end
}

--- wild west
SMODS.Joker {
	key = 'wild_west',
	loc_txt = {
		name = 'Wild West',
		text = {
			"Scored {C:attention}wildcards{} give a {C:attention}random effect{} out of:",
            "{C:chips}+#1# Chips{}, {X:chips,C:white}X#2#{} {C:chips}Chips{}, {C:mult}+#3# Mult{}, {X:mult,C:white}X#4#{} {C:mult}Mult{}, or {C:money}+$#5#{}"
		}
	},
    enhancement_gate = "m_wild",
	config = {
        chip_gain = 30,
        chip_mult = 1.5,
        mult_gain = 5,
        mult_mult = 2,
        money_gain = 3,
    },
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_wild"]
        return {vars = {
            card.ability.chip_gain,
            card.ability.chip_mult,
            card.ability.mult_gain,
            card.ability.mult_mult,
            card.ability.money_gain
        }}
    end,
	calculate = function(self, card, context)

        if context.individual and context.cardarea == G.play then
            if SMODS.has_enhancement(context.other_card, "m_wild") and not context.other_card.debuff then
                local choice = pseudorandom_element({"chips","chip mult","mult","mult mult","money"},pseudoseed("wild_west"))
                if choice == "chips" then
                    return {
                        chips = card.ability.chip_gain
                    }
                end
                if choice == "chip mult" then
                    return {
                        xchips = card.ability.chip_mult
                    }
                end
                if choice == "mult" then
                    return {
                        mult = card.ability.mult_gain
                    }
                end
                if choice == "mult mult" then
                    return {
                        xmult = card.ability.mult_mult
                    }
                end
                if choice == "money" then
                    return {
                        dollars = card.ability.money_gain
                    }
                end
                
            end
        end


	end
}

-- nebula
SMODS.Joker {
	key = 'nebula',
	loc_txt = {
		name = 'Nebula',
		text = {
            "{E:1,C:purple}Balance{} the base",
            "{C:chips}Chips{} & {C:mult}Mult{}",
            "of the played hand."
		}
	},
	config = {},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true,
    perishable_compat = true, 
    eternal_compat = true,
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = {
            }
        }
	end,
	calculate = function(self, card, context)
        if context.initial_scoring_step then
            return {
                balance = true,
            }

		end
	end
}

-- plasma globe
SMODS.Joker {
	key = 'plasma_globe',
	loc_txt = {
		name = 'Plasma Globe',
		text = {
            "{E:1,C:purple}Balance{} {C:chips}Chips{} & {C:mult}Mult{}",
            "when playing your {C:attention}last hand{}."
		}
	},
	config = {},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true,
    perishable_compat = true, 
    eternal_compat = true,
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 8,
	loc_vars = function(self, info_queue, card)
		return { vars = {
            }
        }
	end,
	calculate = function(self, card, context)
        if context.final_scoring_step and G.GAME.current_round.hands_left == 0 then
            return {
                balance = true,
            }

		end
	end
}

-- splitting the atom
SMODS.Joker {
	key = 'splitting_atom',
	loc_txt = {
		name = 'Splitting the atom',
		text = {
			"If the played hand contains an {C:attention}Ace{}",
            "{C:red}destroy{} a random scored {C:attention}Ace{}",
            "and {E:1,C:purple}balance{} {C:chips}Chips{} & {C:mult}Mult{}",
            "at the end of scoring"
		}
	},
	config = {target={}},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 5,
    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,
	calculate = function(self, card, context)

        if context.final_scoring_step then
            local valid_targets = {}
            for i=1,#G.play.cards do
                if G.play.cards[i]:get_id() == 14 and not G.play.cards[1].debuff then
                    valid_targets[#valid_targets+1] = G.play.cards[i]
                end
            end

            if #valid_targets >= 1 then
                local target = pseudorandom_element(valid_targets,pseudoseed("split_target"))
                card.ability.target[#card.ability.target + 1] = target
                return {
                    balance = true
                }
            end
        end

        if context.destroying_card and context.destroying_card.area == G.play then
            if context.destroying_card == (card.ability.target[1] or 0) then
                local target = card.ability.target[1]
                card.ability.target = {}
                return {
                    message_card = target,
                    message = "Split!",
                    colour = G.C.DARK_EDITION,
                    remove = true
                }
            end
        end
	end
}

-- uno reverse
SMODS.Joker {
	key = 'uno reverse',
	loc_txt = {
		name = 'UNO Reverse Card',
		text = {
            "{C:attention}Swap{} {C:chips}Chips{} & {C:mult}Mult{}",
            "when this joker is scored."
		}
	},
	config = {},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true,
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = {}
        }
	end,
	calculate = function(self, card, context)

        if context.joker_main then
            return {   
                message_card = card,
                message = "Reversed!",
                swap = true
            }
		end
        
	end
}

-- Alchemist
SMODS.Joker {
	key = 'alchemist',
	loc_txt = {
		name = 'Alchemist',
		text = {
            "{C:inactive}Steel{} cards are converted into {C:gold}gold{}",
            "cards before scoring, and {C:gold}gold{} into {C:inactive}steel{}.",
            "{C:inactive}steel{} cards give {C:money}+#1#${} at the end of round.",
            "{C:gold}gold{} cards give {X:mult,C:white}X#2#{} {C:mult}Mult{} while held in hand."
		}
	},
	config = { steel_money = 2, gold_xmult = 1.25},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 8,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_steel"]
        info_queue[#info_queue+1] = G.P_CENTERS["m_gold"]
		return { vars = { 
            card.ability.steel_money,
            card.ability.gold_xmult
         } }
	end,
	calculate = function(self, card, context)

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if SMODS.has_enhancement(context.other_card, "m_steel") and not context.other_card.debuff then
                context.other_card:set_ability(G.P_CENTERS.m_gold)
                return {
                    message_card = context.other_card,
                    message = "Golden!",
                    color = G.C.GOLD
                }
            end
            if SMODS.has_enhancement(context.other_card, "m_gold") and not context.other_card.debuff then
                context.other_card:set_ability(G.P_CENTERS.m_steel)
                return {
                    message_card = context.other_card,
                    message = "Steel!",
                    color = G.C.inactive
                }
            end
		end

        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            if SMODS.has_enhancement(context.other_card, "m_gold") and not context.other_card.debuff then
                return {
                    xmult = card.ability.gold_xmult
                }
            end
        end

        if context.individual and context.cardarea == G.hand and context.end_of_round then
            if SMODS.has_enhancement(context.other_card, "m_steel") and not context.other_card.debuff then
                return {
                    dollars = card.ability.steel_money
                }
            end
        end
	end
}

-- 24 Karat Gold
SMODS.Joker {
	key = '24_karat_onionmod',
	loc_txt = {
		name = '24 Karat Gold',
		text = {
            "Scoring {C:gold}gold{} cards have their",
            "payout increased by {C:money}$#1#{}.",
            "Scoring {C:attention}2{}'s & {C:attention}4{}'s give {C:money}$1{} for",
            "every {C:attention}#2#{} {C:gold}gold{} cards held in hand."
		}
	},
    enhancement_gate = "m_gold",
	config = { payout_increase = 1, cards_per_money = 2 },
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 8,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_gold"]
		return { vars = { 
            card.ability.payout_increase,
            card.ability.cards_per_money
         } }
	end,
	calculate = function(self, card, context)

        if context.individual and context.cardarea == G.play then
            if context.other_card.base.id == 2 or context.other_card.base.id == 4 then
                local count = 0
                for a,b in pairs(G.hand.cards) do
                    if SMODS.has_enhancement(b, "m_gold") then
                        count = count + 1
                        if math.floor(0.5 + (count / card.ability.cards_per_money)) == (count / card.ability.cards_per_money) then
                            delay(0.25)
                            ease_dollars(1)
                            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + 1
                            G.E_MANAGER:add_event(Event({func = (function()
                                G.GAME.dollar_buffer = 0;
                                b:juice_up(0.3, 0.5);
                                return true
                            end)}))
                        end

                    end
                    --if SMODS.has_enhancement(b, "m_gold") then
                    --    count = count + 1
                    --    if math.floor(0.5 + (count / card.ability.cards_per_money)) == (count / card.ability.cards_per_money) then
                    --        G.E_MANAGER:add_event(Event({
                    --            trigger = 'immediate',--after',
                    --            delay = 0.05,
                    --            blockable = false,
                    --            func =  function()
                    --                b:juice_up(0.3, 0.5)
                    --                ease_dollars(1)
                    --                return true 
                    --        end }))
                    --    end
                    --end
                end
            end

            if SMODS.has_enhancement(context.other_card, "m_gold") and not context.other_card.debuff then
                --print(tprint(context.other_card.ability))
                context.other_card.ability.h_dollars = context.other_card.ability.h_dollars + card.ability.payout_increase
                context.other_card:juice_up(0.3, 0.5) 
                return {message_card = context.other_card, message = "Upgraded!", color = G.C.Gold} 
            end

		end
	end
}

-- Stardust
SMODS.Joker {
	key = 'stardust',
	loc_txt = {
		name = 'Stardust',
		text = {
            "{C:planet}Planet{} cards gain either",
            "{C:dark_edition}Foil{}, {C:dark_edition}Holographic{} or",
            "{C:dark_edition}Polychrome{} when bought",
            "directly from the shop."
		}
	},
	config = {},
    unlocked = true,
    discovered = true, 
    blueprint_compat = false,
    perishable_compat = true, 
    eternal_compat = true,
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = {}
        }
	end,
	calculate = function(self, card, context)

        if context.buying_card and not context.blueprint then
            if context.card.ability.set == "Planet" then

                G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.25,
                func = (function()
                        local editi = pseudorandom_element(G.P_CENTER_POOLS.Edition,pseudoseed("stardust")).key
                        local i = 0
                        while editi == "e_base" or editi == "e_negative" do 
                            editi = pseudorandom_element(G.P_CENTER_POOLS.Edition,pseudoseed("stardust"..tostring(i))).key
                            i = i + 1
                        end
                        context.card:set_edition(editi, true)
                        context.card:juice_up(0.3, 0.5)
                        delay(0.5)
                        return {
                            message_card = context.card,
                            message = "Dusted!"
                        }
                    end)
                }))
                card:juice_up(0.3, 0.5)
            end

		end
        
	end
}

-- windows 95
SMODS.Joker {
	key = 'windows 95',
	loc_txt = {
		name = 'Windows 95',
		text = {
			"Gains {C:mult}+#2# Mult{} when a {C:attention}9{} or {C:attention}5{} is scored.",
            "When passing {C:mult}32 Mult{}, resets to",
            "{C:mult}0 Mult{} and gains {X:chips,C:white}X#4#{} {C:chips}Chips{}.",
            "{C:inactive}(Currently {C:mult}+#1# Mult{C:inactive} & {X:chips,C:white}X#3#{} {C:chips}Chips{C:inactive}.)"
		}
	},
	config = { mult = 0, mult_gain = 3, xchips = 1, xchips_gain = 0.25 },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true,
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = {
            card.ability.mult,
            card.ability.mult_gain,
            card.ability.xchips,
            card.ability.xchips_gain
        } }
	end,
	calculate = function(self, card, context)

        if context.individual and context.cardarea == G.play then
            if context.other_card.base.id == 9 or context.other_card.base.id == 5 then
                card.ability.mult = card.ability.mult + card.ability.mult_gain
                if card.ability.mult > 32 then
                    card.ability.mult = 0
                    card.ability.xchips = card.ability.xchips + card.ability.xchips_gain
                    return {
                        --colour = G.C.CHIPS,
                        message_card = card,
                        message = "Reset & Upgrade!"
                    }
                else
                    return {
                        message_card = card,
                        message = "Upgrade!"
                    }
                end
            end
        end

        if context.joker_main then
			return {
				mult = card.ability.mult,
                xchips = card.ability.xchips,
			}
		end

	end
}

-- sleeper agent
SMODS.Joker {
	key = 'sleeper_agent',
	loc_txt = {
		name = 'Sleeper Agent',
		text = {
			"When a specific {C:attention,E:4}unknown{} poker hand",
            "is played, create an {C:uncommon}Uncommon{} {C:attention}Joker{}.",
            "{C:green}#1# in #2#{} chance to instead be {C:rare}Rare{}.",
            "{C:inactive}(Hand is randomized on creation and{}",
            "{C:inactive}when boss blind is defeated. Must have room.){}"
		}
	},
	config = {
        chance = 1,
        odds = 8,
        poker_hand = "High Card"
        },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 8,
	loc_vars = function(self, info_queue, card)
		return { vars = {''..(G.GAME and G.GAME.probabilities.normal or 1), card.ability.odds, card.ability.poker_hand} }
	end,
	calculate = function(self, card, context)

        if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
            if G.GAME.blind.boss then
                local poker_hands = {}
                for k, v in pairs(G.GAME.hands) do
                    if v.visible then
                        poker_hands[#poker_hands + 1] = k
                    end
                end
                card.ability.poker_hand = pseudorandom_element(poker_hands, pseudoseed('slperangentrando'..tostring(card.ability.poker_hand)))
                
                return {
                    card = card,
                    message = "Randomized!"
                }
            end
        end

        if context.before and context.scoring_name == card.ability.poker_hand then
            
            card:juice_up(0.3, 0.5)
            if #G.jokers.cards < G.jokers.config.card_limit then

                local poker_hands = {}
                for k, v in pairs(G.GAME.hands) do
                    if v.visible then
                        poker_hands[#poker_hands + 1] = k
                    end
                end
                card.ability.poker_hand = pseudorandom_element(poker_hands, pseudoseed('slperangentrando'..tostring(card.ability.poker_hand)))
                if pseudorandom('slpagnt') < ((card.ability.chance * G.GAME.probabilities.normal) / card.ability.odds) then
                    --rare
                    local new_joker = SMODS.add_card({set = 'Joker', rarity = 1 })
                    return {
                        message = "Rare!"
                    }
                else
                    --uncommon
                    local new_joker = SMODS.add_card({set = 'Joker', rarity = 0.85 })
                    return {
                        message = "Awake!"
                    }
                end
            end

		end

	end
}

-- pop-up
SMODS.Joker {
	key = 'popup',
	loc_txt = {
		name = 'Pop-up',
		text = {
			"When exiting a shop lose {C:money}-$3{}",
            "and create a {C:attention}random consumeable{}.",
            "{C:inactive}(Must have room, lose {C:money}${C:inactive} regardless.)"
		}
	},
	config = {},
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 4 },
	cost = 4,
	loc_vars = function(self, info_queue, card)
		return { vars = { } }
	end,
	calculate = function(self, card, context)

        if context.ending_shop then
            if #G.consumeables.cards < G.consumeables.config.card_limit then
                local the_set = pseudorandom_element({"Tarot","Spectral","Planet"},pseudoseed("lancerdeltaruneisacooldude"))
                local new_joker = SMODS.add_card({set = the_set })
            end
            return {
                dollars = -3,
            }

		end

	end
}

-- three body problem
SMODS.Joker {
	key = '3bodyproblem',
	loc_txt = {
		name = 'Three Body Problem',
		text = {
			"Create {C:attention}3{} {E:1,C:dark_edition}negative{} {C:planet}Planet{} cards",
            "if the first played hand of a round",
            "contains a {C:attention}Three of a Kind{}."
		}
	},
	config = {
        extra = { mult = 0},
    },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	calculate = function(self, card, context)
        if G.GAME.current_round.hands_played < 1 and context.before and next(context.poker_hands['Three of a Kind']) then
            local new_card = SMODS.add_card({set = "Planet",edition="e_negative" })
            local new_card2 = SMODS.add_card({set = "Planet",edition="e_negative" })
            local new_card3 = SMODS.add_card({set = "Planet",edition="e_negative" })
            card:juice_up(0.3, 0.5) 
            return {
                message = "Created!"
            }
		end
	end
}

-- card against humanity
SMODS.Joker {
	key = 'cardagainsthumanity',
	loc_txt = {
		name = 'Card Against Humanity',
		text = {
            "Gains {X:chips,C:white}X#2#{} {C:chips}Chips{} for",
            "every {C:attention}face card{} discarded.",
            "{C:inactive}(Currently {X:chips,C:white}X#1#{} {C:chips}Chips{}{C:inactive}.)"
		}
	},
	config = {chips_mult = 1.0,chip_mult_gain=0.05},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 8,
	loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.chips_mult,
            card.ability.chip_mult_gain
        }}
    end,
	calculate = function(self, card, context)

        if context.joker_main then
            return {xchips = card.ability.chips_mult}
        end

        if context.discard and not context.blueprint then
            if context.other_card:is_face() then
                card.ability.chips_mult = math.max(1.0,card.ability.chips_mult + card.ability.chip_mult_gain)
                return {
                    message = "+X"..tostring(card.ability.chip_mult_gain),
                    colour = G.C.CHIPS,
                    message_card = card
                }
            end
        end


	end
}

-- stained glass
SMODS.Joker {
	key = 'stained_glass',
	loc_txt = {
		name = 'Stained Glass',
		text = {
            "{C:attention}Glass{} cards gain a random",
            "{C:dark_edition}edition{} when drawn to hand."
		}
	},
    enhancement_gate = "m_glass",
	config = {},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_glass"]
        return {vars = {}}
    end,
	calculate = function(self, card, context)

        if context.hand_drawn then
            for _,i in pairs(context.hand_drawn) do
                if SMODS.has_enhancement(i, "m_glass") then
                    --G.play.cards
                    local editi = pseudorandom_element(G.P_CENTER_POOLS.Edition,pseudoseed("glasseditonstained")).key
                    local a = "1"
                    while editi == "e_base" do 
                        editi = pseudorandom_element(G.P_CENTER_POOLS.Edition,pseudoseed(a)).key
                        a = a + "1"
                    end
                    if editi == "e_negative" then
                        if not negative_less_likely() then
                            editi = pseudorandom_element(G.P_CENTER_POOLS.Edition,pseudoseed("lemon")).key
                        end
                    end
                    i:set_edition(editi, true)
                    i:juice_up(0.3, 0.5)
                    card:juice_up(0.3, 0.5)
                end
            end 
        end
	end
}

-- chipped windscreen
SMODS.Joker {
	key = 'chipped_screen',
	loc_txt = {
		name = 'Chipped Windscreen',
		text = {
            "{C:red}Destroyed {C:attention}glass{} cards create a copy of themselves",
            "with {X:mult,C:white}-X0.25{} {C:mult}Mult{} & {X:chips,C:white}+X0.5{} {C:chips}Chips{}",
            "{C:inactive}(Unless going below {X:mult,C:white}X1{} {C:mult}Mult{C:inactive}.){}"
		}
	},
    enhancement_gate = "m_glass",
	config = {},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_glass"]
        return {vars = {}}
    end,
	calculate = function(self, card, context)

        if context.remove_playing_cards and not context.blueprint then
            for _, v in pairs(context.removed) do
                if SMODS.has_enhancement(v, "m_glass") then
                    

                    v.ability.x_mult = v.ability.x_mult - 0.25
                    v.ability.Xmult = v.ability.x_mult
                    v.ability.perma_x_chips = (v.ability.perma_x_chips or 1.0) + 0.5
                    --v.ability.perma_x_chips = v.ability.x_chips

                    if v.ability.x_mult >= 1.0 then
                        local copied = copy_card(v)
                        -- heres where the deck shenanigans happen
                        copied:add_to_deck()
                        G.deck.config.card_limit = G.deck.config.card_limit + 1
                        table.insert(G.playing_cards, copied)
                        G.hand:emplace(copied)
                    end
                end
            end
        end
	end
}

--jack in the box
SMODS.Joker {
	key = 'jack_in_box',
	loc_txt = {
		name = 'Jack in the box',
		text = {
            "Every {C:attention}Jack{} held in hand",
            "gives {C:chips}+#1# Chips{} for every",
            "{C:attention}Jack{} held in hand."
		}
	},
	config = { chips = 25},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 4,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.chips,} }
	end,
	calculate = function(self, card, context)

        if context.individual and context.cardarea == G.hand and not context.end_of_round then

            if context.other_card.base.id == 11  and not context.other_card.debuff then
                local gains = {}

                for i = 1, #G.hand.cards do
                    if G.hand.cards[i].base.id == 11 then
                        gains[#gains+1] = {chips = card.ability.chips}
                    end
                end

                --message nesting
                local return_value =  {}
                local last_had_extra = false
                local g = reverse_table_num(gains)
                for _,i in pairs(g) do
                    if indexOf(g,i) == 1 then
                        return_value = i
                    else
                        local copy = return_value
                        i.extra = copy
                        return_value = i
                    end
                end

                if return_value ~= {} then
                    return return_value
                end
                
            end
        end

	end
}

-- in the rough
SMODS.Joker {
	key = 'in the rough',
	loc_txt = {
		name = 'In the rough',
		text = {
            "Gives {C:chips}+#1# Chips{} for every",
            "{V:1}Diamond{} card remaining in deck.",
            "{C:inactive}(Currently {C:chips}+#2# Chips{} {C:inactive}.)"
		}
	},
	config = { deck_chips = 8,deck_text = 0},
    unlocked = true,
    discovered = true,
    blueprint_compat = true, 
    perishable_compat = true,
    eternal_compat = true, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 3,
	loc_vars = function(self, info_queue, card)

        local count = 0
        if G.deck then
            for i = 1, #G.deck.cards do
                if G.deck.cards[i]:is_suit("Diamonds") then count = count + 1 end
            end
        end
        card.ability.deck_text = card.ability.deck_chips * count

		return {
            vars = {
                card.ability.deck_chips,
                card.ability.deck_text,
                colours = { G.C.SUITS["Diamonds"] }
            }
        }
	end,
	calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.deck_text,
            }
        end

	end
}

--mutiny
SMODS.Joker {
	key = 'mutiny',
	loc_txt = {
		name = 'Mutiny',
		text = {
            "If there are {C:attention}1 or 2 face{} cards",
            "held in hand after each hand scored",
            "{C:attention}discard{} the face cards and give",
            "all other cards {C:mult}+#1# Mult{}."
		}
	},
	config = {add_mult = 2},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = {card.ability.add_mult} }
	end,
	calculate = function(self, card, context)

        if context.individual and context.cardarea == G.hand then
            local amount_of_face = 0
            for a,b in pairs(G.hand.cards) do
                if b:is_face() then amount_of_face = amount_of_face + 1 end
            end
            
            if amount_of_face < 3 and amount_of_face > 0 then
                if context.other_card:is_face() then
                    draw_card(G.hand,G.discard, 0.5,'down', nil, context.other_card, 0.07)
                    return {  
                        message_card = context.other_card,
                        message = "Mutiny!"
                    }
                else
                    context.other_card.ability.perma_mult = context.other_card.ability.perma_mult + card.ability.add_mult
                    return {
                        message = "Upgraded!"
                    }
                end
            end
		end
	end
}

function consp_text(textt,colourr,scalee)
    return {n = G.UIT.T, config = {minw=5, align = "tm", text = textt, colour = colourr, scale = scalee}}
end

function consp_phrase(card)
    local phrase = {}
    local gain = 1
    if string.find(card.ability.extra.cond,"hand") ~= nil then gain = 5 end
    if string.find(card.ability.extra.cond,"sold") ~= nil then gain = 2 end
    if string.find(card.ability.extra.cond,"destroyed") ~= nil then gain = 4 end

    phrase[#phrase+1] = {text = "+"..tostring(gain),colour = G.C.MULT}
    phrase[#phrase+1] = {text = "Mult",colour = G.C.MULT}
    phrase[#phrase+1] = {text = "per"}
    if string.find(card.ability.extra.cond,"C") ~= nil then
        phrase[#phrase+1] = {text = "unique"}
        if string.find(card.ability.extra.cond,"suit") ~= nil then
            phrase[#phrase+1] = {text = "suit",colour = G.C.FILTER}
        end
        if string.find(card.ability.extra.cond,"rank") ~= nil then
            phrase[#phrase+1] = {text = "rank",colour = G.C.FILTER}
        end
    end
    if string.find(card.ability.extra.cond,"P") ~= nil then
        --phrase[#phrase+1] = {text = "individual"}
        if string.find(card.ability.extra.cond,"suit") ~= nil then
            phrase[#phrase+1] = {text = tostring(card.ability.extra.condvar):sub(1, -2),colour = G.C.SUITS[card.ability.extra.condvar]}
            phrase[#phrase+1] = {text = "card"}
        end
        if string.find(card.ability.extra.cond,"rank") ~= nil then
            phrase[#phrase+1] = {text = get_rank_table()[card.ability.extra.condvar - 1],colour = G.C.FILTER}
        end
    end 

    if string.find(card.ability.extra.cond,"S") ~= nil then
        if string.find(card.ability.extra.cond,"hand") ~= nil then
            phrase[#phrase+1] = {text = tostring(card.ability.extra.condvar),colour = G.C.FILTER}
            phrase[#phrase+1] = {text = "played"}
        else
            phrase[#phrase+1] = {text = "scored",colour = G.C.FILTER}
        end
    end

    if string.find(card.ability.extra.cond,"sold") ~= nil then
        phrase[#phrase+1] = {text = "card"}
        phrase[#phrase+1] = {text = "sold",colour = G.C.FILTER}
    end

    if string.find(card.ability.extra.cond,"destroyed") ~= nil then
        phrase[#phrase+1] = {text = "playing"}
        phrase[#phrase+1] = {text = "card"}
        phrase[#phrase+1] = {text = "destroyed",colour = G.C.RED}
    end

    if string.find(card.ability.extra.cond,"unscored") ~= nil then
        phrase[#phrase+1] = {text = "card"}
        phrase[#phrase+1] = {text = "played"}
        phrase[#phrase+1] = {text = "&"}
        phrase[#phrase+1] = {text = "unscored",colour = G.C.FILTER}
    end

    if string.find(card.ability.extra.cond,"D") ~= nil then
        phrase[#phrase+1] = {text = "discarded",colour = G.C.RED}
    end

    card.ability.extra.phrase = phrase
    return phrase
end

function consp_reveal_step(card)
    card.ability.extra.trigs = card.ability.extra.trigs + 1
    if card.ability.extra.trigs >= card.ability.extra.max_trigs then
        card.ability.extra.trigs = 0
        local cont = false
        local targets = {}
        for i=1, #card.ability.extra.revealed do
            if not card.ability.extra.revealed[i] then
                cont = true
                targets[#targets+1] = i
            end
        end

        if cont then
            local next_step = pseudorandom_element(targets,pseudoseed("consp"))
            card.ability.extra.revealed[next_step] = true
            card_eval_status_text(card, 'jokers', 1, nil, nil, {message = "Hint!", colour = G.C.GREEN})
        end
    end
end

-- conspiracy board
SMODS.Joker {
	key = 'conspiracy_board',
	loc_txt = {
		name = 'Conspiracy Board',
		text = {
			"Gains {C:mult}Mult{} based on an {C:attention}unknown condition{}.",
            "{C:attention}1{} word in the {C:attention}condition{} is revealed every {C:attention}#2#{C:inactive}[#3#]{} triggers",
			--"{C:inactive}(Conditon changes every {C:attention}Ante{C:inactive}){}",
            --"{C:inactive}(E.g. specific rank scored, per unique suit discarded, etc...)",
            --"{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult)"
		}
	},
	config = { extra = {
        mult = 0,
        cond = "PsuitS",
        condvar = "Spades",
        phrase = {},
        revealed = {},
        trigs = 0,
        max_trigs = 2
    } },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true,
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 2 },
	cost = 5,
    add_to_deck = function(self, card, from_debuff)
        local phrase = consp_phrase(card)
        card.ability.extra.phrase = phrase
        card.ability.extra.revealed = {}
        for i=1,#phrase do
            card.ability.extra.revealed[#card.ability.extra.revealed + 1] = false
        end
    end,
	loc_vars = function(self, info_queue, card)

        local phrase = consp_phrase(card)

        card.ability.extra.phrase = phrase

        local phrase_nodes = {}
        for i=1,#phrase do
            if card.ability.extra.revealed[i] then
                phrase_nodes[#phrase_nodes+1] = consp_text(" "..phrase[i].text,phrase[i].colour or G.C.UI.TEXT_DARK,0.35)
            else
                local t = " "
                for i=1,#phrase[i].text do
                    t = t.."?"
                end
                phrase_nodes[#phrase_nodes+1] = consp_text(t,G.C.UI.TEXT_INACTIVE,0.35)
            end
        end

        local m_end = {
            {n = G.UIT.C, config = {maxw = 7,minw=0,maxh = 1.0, minh=0, colour = G.C.WHITE, padding = 0.1}, nodes = {
                {n = G.UIT.R, config = {minw=0, minh=0, align = "tm", colour = G.C.WHITE, padding = 0},
                    nodes = phrase_nodes
                },
                {n = G.UIT.R, config = {minw=5, minh=0, align = "tm", colour = G.C.WHITE, padding = 0}, nodes = {
                    consp_text("(Conditon changes every ",G.C.UI.TEXT_INACTIVE,0.25),
                    consp_text("Ante",G.C.FILTER,0.25),
                    consp_text(".)",G.C.UI.TEXT_INACTIVE,0.25)
                }},
                {n = G.UIT.R, config = {minw=5, minh=0, align = "tm", colour = G.C.WHITE, padding = 0}, nodes = {
                    consp_text("(Currently",G.C.UI.TEXT_INACTIVE,0.25),
                    consp_text(" +"..tostring(card.ability.extra.mult or 0).." Mult",G.C.MULT,0.25),
                    consp_text(".)",G.C.UI.TEXT_INACTIVE,0.25)
                }}
            }}
        }

		return { main_end = m_end,vars = { card.ability.extra.mult,card.ability.extra.max_trigs,card.ability.extra.trigs} }
	end,
	calculate = function(self, card, context)

        --card.ability.extra.mult = card.ability.extra.mult

        if context.joker_main then
			return {
				mult = card.ability.extra.mult,
			}
		end

        --specific scoring conditons (PS)
        if string.find(card.ability.extra.cond,"P") ~= nil and string.find(card.ability.extra.cond,"S") ~= nil then
            --scoring specific
            if context.individual and context.cardarea == G.play then
                --PsuitS
                if string.find(card.ability.extra.cond,"suit") ~= nil then
                    if context.other_card:is_suit(card.ability.extra.condvar) then
                        card.ability.extra.mult = card.ability.extra.mult + 1
                        consp_reveal_step(card)
                        return {
                            message_card = card,
                            message = "+1 Mult"
                        }
                    end
                end
                --PrankS
                if string.find(card.ability.extra.cond,"rank") ~= nil then
                    if context.other_card:get_id() == card.ability.extra.condvar then
                        card.ability.extra.mult = card.ability.extra.mult + 1
                        consp_reveal_step(card)
                        return {
                            message_card = card,
                            message = "+1 Mult"
                        }
                    end
                end
            end

        end
        --specific discarding conditions (PD)
        if string.find(card.ability.extra.cond,"P") ~= nil and string.find(card.ability.extra.cond,"D") ~= nil then
            --discarding specific
            if context.discard then
                --PsuitD
                if string.find(card.ability.extra.cond,"suit") ~= nil then
                    if context.other_card:is_suit(card.ability.extra.condvar) then
                        card.ability.extra.mult = card.ability.extra.mult + 1
                        consp_reveal_step(card)
                        return {
                            message_card = card,
                            message = "+1 Mult"
                        }
                    end
                end
                --PrankD
                if string.find(card.ability.extra.cond,"rank") ~= nil then
                    if context.other_card:get_id() == card.ability.extra.condvar then
                        card.ability.extra.mult = card.ability.extra.mult + 1
                        consp_reveal_step(card)
                        return {
                            message_card = card,
                            message = "+1 Mult"
                        }
                    end
                end
            end

        end

        --counting scored conditons
        if string.find(card.ability.extra.cond,"C") ~= nil and string.find(card.ability.extra.cond,"S") ~= nil then
            if context.before then
                --CsuitS
                if string.find(card.ability.extra.cond,"suit") ~= nil then
                    local suits_seen = 0
                    local suit_log = {}
                    for a,b in pairs(context.scoring_hand) do
                        if b:is_suit("Hearts") then
                            suit_log["H"] = 1
                        end
                        if b:is_suit("Diamonds") then
                            suit_log["D"] = 1
                        end
                        if b:is_suit("Spades") then
                            suit_log["S"] = 1
                        end
                        if b:is_suit("Clubs") then
                            suit_log["C"] = 1
                        end
                    end
                    suits_seen = (suit_log["H"] or 0) + (suit_log["D"] or 0) + (suit_log["S"] or 0) + (suit_log["C"] or 0)
                    if suits_seen > 0 then
                        card.ability.extra.mult = card.ability.extra.mult + suits_seen
                        consp_reveal_step(card)
                        return {
                            message_card = card,
                            message = "+"..tostring(suits_seen).." Mult"
                        }
                    end
                end

                --CrankS
                if string.find(card.ability.extra.cond,"rank") ~= nil then
                    local count_ranks = 0
                    local rank_log = {}
                    for a,b in pairs(context.scoring_hand) do
                        if rank_log[tostring(b:get_id())] == nil then
                            rank_log[tostring(b:get_id())] = 1
                            count_ranks = count_ranks + 1
                        end
                    end

                    if count_ranks > 0 then
                        card.ability.extra.mult = card.ability.extra.mult + count_ranks
                        consp_reveal_step(card)
                        return {
                            message_card = card,
                            message = "+"..tostring(count_ranks).." Mult"
                        }
                    end

                end
            end
        
        end

        if string.find(card.ability.extra.cond,"C") ~= nil and string.find(card.ability.extra.cond,"D") ~= nil then
            -- discard stuff 
            if context.discard and context.other_card == G.hand.highlighted[1] then
                
                --CsuitD
                if string.find(card.ability.extra.cond,"suit") ~= nil then
                    local suits_seen = 0
                    local suit_log = {}
                    for a,b in pairs(G.hand.highlighted) do
                        if b:is_suit("Hearts") then
                            suit_log["H"] = 1
                        end
                        if b:is_suit("Diamonds") then
                            suit_log["D"] = 1
                        end
                        if b:is_suit("Spades") then
                            suit_log["S"] = 1
                        end
                        if b:is_suit("Clubs") then
                            suit_log["C"] = 1
                        end
                    end
                    suits_seen = (suit_log["H"] or 0) + (suit_log["D"] or 0) + (suit_log["S"] or 0) + (suit_log["C"] or 0)
                    if suits_seen > 0 then
                        card.ability.extra.mult = card.ability.extra.mult + suits_seen
                        consp_reveal_step(card)
                        return {
                            message_card = card,
                            message = "+"..tostring(suits_seen).." Mult"
                        }
                    end
                end

                --CrankD
                if string.find(card.ability.extra.cond,"rank") ~= nil then
                    local count_ranks = 0
                    local rank_log = {}
                    for a,b in pairs(G.hand.highlighted) do
                        if rank_log[tostring(b:get_id())] == nil then
                            rank_log[tostring(b:get_id())] = 1
                            count_ranks = count_ranks + 1
                        end
                    end

                    if count_ranks > 0 then
                        card.ability.extra.mult = card.ability.extra.mult + count_ranks
                        consp_reveal_step(card)
                        return {
                            message_card = card,
                            message = "+"..tostring(count_ranks).." Mult"
                        }
                    end
                end
            end
        end

        --scored hand (or containing)
        if context.before and string.find(card.ability.extra.cond,"hand") ~= nil then
            if string.find(card.ability.extra.cond,"S") ~= nil then
                if next(context.poker_hands[card.ability.extra.condvar]) then
                    card.ability.extra.mult = card.ability.extra.mult + 5
                    consp_reveal_step(card)
                    return {
                        message_card = card,
                        message = "+5 Mult"
                    }
                end
            end
        end

        --special conditions:
        --unscored
        if context.before and string.find(card.ability.extra.cond,"unscored") ~= nil then
            if (#G.play.cards - #context.scoring_hand) > 0 then
                card.ability.extra.mult = card.ability.extra.mult + (#G.play.cards - #context.scoring_hand)
                consp_reveal_step(card)
                return {
                    message_card = card,
                    message = "+"..tostring(#G.play.cards - #context.scoring_hand).." Mult"
                }
            end
        end
        --sold
        if string.find(card.ability.extra.cond,"sold") ~= nil then
            if context.selling_card then
                card.ability.extra.mult = card.ability.extra.mult + 2
                consp_reveal_step(card)
                return {
                    message = "+2 Mult",
                    message_card = card
                }
            end
        end
        --destroyed
        if string.find(card.ability.extra.cond,"destroyed") ~= nil then
            if context.remove_playing_cards and not context.blueprint then
                local add = 0
                for i=1,#context.removed do
                    add = add + 4
                end
                card.ability.extra.mult = card.ability.extra.mult + add
                consp_reveal_step(card)
                return {
                    message = "+"..tostring(add).." Mult",
                    message_card = card
                }
            end
        end


        -- condition setting
        if (context.using_consumeable or context.end_of_round) and context.cardarea == G.jokers and not context.blueprint then
            if context.using_consumeable or G.GAME.blind.boss then
                local conditons = { -- some are duplicated to adjust rarity, generaly balancing stuff
                    "CsuitS",--count suits scored
                    "CsuitS",
                    "CrankS",--rank ^
                    "CsuitD",--count suits discarded
                    "CsuitD",--
                    "CrankD",--rank ^
                    "PsuitS",--specific suit scored
                    "PrankS",--rank ^
                    "PrankS",
                    "PrankS",
                    "PsuitD",--specific suit discarded
                    "PsuitD",
                    "PrankD",--rank ^
                    "handS",--specific hand scored
                    "unscored",
                    "sold",
                    "destroyed"
                }
                card.ability.extra.cond = pseudorandom_element(conditons,pseudoseed("consp"))
                if string.find(card.ability.extra.cond,"suit") ~= nil then
                    card.ability.extra.condvar = pseudorandom_element({"Hearts","Diamonds","Spades","Clubs"},pseudoseed("consp1"))
                end
                if string.find(card.ability.extra.cond,"rank") ~= nil then
                    card.ability.extra.condvar = pseudorandom_element(get_rank_id_table(),pseudoseed("consp1"))
                end
                if string.find(card.ability.extra.cond,"hand") ~= nil then
                    local poker_hands = {}
                    for k, v in pairs(G.GAME.hands) do
                        if v.visible then
                            poker_hands[#poker_hands + 1] = k
                        end
                    end
                    card.ability.extra.condvar = pseudorandom_element(poker_hands, pseudoseed("consp2"))
                end

                local phrase =  consp_phrase(card)
                card.ability.extra.phrase = phrase
                card.ability.extra.revealed = {}
                for i=1,#phrase do
                    card.ability.extra.revealed[#card.ability.extra.revealed + 1] = false
                end


                return {
                    message = "Cover up!"
                }
            end
        end

	end
}

-- prism
SMODS.Joker {
	key = 'prism',
	loc_txt = {
		name = 'Prism',
		text = {
			"If the {C:attention}first{} played hand contains",
            "only a single {C:attention}wild card{}, {C:red}destroy{} it",
            "and create {C:attention}4{} unenhanced copies of",
            "it in each suit and draw them to hand."
		}
	},
	config = {target={}},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 1, y = 2 },
	cost = 6,
    loc_vars = function(self, info_queue)
        info_queue[#info_queue+1] = G.P_CENTERS["m_wild"]
        return { vars = {} }
    end,
	calculate = function(self, card, context)

        if context.before and G.GAME.current_round.hands_played < 1 and context.scoring_name == "High Card" and #G.play.cards == 1 then
            if SMODS.has_enhancement(G.play.cards[1], "m_wild") and not G.play.cards[1].debuff then
                card.ability.target[#card.ability.target + 1] = G.play.cards[1]

            end
        end

        if context.destroying_card and context.destroying_card.area == G.play then
            if context.destroying_card == (card.ability.target[1] or 0) then
                for _,i in pairs({"Hearts","Diamonds","Spades","Clubs"}) do
                    local copied = copy_card(G.play.cards[1])
                    -- heres where the deck shenanigans happen
                    SMODS.change_base(copied, i)
                    copied:set_ability("c_base")
                    copied:add_to_deck()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    table.insert(G.playing_cards, copied)
                    G.hand:emplace(copied)
                end
                --G.play.cards[1]:start_dissolve()
                local target = card.ability.target[1]
                card.ability.target = {}
                return {
                    message_card = target,
                    message = "Refracted!",
                    colour = G.C.DARK_EDITION,
                    remove = true
                }
            end
        end
	end
}

-- dynamite stick
SMODS.Joker {
	key = 'dynamite',
	loc_txt = {
		name = 'Dynamite',
		text = {
			"{C:red}Destroy{} all cards in hand",
            "when this joker is sold."
		}
	},
	config = { extra = { } },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = false, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 4,
    sell_cost = 0,
	loc_vars = function(self, info_queue, card)
		return {vars = {}}
	end,
	calculate = function(self, card, context)
        if context.selling_self and not context.blueprint and #G.hand.cards > 0 then
            SMODS.destroy_cards(G.hand.cards)
            --for _,i in pairs(G.hand.cards) do
            --    i:start_dissolve()
            --end
        end
	end
}

--feature wall
SMODS.Joker {
	key = 'feature_wall',
	loc_txt = {
		name = 'Feature Wall',
		text = {
            "Gains {X:mult,C:white}X#2#{} if the scored hand contains",
            "{C:attention}atleast 3{} cards of {C:attention}one suit{} and",
            "{C:attention}atmost{} {C:attention}1{} card of any {C:attention}other suit{}.",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{} {C:mult}Mult{}{C:inactive}.)"
		}
	},
	config = {x_mult = 1.0,x_mult_gain=0.25},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true,
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.x_mult,
            card.ability.x_mult_gain
        }}
    end,
	calculate = function(self, card, context)

        if context.joker_main then
            return {xmult = card.ability.x_mult}
        end

        if context.before and not context.blueprint then
            local suit_log = {}
            local three = {}
            for a,b in pairs(context.scoring_hand) do
                if b:is_suit("Hearts") then
                    suit_log["H"] = (suit_log["H"] or 0) + 1
                    three["H"] = false
                end
                if b:is_suit("Diamonds") then
                    suit_log["D"] = (suit_log["D"] or 0) + 1
                    three["D"] = false
                end
                if b:is_suit("Spades") then
                    suit_log["S"] = (suit_log["S"] or 0) + 1
                    three["S"] = false
                end
                if b:is_suit("Clubs") then
                    suit_log["C"] = (suit_log["C"] or 0) + 1
                    three["C"] = false
                end
            end
            for a,b in pairs(suit_log) do
                if b >= 3 then three[a] = true end
            end
            local three_found = false
            local one_found = false
            local override_one = false
            for a,b in pairs(suit_log) do
                if three[a] then
                    three_found = true
                end
                if three[a] == false and b == 1 then
                    one_found = true
                end
            end
            
            if one_found and three_found then
                
                card.ability.x_mult = card.ability.x_mult + card.ability.x_mult_gain
                return {
                    card = card,
                    message = "Upgraded!"
                }
            end
        end


	end
}

--trail mix
SMODS.Joker {
	key = 'trail_mix',
	loc_txt = {
		name = 'Trail Mix',
		text = {
			"Add a random {C:attention}seal{}, {C:attention}enhancement{}",
            "or {C:attention}edition{} to a random card",
            "in hand before every hand played.",
            "{C:inactive}({C:attention}#1#{} {C:inactive}remaining.)"
		}
	},
	config = { extra = {remaining = 10} },
    unlocked = true, 
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true,
	eternal_compat = false, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
    sell_cost = 0,
	loc_vars = function(self, info_queue, card)
		return {vars = {card.ability.extra.remaining}}
	end,
	calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local target = pseudorandom_element(G.hand.cards, pseudoseed("trailmixA"))
            local failed_targets = {}
            local found_target = false
            local found_choice = false
            local choices = {"En","Se","Ed"}
            local i = 0
            local choice = "empty"

            while #choices > 0 and found_choice == false do
                
                choice = pseudorandom_element(choices, pseudoseed("trailmixB"))
                failed_targets = {}
                
                if choice == "En" then

                    local all_enh = false
                    local en_count = 0
                    for _,i in pairs(G.hand.cards) do
                        local has_en = false
                        for b=1, #G.P_CENTER_POOLS.Enhanced do
                            if SMODS.has_enhancement(i,tostring(G.P_CENTER_POOLS.Enhanced[b].key)) then has_en = true end
                        end
                        if has_en then
                            en_count =en_count + 1
                        end
                    end
                    if en_count >= #G.hand.cards then
                        all_enh = true
                    end


                    if all_enh then
                        choices[indexOf(choices,"En")] = nil
                    else
                        local eni = indexOf(G.hand.cards,pseudorandom_element(G.hand.cards, pseudoseed("trailmixA"..tostring(i))))
                        while #failed_targets < #G.hand.cards and found_target == false do
                            
                            eni = eni + 1
                            if eni > #G.hand.cards then
                                eni = 1
                            end
                            target = G.hand.cards[eni]

                            local allow = true
                            for b=1, #G.P_CENTER_POOLS.Enhanced do
                                if SMODS.has_enhancement(target,tostring(G.P_CENTER_POOLS.Enhanced[b].key)) then allow = false end
                            end

                            if allow then
                                found_target = true
                            else
                                i = i + 1
                                if indexOf(failed_targets,target) == nil then
                                    failed_targets[#failed_targets] = target
                                end
                            end
                        end
                        
                        if #failed_targets >= #G.hand.cards then
                            choices[indexOf(choices,"En")] = nil
                        else
                            found_choice = true
                        end
                    end
                end

                if choice == "Ed" then

                    local all_ed = false
                    local ed_count = 0
                    for _,i in pairs(G.hand.cards) do
                        if i.edition ~= nil then
                            ed_count = ed_count + 1
                        end
                    end
                    if ed_count >= #G.hand.cards then
                        all_ed = true
                    end

                    if all_ed then
                        choices[indexOf(choices,"Ed")] = nil
                    else
                        while #failed_targets < #G.hand.cards and found_target == false do
                            target = pseudorandom_element(G.hand.cards, pseudoseed("trailmixA"..tostring(i)))
                            if target.edition == nil then
                                found_target = true
                            else
                                i = i + 1
                                if indexOf(failed_targets,target) == nil then
                                    failed_targets[#failed_targets] = target
                                end
                            end
                        end
                        if #failed_targets >= #G.hand.cards then
                            choices[indexOf(choices,"Ed")] = nil
                        else
                            found_choice = true
                        end
                    end
                end

                if choice == "Se" then


                    local all_se = false
                    local se_count = 0
                    for _,i in pairs(G.hand.cards) do
                        if i.seal then
                            se_count = se_count + 1
                        end
                    end
                    if se_count >= #G.hand.cards then
                        all_se = true
                    end

                    if all_se then
                        choices[indexOf(choices,"Se")] = nil
                    else
                        while #failed_targets < #G.hand.cards and found_target == false do
                            target = pseudorandom_element(G.hand.cards, pseudoseed("trailmixA"..tostring(i)))
                            if target.seal == nil then
                                found_target = true
                            else
                                i = i + 1
                                if indexOf(failed_targets,target) == nil then
                                    failed_targets[#failed_targets] = target
                                end
                            end
                        end
                        if #failed_targets >= #G.hand.cards then
                            choices[indexOf(choices,"Se")] = nil
                        else
                            found_choice = true
                        end
                    end
                end

            end

            if found_choice then
                if choice == "En" then
                    target:set_ability(pseudorandom_element(G.P_CENTER_POOLS.Enhanced,pseudoseed(tostring(i))).key)
                    target:juice_up(0.3, 0.5)
                end
                if choice == "Ed" then
                    local editi = pseudorandom_element(G.P_CENTER_POOLS.Edition,pseudoseed(tostring(i))).key
                    while editi == "e_base" do 
                        editi = pseudorandom_element(G.P_CENTER_POOLS.Edition,pseudoseed(tostring(i))).key
                        i = i + 1
                    end
                    if editi == "e_negative" then
                        if not negative_less_likely() then
                            editi = pseudorandom_element(G.P_CENTER_POOLS.Edition,pseudoseed("jokerahlagh")).key
                        end
                    end
                    target:set_edition(editi, true)
                    target:juice_up(0.3, 0.5)
                end
                if choice == "Se" then
                    target:set_seal(pseudorandom_element(G.P_CENTER_POOLS.Seal,pseudoseed(tostring(i))).key, true)
                    target:juice_up(0.3, 0.5)
                end
                card.ability.extra.remaining = card.ability.extra.remaining - 1
                if card.ability.extra.remaining <= 0 then
                    card:start_dissolve()
                    G.jokers:remove_card(card)
                    return {
                        card = target,
                        message = "Empty!"
                    }
                else
                    card:juice_up(0.3, 0.5)
                    return {
                        card = target,
                        message = tostring(card.ability.extra.remaining).." Left!"
                    }
                end
            else
                return {
                    card = card,
                    message = "Huh? None valid??"
                }
            end


        end
	end
}

-- stacked deck
SMODS.Joker {
	key = 'stacked_deck',
	loc_txt = {
		name = 'Stacked Deck',
		text = {
            "When a {C:attention}ranked{} card is scored,",
            "{C:mult}+#1# Mult{} for every copy of that",
            "{C:attention}rank{} in your {C:attention}full deck{}."
		}
	},
	config = {mult_per_dupe = 1},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true,
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 8,
	loc_vars = function(self, info_queue, card)
		return { vars = {card.ability.mult_per_dupe}}
	end,
	calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local value = 0
            for _, v in pairs(G.playing_cards) do
                if v:get_id() == context.other_card:get_id() then
                    value = value + 1
                end
            end
            return {
                mult = card.ability.mult_per_dupe * value
            }
        end
    end
}

-- zip bomb
SMODS.Joker {
    	key = 'zip_bomb',
	loc_txt = {
		name = 'Zip Bomb',
		text = {
            "Create {C:attention}#1#{} random {C:attention}enhanced{} cards",
            "with either an {C:dark_edition}edition{} or {C:attention}seal",
            "and add them to the deck when this",
			"joker is {C:red}destroyed{}. {C:inactive}(Not sold)",
        }
	},
	config = { amount=20,will_create=true },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = false, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
    sell_cost = 0,
	loc_vars = function(self, info_queue, card)
		return {vars = {card.ability.amount,card.ability.will_create}}
	end,
	calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            card.ability.will_create = false
        end
	end,
    remove_from_deck = function(self, card, from_debuff)
        local created = card.ability.will_create
        if card.ability.will_create then
            for i = 1, card.ability.amount do
                local r = pseudorandom_element(get_rank_table(),pseudoseed("stoners"))
                local s = pseudorandom_element(get_suit_table(),pseudoseed("stoners"))
                local new_card = create_playing_card({
                    --front = G.P_CARDS.S_A, 
                    no_edition = true,
                    area = nil,
                    --rank = pseudorandom_element(get_rank_table(),pseudoseed("stonerr")),
                    --suit = pseudorandom_element(get_suit_table(),pseudoseed("stoners")),
                    center = G.P_CENTERS.c_base}, G.hand, nil, nil, {G.C.SECONDARY_SET.Enhanced}
                )
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                new_card:set_ability(pseudorandom_element(G.P_CENTER_POOLS.Enhanced,pseudoseed(tostring("glitch_404"))).key)
                SMODS.change_base(new_card, s, r)
                rand_seals = G.P_CENTER_POOLS.Seal
                rand_editi = G.P_CENTER_POOLS.Edition
                --remove base & negative edition from pool
                rand_editi[1] = nil
                rand_editi[5] = nil
                if pseudorandom_element({true,false},pseudoseed("coinflip")) then
                    new_card:set_edition(pseudorandom_element(rand_editi,pseudoseed("stoner_add")).key, true)
                else
                    new_card:set_seal(pseudorandom_element(rand_seals,pseudoseed("stoner_add")).key, nil, true)
                end
                draw_card(G.hand,G.deck, 0.5,'down', nil, new_card, 0.07)

            end
        end

        card.ability.will_create = true
        if created then
            return {
                card = card,
                message = "Unzipped!"
            }
        end
    end
}

-- House Dragonmaid
SMODS.Joker {
	key = 'house_dragonmaid',
	loc_txt = {
		name = 'House Dragonmaid',
		text = {
            "{C:attention}Transforms{} into {C:purple,E:2}Dragonmaid Sheou{}",
            "after playing {C:attention}#3#{} {C:attention}Full Houses{} that",
            "contain atleast one {C:attention}#1#{}.",
            "{C:inactive}(Rank changes every round)",
            "{C:inactive}({C:attention}#2#{C:inactive} remaining.)"
		}
	},
	config = {rank= "Ace" ,remaining = 2,total = 2 },
    unlocked = true,
    discovered = true, 
    blueprint_compat = true,
    perishable_compat = true, 
    eternal_compat = true,
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 5 },
	cost = 6,
    in_pool = function(self, args)
        return not next(SMODS.find_card("j_onio_dragonmaid_sheou"))
    end,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["j_onio_dragonmaid_sheou"]
		return { vars = { card.ability.rank, card.ability.remaining, card.ability.total } }
	end,
	calculate = function(self, card, context)
        
        if context.setting_blind and not context.blueprint then

            valid_ranks = {}
            for i = #G.playing_cards, 1, -1 do
                if indexOf(valid_ranks,G.playing_cards[i]:get_id()) == nil then
                    valid_ranks[#valid_ranks+1] = G.playing_cards[i]:get_id()
                end
            end
            local a = pseudorandom_element(valid_ranks,pseudoseed("dragonhouserank"))
            
            card.ability.rank = get_rank_table()[a-1]

            return {
                card = card,
                message = "Randomized!"
            }
        end

        if context.before then
            if next(context.poker_hands['Full House']) or indexOf(
                {"onio_straight_five",
                "onio_straight_flush_five",
                "onio_straight_house",
                "onio_straight_flush_house"},context.scoring_name) ~= nil then
                local valid = false
                for _, v in pairs(context.scoring_hand) do
                    if get_rank_table()[v:get_id()-1] == card.ability.rank then valid = true end
                end
                if valid then
                    card.ability.remaining = card.ability.remaining - 1

                    if card.ability.remaining == 0 then
                        card:start_dissolve()
                        local edi = nil
                        local stick = {}
                        if card.edition then
                            edi = card.edition
                        end
                        if card.ability.eternal then stick[#stick+1] = "eternal" end
                        if card.ability.perishable then stick[#stick+1] = "perishable" end
                        if card.ability.rental then stick[#stick+1] = "rental" end
                        local new_joker = SMODS.add_card({set = 'Joker', stickers = stick, no_edition = (edi == nil) , edition = edi or nil, key = "j_onio_dragonmaid_sheou" })
                    else
                        return {
                            card = card,
                            message = tostring(card.ability.total - card.ability.remaining).."/"..tostring(card.ability.total),
                            colour = G.C.PURPLE
                        }
                    end
                end
            end

		end

	end
}

-- Dragonmaid Sheou
SMODS.Joker {
	key = 'dragonmaid_sheou',
	loc_txt = {
		name = 'Dragonmaid Sheou',
		text = {
            "{C:attention{}Disables{} the effects of the boss blind.",
            "{C:attention}Transforms{} back into {C:attention,E:2}House Dragonmaid{}",
            "when boss blind is defeated.",
            "Creates {C:attention}2{} {C:rare}Rare Tags{} when sold",
		}
	},
	config = {},
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    perishable_compat = false, 
    eternal_compat = true,
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 5 },
	cost = 7,
    in_pool = function(self, args)
        return false
    end,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTER_POOLS.Tag[2]
		return { vars = {} }
	end,
	calculate = function(self, card, context)
        
        if (context.before or context.setting_blind) and not context.blueprint then
            if G.GAME.blind and not G.GAME.blind.disabled and G.GAME.blind.boss then
                return {
                    message = localize('ph_boss_disabled'),
                    func = function() -- This is for timing purposes, it runs after the message
                        G.GAME.blind:disable()
                    end
                }
            end
        end

        if context.end_of_round and context.cardarea == G.jokers and not context.blueprint and G.GAME.blind.boss then
            card:start_dissolve()
            local edi = nil
            local stick = {}
            if card.edition then
                edi = card.edition
            end
            if card.ability.eternal then stick[#stick+1] = "eternal" end
            if card.ability.perishable then stick[#stick+1] = "perishable" end
            if card.ability.rental then stick[#stick+1] = "rental" end
            local new_joker = SMODS.add_card({set = 'Joker',stickers = stick, no_edition = (edi == nil) ,edition = edi, key = "j_onio_house_dragonmaid" })
        end

        if context.selling_self and not context.blueprint then
            add_tag(Tag('tag_rare'))
            add_tag(Tag('tag_rare'))
        end

	end
}

--corrupted joker funcs
function get_random_char()
    return pseudorandom_element({
            "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
            "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
            "U", "V", "W", "X", "Y", "Z",
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
            "#","@", "#", "$", "%", "^", "&", "*", "<", ")",
            "#","@", "#", "$", "%", "^", "&", "*", "<", ")",
            "#","@", "#", "$", "%", "^", "&", "*", "<", ")",
            "#","@", "#", "$", "%", "^", "&", "*", "<", ")",
            "#","@", "#", "$", "%", "^", "&", "*", "<", ")",
            "#","@", "#", "$", "%", "^", "&", "*", "<", ")",
        },pseudoseed("randchar"))
end

function rcs(num)
    str = ""
    for i=1,num do
        str = str..get_random_char()
    end
    return str
end

function random_string_object(str,txt_colour)
    return {
        n = G.UIT.O,
        config = {
            object = DynaText({
                string = {
                    { string = str,colour = txt_colour },
                    { string = str,colour = txt_colour },
                    { string = str,colour = txt_colour },
                    { string = str,colour = txt_colour },
                    { string = str,colour = txt_colour },
                    rcs(string.len(str)),rcs(string.len(str)),
                    rcs(string.len(str)),rcs(string.len(str)),
                    rcs(string.len(str)),rcs(string.len(str)),
                    rcs(string.len(str)),rcs(string.len(str)),
                },
                colours = { G.C.UI.TEXT_INACTIVE },
                pop_in_rate = 9999999,
                silent = true,
                random_element = true,
                pop_delay = 0.125,
                padding=0,
                scale = 0.4,
                min_cycle_time = 0
            })
        }
    }
end

function random_string_dict_object(str_dict,rand_len,txt_colour,text_mul)
    local dict = {}
    for _,i in pairs(str_dict) do
        dict[#dict+1] = { string = i,colour = txt_colour }
    end
    for i=1,#str_dict do
        dict[#dict+1] = rcs(rand_len)
    end
    return {
        n = G.UIT.O,
        config = {
            object = DynaText({
                string = dict,
                colours = { G.C.UI.TEXT_INACTIVE },
                pop_in_rate = 9999999,
                silent = true,
                random_element = true,
                pop_delay = 0.03*(10*(text_mul or 0.1)),
                padding=0,
                scale = 0.4,
                min_cycle_time = 0
            })
        }
    }
end

function random_char_object(len)
    return {
        n = G.UIT.O,
        config = {
            object = DynaText({
                string = {
                    rcs(len),rcs(len),rcs(len),rcs(len),rcs(len),rcs(len),
                    rcs(len),rcs(len),rcs(len),rcs(len),rcs(len),rcs(len),
                },
                colours = { G.C.UI.TEXT_INACTIVE },
                pop_in_rate = 9999999,
                silent = true,
                random_element = true,
                pop_delay = 0.03,
                padding=0,
                scale = 0.4,
                min_cycle_time = 0
            })
        }
    }
end

-- Courrupted Joker
SMODS.Joker {
	key = 'corrupted_joker',
	loc_txt = {
		name = 'Corrupted Joker',
		text = {
			""
		}
	},
	config = { seconds = 0  },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 1, y = 3 },
	cost = 6,
    in_pool = function(self, args)
        local allow = false
        if G.deck then
            for i = 1, #G.deck.cards do
                if G.deck.cards[i].seal then
                    if G.deck.cards[i].seal == "onio_glitch_seal" then
                        allow = true
                    end
                end
            end
            return allow
        else return true end
    end,
    update = function(self, card, dt)
        if G.deck then
            local count = 0
            for i = 1, #G.deck.cards do
                if G.deck.cards[i].seal ~= nil then
                    if G.deck.cards[i].seal == "onio_glitch_seal" then count = count + 1 end
                end
            end
            local rate = 0.75 + (0.5 * (count / 52))
            card.ability.seconds = card.ability.seconds + rate
            local a = math.sin((0.5 * card.ability.seconds) / (4.0 * math.pi))
            a = math.pow(math.abs(a),25)
            local offset = 0.725 * (count / 52)
            a = math.min(5,1 + math.floor(offset + (4.25 * a)))
            --print(tostring(card.ability.seconds)..":"..tostring(a))
            card.children.center:set_sprite_pos{ x = a, y = 3 }
        end
    end,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_SEALS["onio_glitch_seal"]
        main_start = {
            random_char_object(2),
            random_string_dict_object({"glitch","seal"},5,G.C.DARK_EDITION,0.5),
            --random_string_object("seal",G.C.DARK_EDITION),
            random_char_object(2),
            random_string_object("discard",G.C.FILTER),
            random_char_object(1),
            random_string_dict_object({"rank","suit","edition","ehncent"},6,G.C.FILTER,0.5),
            random_char_object(3)
        }
        return {
            main_start = main_start,
            vars = {card.ability.seconds}
        }
	end,
	calculate = function(self, card, context)

        --make glitch seals more common in packs lol, force 1 in 3 to add em
        if context.open_booster then
            if G.pack_cards and context.card.ability.name:find('Standard') ~= nil then

                G.E_MANAGER:add_event(Event({
                func = function()
                    if G.pack_cards and G.pack_cards.cards and G.pack_cards.cards[1] and G.pack_cards.VT.y < G.ROOM.T.h then
                        for _, v in ipairs(G.pack_cards.cards) do
                            if not v.seal and pseudorandom('corrupted') < 1/3 then
                                v:set_seal("onio_glitch_seal", nil, true)
                                v:juice_up(0.3, 0.5)
                            end
                        end
                        return true
                    end
                end
                }))
            end


        end

        if context.discard and context.other_card.seal ~= nil then
            if context.other_card.seal == "onio_glitch_seal" and not context.other_card.debuff then
                local randrank = pseudorandom_element(get_rank_table(),pseudoseed("time"..tostring(i)))
                local randsuit = pseudorandom_element(get_suit_table(),pseudoseed("time"..tostring(i)))
                local editi = pseudorandom_element(G.P_CENTER_POOLS.Edition,pseudoseed("gseal")).key
                local i = "1"
                while editi == "e_base" do 
                    editi = pseudorandom_element(G.P_CENTER_POOLS.Edition,pseudoseed(i)).key
                    i = i + "1"
                end
                assert(SMODS.change_base(context.other_card, randsuit, randrank))
                SMODS.change_base(context.other_card, randsuit, randrank)
                context.other_card:set_ability(pseudorandom_element(G.P_CENTER_POOLS.Enhanced,pseudoseed(tostring("glitch_404"))).key)
                context.other_card:set_edition(editi, true)
                context.other_card:juice_up(0.3, 0.5)
                col = pseudorandom_element({G.C.DARK_EDITION,G.C.DARK_EDITION,G.C.DARK_EDITION,G.C.PURPLE,G.C.BLACK},pseudoseed("time"..tostring(i)))
                return {
                    card = context.other_card,
                    message = rcs(9).."!",
                    colour = col
                }
			end
        end
	end
}

-- sunglasses
SMODS.Joker {
	key = 'sunglasses',
	loc_txt = {
		name = 'Sunglasses',
		text = {
            "{C:green}#1# in #2#{} chance to make a",
			"card in hand {C:dark_edition}negative{} when",
            "the score is set on {E:1,C:red}fire{}"
		}
	},
	config = {
        extra = {chance=1,odds = 2},
    },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 7, y = 2 },
	cost = 8,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["e_negative"]
		return { vars = { 
            (card.ability.extra.chance * G.GAME.probabilities.normal) or G.GAME.probabilities.normal,
            card.ability.extra.odds,
            }
        }
	end,
	calculate = function(self, card, context)
        if context.final_scoring_step and (hand_chips * mult) > G.GAME.blind.chips and pseudorandom('sung') < ((card.ability.extra.chance * G.GAME.probabilities.normal) / card.ability.extra.odds) then
            
            local all_ed = false 
            local ed_count = 0
            for _,i in pairs(G.hand.cards) do
                if i.edition ~= nil then
                    ed_count = ed_count + 1
                end
            end
            if ed_count >= #G.hand.cards then
                all_ed = true
            end

            if not all_ed then

                local valid_cards = {}
                for _,i in pairs(G.hand.cards) do
                    if i.edition == nil then valid_cards[#valid_cards+1] = i end
                end

                target = pseudorandom_element(valid_cards, pseudoseed("trailmixA"..tostring(i)))

                target:set_edition("e_negative", true)
                target:juice_up()
                card:juice_up()
                return {
                    message_card = target,
                    message = "Shaded!",
                    colour = G.C.DARK_EDITION
                }
            end
		end
	end
}

-- minimalist 
SMODS.Joker {
    key = 'minimalist',
	loc_txt = {
		name = 'Minimalist',
		text = {
			"retrigger all scored cards",
            "{C:attention}1{} additional times",
            "if the played hand contains",
            "{C:attention}3 or less{} scoring cards."
		}
	},
	config = {
        extra = {},
    },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 6, y = 3 },
	cost = 5,
    config = { extra = { repetitions = 1 } },
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and #context.scoring_hand <= 3 then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
    end,
}

-- haunted house
SMODS.Joker {
	key = 'haunted_house',
	loc_txt = {
		name = 'Haunted House',
		text = {
			"Make a random scoring card {E:1,C:inactive}Ethereal{}",
            "if the first played hand of the",
            "round contains a {C:attention}Full House{}."
		}
	},
	config = {
        extra = {},
    },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 7, y = 3 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_onio_ethereal"]
		return { vars = { } }
	end,
	calculate = function(self, card, context)
        if G.GAME.current_round.hands_played < 1 and context.before and  (next(context.poker_hands['Full House']) or indexOf(
                {"onio_straight_five",
                "onio_straight_flush_five",
                "onio_straight_house",
                "onio_straight_flush_house"},context.scoring_name) ~= nil) then

            local all_enh = false
            local en_count = 0
            for _,i in pairs(context.scoring_hand) do
                local has_en = false
                for b=1, #G.P_CENTER_POOLS.Enhanced do
                    if SMODS.has_enhancement(i,tostring(G.P_CENTER_POOLS.Enhanced[b].key)) then has_en = true end
                end
                if has_en then
                    en_count =en_count + 1
                end
            end
            if en_count >= #context.scoring_hand then
                all_enh = true
            end

            if not all_enh then
                local target = pseudorandom_element(context.scoring_hand,pseudoseed("haunt"))
                local valid = false
                while valid == false do
                    local has_en = false
                    local i = 0
                    for b=1, #G.P_CENTER_POOLS.Enhanced do
                        if SMODS.has_enhancement(target,tostring(G.P_CENTER_POOLS.Enhanced[b].key)) then
                            has_en = true
                        end
                    end
                    if has_en == false then valid = true else 
                        i = i + 1
                         target = pseudorandom_element(context.scoring_hand,pseudoseed("haunt"..tostring(i)))
                    end
                end

                target:set_ability("m_onio_ethereal")
                return {
                    message_card = target,
                    message = "Haunted!"
                }
            end
		end
	end
}

-- golden retriver
SMODS.Joker {
    key = 'gold_retrev',
	loc_txt = {
		name = 'Golden Retriver',
		text = {
			"{C:gold}Gold{} cards & cards with {C:gold}gold{} seals",
            "are drawn frist when entering a blind"
		}
	},
	config = {
        extra = {},
    },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_gold"]
        info_queue[#info_queue+1] = G.P_SEALS["Gold"]
		return { vars = { } }
	end,
    calculate = function(self, card, context)
        if context.setting_blind then
            local valid_cards = {}
            for i = 1, #G.deck.cards do
                if G.deck.cards[i].seal ~= nil then
                    if G.deck.cards[i].seal == "Gold" then valid_cards[#valid_cards+1] = G.deck.cards[i] end
                end
                if indexOf(valid_cards,G.deck.cards[i]) == nil then
                    if SMODS.has_enhancement(G.deck.cards[i], "m_gold") then valid_cards[#valid_cards+1] = G.deck.cards[i] end
                end
            end

            for i = 1, math.min(G.hand.config.card_limit,#valid_cards) do
                draw_card(G.deck,G.hand, 0.5,'up', nil, valid_cards[i], 0.07)
            end
        end
    end,
}

-- insurance contract
SMODS.Joker {
	key = 'insurance',
	loc_txt = {
		name = 'Insurance Contract',
		text = {
			"Create {C:attention}#1#{} {V:1}#3#{} Jokers when this joker",
            "is {C:money}sold{}, rarity {C:attention}increases{} and amount",
            "is {C:attention}halved{} when {C:attention}boss blind{} is defeated.",
            "{C:inactive}(Cannot make {E:1,C:legendary}Legendary{}{C:inactive} Jokers.)",
            "{C:inactive}(Must have room)"
		}
	},
	config = { amount=4,rarity=1,rarity_label="Common",colours={G.C.RARITY.Common} },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = false, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
    sell_cost = 0,
    update = function(self, card, dt)
        card.ability.colours = {G.C.RARITY.Common}
        card.ability.rarity_label = "Common"
        if card.ability.rarity == 2 then
            card.ability.colours = {G.C.RARITY.Uncommon}
            card.ability.rarity_label = "Uncommon"
        end
        if card.ability.rarity == 3 then
            card.ability.colours = {G.C.RARITY.Rare}
            card.ability.rarity_label = "Rare"
        end
    end,
	loc_vars = function(self, info_queue, card)
		return {vars = {
            card.ability.amount,
            card.ability.rarity,
            card.ability.rarity_label,
            colours = card.ability.colours
        }}
	end,
	calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            local h = -1
            for i=1,card.ability.amount do
                if #G.jokers.cards + h - 1 < G.jokers.config.card_limit then
                    local rar = 0.7
                    if card.ability.rarity == 2 then
                        rar = 0.85
                    end
                    if card.ability.rarity == 3 then
                        rar = 1
                    end
                    local new_joker = SMODS.add_card({set = 'Joker', rarity = rar })
                    h = h + 1
                end
            end
        end

        if context.end_of_round and context.cardarea == G.jokers and not context.blueprint and G.GAME.blind.boss then
            card.ability.amount = math.floor(card.ability.amount / 2)
            card.ability.rarity = card.ability.rarity + 1
            if card.ability.rarity ~= 4 then
                return {
                    card = card,
                    message = "Altered!",
                    colour = G.C.RARITY[card.ability.rarity]--card.ability.colours[1]
                }
            else
                card:start_dissolve()
                G.jokers:remove_card(card)
                return {
                    card = card,
                    message = "Eaten!",
                    colour = G.C.RARITY.Legendary
                }
            end
        end
	end
}

--DLC
SMODS.Joker {
	key = 'deelc',
	loc_txt = {
		name = 'DLC',
		text = {
			"If the first played hand contains",
            "atleast {C:attention}3{} scoring {C:attention}Aces{} lose",
            "{C:red}-$#1#{} and create {C:attention}3{} random",
            "{C:attention}'Booster Pack' Tags{}."
            --"{C:attention}Standard Tag{},{C:attention}Buffoon Tag{},{C:spectral}Ethereal Tag{},",
            --"{C:planet}Meteor Tag{},{C:tarot}Charm Tag{}.",
		}
	},
	config = {extra = {cost=8}},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 5,
    loc_vars = function(self, info_queue, card)
        --print(get_keys(G.P_TAGS))
        --info_queue[#info_queue+1] = G.P_TAGS["tag_standard"]
        --info_queue[#info_queue+1] = G.P_TAGS["tag_buffoon"]
        --info_queue[#info_queue+1] = G.P_TAGS["tag_ethereal"]
        --info_queue[#info_queue+1] = G.P_TAGS["tag_meteor"]
        --info_queue[#info_queue+1] = G.P_TAGS["tag_charm"]
        return { vars = {card.ability.extra.cost} }
    end,
	calculate = function(self, card, context)

         if G.GAME.current_round.hands_played < 1 and context.before then
            local ace_count = 0
            for i=1,#G.play.cards do
                if G.play.cards[i]:get_id() == 14 and not G.play.cards[1].debuff then
                    ace_count = ace_count + 1
                end
            end

            if ace_count >= 3 then
                local tag_list = {
                    "tag_standard",
                    "tag_standard",
                    "tag_buffoon",
                    "tag_ethereal",
                    "tag_meteor",
                    "tag_meteor",
                    "tag_charm",
                    "tag_charm"
                }
                G.E_MANAGER:add_event(Event({
                    func = function()
                        add_tag(Tag(pseudorandom_element(tag_list,pseudoseed("tag1"))))
                        add_tag(Tag(pseudorandom_element(tag_list,pseudoseed("tag2"))))
                        add_tag(Tag(pseudorandom_element(tag_list,pseudoseed("tag3"))))
                        play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                        return true
                    end
                }))
                return {
                    message = "Purchased!",
                    dollars = -1 * card.ability.extra.cost
                }
            end
        end
	end
}

--quickdraw
SMODS.Joker {
	key = 'quickdraw',
	loc_txt = {
		name = 'Quickdraw',
		text = {
			"{X:mult,C:white}X#1#{} {C:mult}Mult{} on the first played hand",
            "per blind if {C:red}no discards{} are used."
		}
	},
	config = {
        extra = { mult_mult = 3},
    },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult_mult } }
	end,
	calculate = function(self, card, context)
        if context.joker_main and G.GAME.current_round.hands_played < 1 and G.GAME.current_round.discards_left == G.GAME.round_resets.discards then
            return {
                xmult = card.ability.extra.mult_mult
            }
		end
	end
}

--apartment
SMODS.Joker {
	key = 'apartment',
	loc_txt = {
		name = 'Apartment',
		text = {
			"If the played hand is a {C:attention}Two Pair",
            "or a {C:attention}Three of a Kind{} it is instead",
            "counted as a {C:attention}Full House{}"
		}
	},
	config = {
        extra = { most_hand = ""},
    },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true,
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
    update = function(self, card, dt)
        card.ability.extra.most_hand = most_played_hand()
    end,
	loc_vars = function(self, info_queue, card) 
		return { vars = { card.ability.extra.most_hand } }
	end,
	calculate = function(self, card, context)

        if context.evaluate_poker_hand then
            if context.display_name == "Two Pair" or context.display_name == "Three of a Kind" then
                local poker_hands = context.poker_hands
                poker_hands["Two Pair"] = context.full_hand
                poker_hands["Three of a Kind"] = context.full_hand
                return {
                    replace_scoring_name = "Full House",
                    replace_display_name = "Full House",
                    replace_poker_hands = poker_hands
                }

            end

        end

	end
}

--hangman
SMODS.Joker {
    key = 'hangman',
    loc_txt = {
        name = 'Hangman',
        text = {
            '{C:attention}Face Cards{} can fill gaps',
            'in {C:attention}Straights{}',
            '{C:inactive}(e.g. {C:attention}9{C:inactive}, {E:1,C:attention}J{C:inactive}, {C:attention}7{C:inactive}, {C:attention}6{C:inactive}, {E:1,C:attention}Q{C:inactive}.)'
        }
    },
    config = {
        extra = {},
    },
    unlocked = true,
	discovered = true, 
    blueprint_compat = false,
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
    calculate = function(self, card, context)
        if context.modify_scoring_hand then
            local _, _, poker_hands = G.FUNCS.get_poker_hand_info(context.full_hand)
            if poker_hands["Straight"] then
                return {
                    add_to_hand = true
                }
            end
        end
    end
}

--wraparound
SMODS.Joker {
    key = 'wraparound',
    loc_txt = {
        name = 'Wraparound',
        text = {
            '{C:attention}Straights{} may continue through {C:attention}Ace{}.',
            '{C:inactive}(e.g. {C:attention}3{C:inactive}, {C:attention}2{C:inactive}, {E:1,C:attention}A{C:inactive}, {C:attention}K{C:inactive}, {C:attention}Q{C:inactive}.)'
        }
    },
    config = {
        extra = {},
    },
    unlocked = true,
	discovered = true, 
    blueprint_compat = false,
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 5,
}

--recipt
SMODS.Joker {
	key = 'recipt',
	loc_txt = {
		name = 'Recipt',
		text = {
			"Gains {C:chips}Chips{} equal to double",
            "the price of cards purchased.",
            "{C:inactive}(Currently {C:chips}+#1# Chips{C:inactive}.)"
		}
	},
	config = { chips = 0 },
    unlocked = true, 
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.chips } }
	end,
	calculate = function(self, card, context)

        if context.joker_main then
			return {
				chips = card.ability.chips,
			}
		end

        if context.buying_card and not context.blueprint then
            card.ability.chips = card.ability.chips + (context.card.cost * 2)
            if true then
                return {
                    message = "Upgraded!",
                    colour = G.C.Chips,
                    card = card
                }
            end
		end
	end
}

--colour blind
SMODS.Joker {
    key = 'c_blind',
    loc_txt = {
        name = 'Colour Blind Joker',
        text = {
            '{C:hearts}Hearts{} and {C:clubs}Clubs{} are',
            'considered the same suit'
        }
    },
    unlocked = true,
	discovered = true,
    blueprint_compat = false,
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 5,
}

--skipping stone
SMODS.Joker {
    key = 'skipping_stone',
    loc_txt = {
        name = 'Skipping Stone',
        text = {
            '{C:attention}Stone Cards{} can fill gaps',
            'in {C:attention}Straights{} and {C:attention}Flushes{}',
            '{C:inactive}(e.g. {C:attention}9{C:inactive}, {E:1,C:attention}S{C:inactive}, {C:attention}7{C:inactive}, {C:attention}6{C:inactive}, {E:1,C:attention}S{C:inactive}.)'
        }
    },
    config = {
        extra = {},
    },
    unlocked = true,
	discovered = true, 
    blueprint_compat = false,
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_stone"]
		return { vars = { } }
	end
}

--catalouge
SMODS.Joker {
	key = 'catalouge',
	loc_txt = {
		name = 'Catalouge',
		text = {
            "Gains {C:mult}+#1# Mult{} for every",
            "unique {C:attention}enhancement{}, {C:attention}edition{} and",
            "{C:attention}seal{} in your {C:attention}full deck{}.",
            "{C:inactive}(Currently {C:mult}+#2# Mult{} {C:inactive}.)"
		}
	},
	config = { mult_per = 4, deck_text = 0},
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)

        local enh = {}
        local edi = {}
        local sea = {}
        if G.playing_cards then
            for i = 1, #G.playing_cards do
                for b=1, #G.P_CENTER_POOLS.Enhanced do
                    if SMODS.has_enhancement(G.playing_cards[i],tostring(G.P_CENTER_POOLS.Enhanced[b].key)) then
                        enh[G.P_CENTER_POOLS.Enhanced[b].key] = true
                    end
                end
                if G.playing_cards[i].edition ~= nil then
                    edi[tostring(G.playing_cards[i].edition.key)] = true
                end
                if G.playing_cards[i].seal ~= nil then
                    sea[tostring(G.playing_cards[i].seal)] = true
                end
            end
            local count = #get_keys(enh) + #get_keys(edi) + #get_keys(sea)
            card.ability.deck_text = card.ability.mult_per * count
        end

		return {
            vars = {
                card.ability.mult_per,
                card.ability.deck_text,
            }
        }
	end,
	calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.deck_text
            }
        end

	end
}

--Mr Ant.Tenna
SMODS.Joker {
    key = 'tenna',
    loc_txt = {
        name = 'Mr.Ant Tenna',
        text = {
            'Earn {E:1,C:attention}points{} whenever you do',
            'something {s:1.5,E:1,C:dark_edition}entertaining!{}',
            'When this joker is scored convert {C:attention}#1#{}',
            "of your current {E:1,C:attention}points{} into {X:mult,C:white}XMult{}.",
            "{C:attention}#4# point interest{} after each blind.",
            "{C:attention}+#5# interest{} after each boss.",
            '{C:inactive}(Currently {C:attention}#2# {E:1,C:attention}Points{C:inactive} -> {X:mult,C:white}X#3#{C:mult} Mult{} {C:inactive}.)',
            "#6# & #7#"
        }
    },
    config = {
        extra = {points = 0, conversion = 0.001, interest = -0.05, interest_gain = 0.05,page=1,page_count=2},
    },
    unlocked = true,
	discovered = true, 
    blueprint_compat = true,
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 4,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 20,
    onio_can_activate = function(card)
        return true
    end,
    onio_activate = function(card)
    end,
    loc_vars = function(self, info_queue, card)
		return {
            vars = {
                tostring(card.ability.extra.conversion * 100).."%",
                card.ability.extra.points,
                1.0 + (card.ability.extra.points * card.ability.extra.conversion),
                tostring(card.ability.extra.interest * 100).."%",
                tostring(card.ability.extra.interest_gain * 100).."%",
                card.ability.extra.page,
                card.ability.extra.page_count
            },
            key = "j_onio_tenna_page"..tostring(card.ability.extra.page)
        }
	end,
    calculate = function(self, card, context)

        -- interest
        if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
            card.ability.extra.points = card.ability.extra.points * (1.0 + card.ability.extra.interest)
            if G.GAME.blind.boss then
                card.ability.extra.interest = card.ability.extra.interest + card.ability.extra.interest_gain
                return {
                    card = card,
                    message = "X"..tostring(1.0 + card.ability.extra.interest),
                    extra = {
                        message = "Upgraded!"
                    }
                }
            else
                return {
                    card = card,
                    message = "X"..tostring(1.0 + card.ability.extra.interest)
                }
            end
        end

        if context.main_eval and not context.blueprint then

            local gains = {}

            if context.before then

                --Ten + Ace in hand, Ten-A = Tenna
                local has_10 = false
                local has_a = false
                for _,c in pairs(context.scoring_hand) do
                    if c:get_id() == 10 then has_10 = true end
                    if c:get_id() == 14 then has_a = true end
                end
                if has_10 and has_a then
                    card.ability.extra.points = card.ability.extra.points + 50
                    gains[#gains+1] = {card = card, message = "Ten-A!", colour = G.C.GREEN}
                    gains[#gains+1] = {card = card, message = "+50", colour = G.C.GREEN}
                end

                --fucked up straights
                local cool_hands = {"onio_straight_five","onio_straight_flush_five","onio_straight_house","onio_straight_flush_house"}
                local is_cool = false
                for _,i in pairs(cool_hands) do
                    if next(context.poker_hands[i]) then
                        is_cool = true
                    end
                end
                if is_cool then
                    card.ability.extra.points = card.ability.extra.points + 75
                    gains[#gains+1] = {card = card, message = "How straight?!", colour = G.C.GREEN}
                    gains[#gains+1] = {card = card, message = "+75", colour = G.C.GREEN}
                end

            end

            --score fire
            if context.final_scoring_step and (hand_chips * mult) > G.GAME.blind.chips and context.cardarea == G.jokers then
                    card.ability.extra.points = card.ability.extra.points + 250
                    gains[#gains+1] = {card = card, message = "Score fire!", colour = G.C.GREEN}
                    gains[#gains+1] = {card = card, message = "+250", colour = G.C.GREEN}
                if G.GAME.current_round.hands_played == 0 then
                    card.ability.extra.points = card.ability.extra.points + 500
                    gains[#gains+1] = {card = card, message = "1 tapped!", colour = G.C.GREEN}
                    gains[#gains+1] = {card = card, message = "+500", colour = G.C.GREEN}
                end
            end

            --skipping a blind
            if context.skip_blind then
                card.ability.extra.points = card.ability.extra.points + 100
                gains[#gains+1] = {card = card, message = "Skipped!", colour = G.C.GREEN}
                gains[#gains+1] = {card = card, message = "+100", colour = G.C.GREEN}
            end

            --skipping a pack
            if context.skipping_booster then
                card.ability.extra.points = card.ability.extra.points + 100
                gains[#gains+1] = {card = card, message = "Skipped!", colour = G.C.GREEN}
                gains[#gains+1] = {card = card, message = "+100", colour = G.C.GREEN}
            end

            --selling a rare
            if context.selling_card and context.cardarea == G.jokers then
                if context.card.config.center.rarity == 3 then
                    card.ability.extra.points = card.ability.extra.points + 1000
                    gains[#gains+1] = {card = card, message = "Sold!", colour = G.C.GREEN}
                    gains[#gains+1] = {card = card, message = "+1000", colour = G.C.GREEN}
                end
            end

            --message nesting
            local return_value =  {}
            local last_had_extra = false
            local g = reverse_table_num(gains)
            for _,i in pairs(g) do
                if indexOf(g,i) == 1 then
                    return_value = i
                else
                    local copy = return_value
                    i.extra = copy
                    return_value = i
                end
            end

            if return_value ~= {} then
                return return_value
            end


        end

        -- conversion
        if context.joker_main then
            local converted = card.ability.extra.points * card.ability.extra.conversion
            if not context.blueprint then
                card.ability.extra.points = card.ability.extra.points - converted
            end
			return {
				xmult = 1.0 + converted,
                card = card,
                message = "-"..tostring(card.ability.extra.conversion * 100).."%",
			}
		end


    end
}

--landfill
SMODS.Joker {
	key = 'landfill',
	loc_txt = {
		name = 'Landfilll',
		text = {
            --"{C:attention}+1{} {C:red}discards{} per round",
            "{C:attention}+#1#{} {C:red}discard{} selection limit."
		}
	},
	config = {limit=5},
    unlocked = true,
    discovered = true,
    blueprint_compat = false, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
		return { vars = {card.ability.limit} }
	end,
    add_to_deck = function(self, card, from_debuff)
        --G.GAME.round_resets.discards = G.GAME.round_resets.discards + 1
		SMODS.change_discard_limit(card.ability.limit)
	end,
	remove_from_deck = function(self, card, from_debuff)
        --G.GAME.round_resets.discards = G.GAME.round_resets.discards - 1
		SMODS.change_discard_limit(-1 * card.ability.limit)
	end
}

--skip bin
SMODS.Joker {
	key = 'skip_bin',
	loc_txt = {
		name = 'Skip bin',
		text = {
            "If the {C:attention}first discard{} of the round",
            "hand contains only {C:attention}1{} single {C:green}Skip{} card",
            "convert the {C:attention}leftmost{} card in",
            "hand into a {C:green}Skip{} card"
		}
	},
    enhancement_gate = "m_onio_skip",
	config = {},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_onio_skip"]
        return {vars = {}}
    end,
	calculate = function(self, card, context)

        if context.pre_discard and not context.blueprint then
            if #G.hand.highlighted == 1 and G.GAME.round_resets.discards == G.GAME.current_round.discards_left then
                if SMODS.has_enhancement(G.hand.highlighted[1], "m_onio_skip") then
                    G.hand.cards[1]:juice_up(0.3, 0.5)
                    G.hand.cards[1]:set_ability("m_onio_skip")
                    return {
                        card = G.hand.cards[1],
                        message = "Skip!",
                        colour = G.C.GREEN
                    }
                end
            end
        end


	end
}

--in the fog
SMODS.Joker {
    key = 'in_the_fog',
	loc_txt = {
		name = 'In The Fog',
		text = {
			"Every {C:attention}other{} card drawn when first",
            "entering a blind is drawn {C:attention}face down{}.",
            "Create a {E:1,C:dark_edition}Cryptid{} if the blind is won",
            "in the played {C:attention}first {C:attention}hand{} without",
            "using any {C:attention}discards{}",
            "{C:inactive}(Must have room)"
		}
	},
	config = {
        extra = {},
    },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["c_cryptid"]
		return { vars = { } }
	end,
    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local alt = false
            for _,i in pairs(G.hand.cards) do
                if alt then
                    i:flip()
                    alt = false
                else
                    alt = true
                end
            end
        end

        if context.end_of_round and context.cardarea == G.jokers and G.GAME.current_round.hands_played <= 1 and G.GAME.current_round.discards_left == G.GAME.round_resets.discards then
            if #G.consumeables.cards < G.consumeables.config.card_limit then
                local new_card2 = SMODS.add_card({set = "Spectral",key="c_cryptid" })
                card:juice_up(0.3, 0.5)
            end
        end
    end,
}

--midnight
SMODS.Joker {
	key = 'midnight',
	loc_txt = {
		name = 'Midnight',
		text = {
            "Create a {C:dark_edition}spectral{} card when",
            "playing your {C:attention}final hand{} with",
            "{C:red}no discards{} {C:attention}used{}",
            "{C:inactive}(Must have room)"
		}
	},
	config = {  },
    unlocked = true,
    discovered = true, 
    blueprint_compat = true,
    perishable_compat = true, 
    eternal_compat = true,
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 8,
	loc_vars = function(self, info_queue, card)
		return { vars = { } }
	end,
	calculate = function(self, card, context)
        
        if context.joker_main then
            if  G.GAME.current_round.hands_left == 0 and G.GAME.current_round.discards_left >= G.GAME.round_resets.discards then
                if #G.consumeables.cards < G.consumeables.config.card_limit then
                    local new_card2 = SMODS.add_card({set = "Spectral" })
                    card:juice_up(0.3, 0.5)
                    return {message = "Created!"}
                end
            end
		end
	end
}

--7 leaf clover
SMODS.Joker {
	key = '7_leaf_clover',
	loc_txt = {
		name = '7 Leaf Clover',
		text = {
            "{C:green}+1 free rerolls{} every {C:attention}7{C:inactive}[#1#] {C:attention}7{}'s scored.",
            "If you have already gained a reroll",
            "this blind instead gain a {C:green}Clover Tag{}",
            "{C:inactive}(Currently {C:green}+#2# free rerolls{C:inactive})"
		}
	},
	config = {current = 0,rerolls=0,has_trig = false},
    unlocked = true,
    discovered = true, 
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	rarity = 2,--dsvid woiz heree
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_TAGS["tag_onio_clover"]
        return {vars = {
            card.ability.current,
            card.ability.rerolls,
            card.ability.has_trig
        }}
    end,
    remove_from_deck = function(self, card, from_debuff)
        SMODS.change_free_rerolls(-1 * card.ability.rerolls)
    end,
	calculate = function(self, card, context)
        
        if context.first_hand_drawn and not context.blueprint then
            card.ability.has_trig = false
        end


        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 7 then
                card.ability.current = card.ability.current + 1

                if card.ability.current >= 7 then
                    if card.ability.has_trig then
                        card.ability.current = 0
                        add_tag(Tag('tag_onio_clover'))
                        play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                        return {
                            message_card = card,
                            message = "Clover!",
                            colour = G.C.GREEN
                        }
                    else
                        card.ability.rerolls = card.ability.rerolls + 1
                        card.ability.current = 0 
                        card.ability.has_trig = true
                        SMODS.change_free_rerolls(1)
                        return {
                            message_card = card,
                            message = "+1 Rerolls!",
                            colour = G.C.GREEN
                        }
                    end
                else
                    return {
                        message_card = card,
                        message = tostring(card.ability.current).."/7",
                        colour = G.C.GREEN
                    }
                end
			end
        end

	end
}

--slot machine
SMODS.Joker {
	key = 'slotmachine',
	loc_txt = {
		name = 'Slot Machine',
		text = {
			"If the played hand is a {C:attention}Three of a Kind",
            "randomize the {C:attention}suits{} of all scoring cards",
            "{C:money}+$#1#{} if there are {C:attention}2{} of the same {C:attention}suit",
            "{C:money}+$#2#{} if there are {C:attention}3{} of the same {C:attention}suit"
		}
	},
	config = {
        extra = { pair_money = 10,three_money=30},
    },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.pair_money,card.ability.extra.three_money } }
	end,
	calculate = function(self, card, context)
        if context.before and context.scoring_name == "Three of a Kind" then

            local suitcount = {}
            for _,i in pairs(get_suit_table()) do
                suitcount[i] = 0
            end
            for _,i in pairs(context.scoring_hand) do
                if not i.debuff then
                    local s = pseudorandom_element(get_suit_table(), 'sigil')
                    assert(SMODS.change_base(i,s))
                    if G.GAME.blind.boss then
                        i.ability.played_this_ante = false
                        assert(i.ability.played_this_ante == false)
                        i.ability.played_this_ante = false
                        SMODS.debuff_card(i, "prevent_debuff", "pillar vs slot machine bug i fucking hate")
                    end
                    suitcount[s] = suitcount[s] + 1
                end
            end

            print(suitcount)
            for _,i in pairs(suitcount) do
                if i == 2 then return {dollars = card.ability.extra.pair_money,messsage = "Win!"} end
                if i == 3 then return {dollars = card.ability.extra.three_money,messsage = "Big Win!"} end
            end
        end

        if context.end_of_round and context.cardarea == G.jokers and not context.blueprint and G.GAME.blind.boss then
            for _,i in pairs(G.playing_cards) do
                SMODS.debuff_card(i, "reset", "pillar vs slot machine bug i fucking hate")
            end
        end
	end
}

--lighthouse
SMODS.Joker {
	key = 'lighthouse',
	loc_txt = {
		name = 'Lighthouse',
		text = {
			"{V:1}#1#{} cards {C:attention}always score{} and give {C:money}+#2#$",
            "suit {C:attention}cycles{} after every hand played",
            "{C:inactive}({C:hearts}Hearts{C:inactive} -> {C:diamonds}Diamonds{C:inactive} -> {C:clubs}Clubs{C:inactive} -> {C:spades}Spades{C:inactive})"
		}
	},
	config = { extra = {suit_index = 1,money = 1} },
    unlocked = true,  
	discovered = true,
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return {
            vars = {get_suit_table()[card.ability.extra.suit_index],card.ability.extra.money,
            colours = { G.C.SUITS[get_suit_table()[card.ability.extra.suit_index]] } -- sets the colour of the text affected by `{V:1}`
            }
        }
	end,
	calculate = function(self, card, context)

        if context.modify_scoring_hand then
            if context.other_card:is_suit(get_suit_table()[card.ability.extra.suit_index]) then
                return {
                    add_to_hand = true
                }
            end
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit(get_suit_table()[card.ability.extra.suit_index]) then
                return {
                    dollars = card.ability.extra.money,
                }
			end
        end
        
        if context.after then
            card.ability.extra.suit_index = card.ability.extra.suit_index + 1
            if card.ability.extra.suit_index > #get_suit_table() then
                card.ability.extra.suit_index = 1
            end
            return {
                message = tostring(get_suit_table()[card.ability.extra.suit_index]).."!",
                colour =  G.C.SUITS[get_suit_table()[card.ability.extra.suit_index]]
            }
            
        end

	end
}

--medusa
SMODS.Joker {
	key = 'medusa',
	loc_txt = {
		name = 'Medusa',
		text = {
			"Scoring {C:attention}face cards{} are",
            "enhanced into {C:attention}stone cards{}"
		}
	},
	config = { extra = {} },
    unlocked = true,  
	discovered = true,
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
    end,
	calculate = function(self, card, context)
        if context.before and context.main_eval and not context.blueprint then

            for _, scored_card in ipairs(context.scoring_hand) do
                if scored_card:is_face() then

                    scored_card:set_ability('m_stone', nil, true)
                    card_eval_status_text(scored_card, 'jokers', 1, nil, nil, {message = "Petrified!", colour =  G.C.UI.TEXT_INACTIVE})
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            scored_card:juice_up()
                            card:juice_up()
                            return true
                        end
                    }))
                end
            end
            
        end

    end
}

--void
SMODS.Joker {
	key = 'void',
	loc_txt = {
		name = 'Void',
		text = {
			"Sell this Joker to",
            "{C:red}destroy all Jokers{}",
            "and create an equal",
            "amount of {C:dark_edition}Negative Tags"
		}
	},
	config = { extra = { } },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = false, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 1, y = 0 },
	cost = 4,
    sell_cost = 0,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTER_POOLS.Tag[3]
		return {vars = {}}
	end,
	calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            for i=1,#G.jokers.cards do 
                if not SMODS.is_eternal(G.jokers.cards[i], card) and not G.jokers.cards[i].getting_sliced then
                    local sliced_card = G.jokers.cards[i]
                    sliced_card.getting_sliced = true -- Make sure to do this on destruction effects
                    G.GAME.joker_buffer = G.GAME.joker_buffer - 1
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.joker_buffer = 0
                            -- See note about SMODS Scaling Manipulation on the wiki
                            card:juice_up(0.8, 0.8)
                            sliced_card:start_dissolve({ HEX("000000") }, nil,1.6)
                            play_sound('slice1', 0.96 + math.random() * 0.08)
                            add_tag(Tag('tag_negative'))
                            play_sound('generic1', 0.6 + math.random() * 0.1, 0.8)
                            play_sound('holo1', 1.1 + math.random() * 0.1, 0.4)
                            return true
                        end
                    }))
                end
            end
        end
	end
}

--pioneer 9
SMODS.Joker {
	key = 'pioneer_9',
	loc_txt = {
		name = 'Pioneer 9',
		text = {
            "Create a {C:planet}Planet{} card",
            "every {C:attention}#1#{C:inactive}[#2#]{C:attention} 9{}'s scored",
            "{C:inactive}(Must have room)"
		}
	},
	config = {max = 4, current = 0},
    unlocked = true,
    discovered = true, 
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.max,
            card.ability.current,
        }}
    end,
	calculate = function(self, card, context)

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:get_id() == 9 then
                if not context.blueprint then
                    card.ability.current = card.ability.current + 1
                end

                if card.ability.current >= card.ability.max then
                    if #G.consumeables.cards < G.consumeables.config.card_limit then
                        local new_card = SMODS.add_card({set = "Planet"})
                        if not context.blueprint then
                            card.ability.current = 0
                        end
                        return {
                            message_card = card,
                            message = "Created!",
                        }
                    else
                        return {
                            message_card = card,
                            message = "No Room!",
                        }
                    end
                else
                    if not context.blueprint then
                        return {
                            message_card = card,
                            message = tostring(card.ability.current).."/"..tostring(card.ability.max),
                        }
                    end
                end
			end
        end

	end
}

--job application
SMODS.Joker {
	key = 'job_application',
	loc_txt = {
		name = 'Job Application',
		text = {
			"Each owned {C:attention}Joker{} gives",
            "{C:money}+$#1#{} at end of round."
		}
	},
	config = { extra = {
        money = 1
    } },
    unlocked = true,
	discovered = true, 
    blueprint_compat = true,
    perishable_compat = true, 
	eternal_compat = false,
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 3, y = 4 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return {vars = { 
            card.ability.extra.money
            }
        }
	end,
    calculate = function(self, card, context)
		if context.end_of_round and context.cardarea == G.jokers then

            local gains = {}

            for _,j in pairs(G.jokers.cards) do
                if not j.debuff then
                    card:juice_up()
                    gains[#gains+1] = {message_card = j, dollars = card.ability.extra.money}
                end
            end

            --message nesting
            local return_value =  {}
            local last_had_extra = false
            local g = reverse_table_num(gains)
            for _,i in pairs(g) do
                if indexOf(g,i) == 1 then
                    return_value = i
                else
                    local copy = return_value
                    i.extra = copy
                    return_value = i
                end
            end

            if return_value ~= {} then
                return return_value
            end
        end
	end
}

--disabled parking
SMODS.Joker {
	key = 'disabled_parking',
	loc_txt = {
		name = 'Disabled Parking',
		text = {
			"Each {C:red}debuffed{} {C:attention}Joker{} or",
            "card held in hand gives",
            "{C:money}+$#1#{} at end of round."
		}
	},
	config = { extra = {
        money = 6
    } },
    unlocked = true,
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = false,
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return {vars = { 
            card.ability.extra.money
            }
        }
	end,
    calculate = function(self, card, context)
		if context.end_of_round and context.cardarea == G.jokers then

            local gains = {}

            for _,j in pairs(G.jokers.cards) do
                if j.debuff then
                    card:juice_up()
                    gains[#gains+1] = {message_card = j, dollars = card.ability.extra.money}
                end
            end
            for _,j in pairs(G.hand.cards) do
                if j.debuff then
                    card:juice_up()
                    gains[#gains+1] = {message_card = j, dollars = card.ability.extra.money}
                end
            end

            --message nesting
            local return_value =  {}
            local last_had_extra = false
            local g = reverse_table_num(gains)
            for _,i in pairs(g) do
                if indexOf(g,i) == 1 then
                    return_value = i
                else
                    local copy = return_value
                    i.extra = copy
                    return_value = i
                end
            end

            if return_value ~= {} then
                return return_value
            end
        end
	end
}

--lighter
SMODS.Joker {
	key = 'lighter',
	loc_txt = {
		name = 'Lighter',
		text = {
            "If the {C:attention}first or last discard",
            "contains only {C:attention}1{} single card",
            "add a {C:attention}Burnt Seal{}"
		}
	},
	config = {},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_SEALS['onio_burnt_seal']
        return {vars = {}}
    end,
	calculate = function(self, card, context)

        if context.pre_discard and not context.blueprint then
            local trig = (G.GAME.round_resets.discards == G.GAME.current_round.discards_left) or (G.GAME.current_round.discards_left == 1)
            if #G.hand.highlighted == 1 and trig then
                G.hand.highlighted[1]:juice_up(0.3, 0.5)
                G.hand.highlighted[1]:set_seal('onio_burnt_seal', nil, true)
                return {
                    message_card = card,
                    message = "Burnt!",
                }
            end
        end


	end
}

--pickaxe
SMODS.Joker {
	key = 'pickaxe',
	loc_txt = {
		name = 'Pickaxe',
		text = {
			"{C:attention}1{} random played {C:attention}stone card{} is",
            "converted into {C:gold}Gold{} or {C:inactive}Steel{}",
            "{C:green}#1# in #2#{} chance to add {C:money,E:1}Gilded",
		}
	},
    enhancement_gate = "m_stone",
	config = {extra= {chance=1,odds = 6}},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_stone"]
        info_queue[#info_queue+1] = G.P_CENTERS["m_gold"]
        info_queue[#info_queue+1] = G.P_CENTERS["m_steel"]
        info_queue[#info_queue + 1] = G.P_CENTERS.e_onio_gilded
        return {vars = {card.ability.extra.chance,card.ability.extra.odds}}
    end,
	calculate = function(self, card, context)

        if context.before and context.main_eval and not context.blueprint then

            local valids = {}
            for _, scored_card in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(scored_card, "m_stone") and not scored_card.debuff and not scored_card.vampired then
                    valids[#valids+1] = scored_card
                end
            end
            local target = pseudorandom_element(valids,pseudoseed("targetpickslguaglrhag"))


            for _, scored_card in ipairs(context.scoring_hand) do
                if scored_card == target and SMODS.has_enhancement(scored_card, "m_stone") and not scored_card.debuff and not scored_card.vampired then

                    scored_card.vampired = true
                    
                    scored_card:set_ability(pseudorandom_element({"m_steel","m_gold"},pseudoseed("scrumble")), nil, true)
                    card_eval_status_text(scored_card, 'jokers', 1, nil, nil, {message = "Mined!", colour = G.C.UI.TEXT_INACTIVE})

                    if pseudorandom('bday_card') < ((card.ability.extra.chance * G.GAME.probabilities.normal) / card.ability.extra.odds) then
                        scored_card:set_edition("e_onio_gilded", true)
                    end

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            scored_card:juice_up()
                            card:juice_up()
                            scored_card.vampired = nil
                            return true
                        end
                    }))
                end
            end

        end


	end
}

--ghost pepper
SMODS.Joker {
	key = 'ghost_pepper',
	loc_txt = {
		name = 'Ghost Pepper',
		text = {
            "Gains {X:chips,C:white}X#2#{} {C:chips}Chips{} after each round",
            "This {C:attention}Joker{} is {C:red}destroyed{} in {C:attention}#3#{} rounds",
            "{C:attention}+2{} rounds when a {C:spectral,E:1}Spectral{} card is used",
            "{C:inactive}(Currently {X:chips,C:white}X#1#{} {C:chips}Chips{}{C:inactive})"
		}
	},
	config = {chips_mult = 1.0,chip_mult_gain=0.5,remaining = 4},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true,
    perishable_compat = true, 
    eternal_compat = true, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.chips_mult,
            card.ability.chip_mult_gain,
            card.ability.remaining
        }}
    end,
	calculate = function(self, card, context)

        if context.joker_main then
            return {xchips = card.ability.chips_mult}
        end

        if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
            card.ability.remaining = card.ability.remaining - 1
            if card.ability.remaining <= 0 then
                card:start_dissolve()
                G.jokers:remove_card(card)
                return {
                    card = target,
                    message = "Eaten!"
                }
            else
                card.ability.chips_mult = math.max(1.0,card.ability.chips_mult + card.ability.chip_mult_gain)
                return {
                    message = "+X"..tostring(card.ability.chip_mult_gain),
                    colour = G.C.CHIPS,
                    message_card = card,
                    extra = {
                        message_card = card,
                        message = tostring(card.ability.remaining).." Remaining!",
                        colour = G.C.SECONDARY_SET.Spectral
                    }
                }
            end
        end

        if context.using_consumeable and not context.blueprint then
            if context.consumeable.config.center.set == "Spectral" then
                card.ability.remaining = card.ability.remaining + 2
                return {
                        message_card = card,
                        message = "+1 Round!",
                        colour = G.C.SECONDARY_SET.Spectral
                    }
            end
        end


	end
}

--tag team
SMODS.Joker {
	key = 'tag_team',
	loc_txt = {
		name = 'Tag Team',
		text = {
            "Create a {C:attention}Tag{} for",
            "every {C:attention}Pair{} in hand",
            "at end of round"
		}
	},
	config = {},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = true,
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
		return { vars = {}}
	end,
	calculate = function(self, card, context)

        if context.end_of_round and context.individual then
            
            local ranks_seen = {}
            for _, v in pairs(G.hand.cards) do
                ranks_seen[v:get_id()] = (ranks_seen[v:get_id()] or 0) + 1
            end
            if ranks_seen[context.other_card:get_id()] ~= nil then
                if tonumber(ranks_seen[context.other_card:get_id()]) >= 2 then

                    local cards_of_this_rank = {}
                    for a, b in pairs(G.hand.cards) do
                        if b.base.id == context.other_card.base.id then
                            cards_of_this_rank[#cards_of_this_rank + 1] = b
                        end
                    end

                    if indexOf(cards_of_this_rank,context.other_card) == 1 then
                        return {
                            message_card = context.other_card,
                            message = "Tag!",
                            func = function ()
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        --context.other_card:juice_up()
                                        card:juice_up()
                                        add_tag(Tag(pseudorandom_element(get_keys(G.P_TAGS),pseudoseed("tag1"))))
                                        return true
                                    end
                                }))
                            end
                        }
                    end
                end
            end
        end
        
	end
}

--weighted dice
SMODS.Joker {
	key = 'weight_dice',
	loc_txt = {
		name = 'Weighted Dice',
		text = {
			"Create an {C:uncommon}Uncommon Tag{} every {C:attention}#1#{C:inactive}[#2#]{} Rerolls",
            "Create a {C:rare}Rare Tag{} every {C:attention}#3#{C:inactive}[#4#]{} Rerolls",
            "Resets at end of shop"
		}
	},
	config = { extra = { u_max = 4, u_prog = 0, r_max = 6, r_prog = 0 } },
    unlocked = true,  
	discovered = true,
    blueprint_compat = true,
    perishable_compat = true,
	eternal_compat = false, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
    sell_cost = 0,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTER_POOLS.Tag[1]
        info_queue[#info_queue+1] = G.P_CENTER_POOLS.Tag[2]
		return {vars = {card.ability.extra.u_max,card.ability.extra.u_prog,card.ability.extra.r_max,card.ability.extra.r_prog}}
	end,
	calculate = function(self, card, context)

        if context.ending_shop then
            card.ability.extra.u_prog = 0
            card.ability.extra.r_prog = 0
            return {
                message = "Reset!",
                colour = G.C.UI.TEXT_INACTIVE
            }
        end

        if context.reroll_shop then
            card.ability.extra.u_prog = card.ability.extra.u_prog + 1
            if card.ability.extra.u_prog >= card.ability.extra.u_max then
                card.ability.extra.u_prog = 0
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:juice_up()
                        add_tag(Tag("tag_uncommon"))
                        card_eval_status_text(card, 'jokers', 1, nil, nil, {message = "Tag!", colour = G.C.RARITY.Uncommon})
                        return true
                    end
                }))
            else
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card_eval_status_text(card, 'jokers', 1, nil, nil, {message = tostring(card.ability.extra.u_prog).."/"..tostring(card.ability.extra.u_max), colour = G.C.RARITY.Uncommon})
                        return true
                    end
                }))
            end

            card.ability.extra.r_prog = card.ability.extra.r_prog + 1
            if card.ability.extra.r_prog >= card.ability.extra.r_max then
                card.ability.extra.r_prog = 0
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:juice_up()
                        add_tag(Tag("tag_rare"))
                        card_eval_status_text(card, 'jokers', 1, nil, nil, {message = "Tag!", colour = G.C.RARITY.Rare})
                        return true
                    end
                }))
            else
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card_eval_status_text(card, 'jokers', 1, nil, nil, {message = tostring(card.ability.extra.r_prog).."/"..tostring(card.ability.extra.r_max), colour = G.C.RARITY.Rare})
                        return true
                    end
                }))
            end

        end
	end
}

--doughnut
SMODS.Joker {
	key = 'doughnut',
	loc_txt = {
		name = 'Doughnut',
		text = {
			"Each played {C:attention}6{}, {C:attention}8{}, {C:attention}9{},",
            "{C:attention}10{} or {C:attention}Queen gives",
            "{C:mult}+#1# Mult{} when scored",
            "{C:mult}-2 Mult{} per round"
		}
	},
	config = { extra = { mult = 12} },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
		return {vars = { card.ability.extra.mult}}
	end,
	calculate = function(self, card, context)

        if context.end_of_round and context.cardarea == G.jokers then
            if not context.blueprint then
                card.ability.extra.mult = card.ability.extra.mult - 2
            end
            if card.ability.extra.mult <= 0 then
                card:start_dissolve()
                G.jokers:remove_card(card)
                return {
                    card = target,
                    message = "Eaten!"
                }
            else
                return {
                    message = "-2",
                    colour = G.C.MULT
                }
            end
        end

		if context.individual and context.cardarea == G.play then
            if indexOf({6,8,9,10,12},context.other_card:get_id()) ~= nil then
                return {
                    mult = card.ability.extra.mult,
                }
            end
        end
	end
}

--palm reader
SMODS.Joker {
	key = 'palm_reader',
	loc_txt = {
		name = 'Palm Reader',
		text = {
            "Create {C:attention}2 {C:attention,E:1}Fragile{} {C:tarot}Tarot{} cards",
            "when blind is selected",
            "{C:inactive}({C:red}Destroyed{C:inactive} at end of round)",
            "{C:inactive}(Must have room)"
		}
	},
	config = {},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true,
    perishable_compat = true, 
    eternal_compat = true,
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = { } }
	end,
	calculate = function(self, card, context)
        
        if context.setting_blind then

            for i=1,2 do
                if #G.consumeables.cards < G.consumeables.config.card_limit then
                    local new_card = SMODS.add_card({set = "Tarot"})
                    SMODS.Stickers.onio_fragile:apply(new_card, true)
                    card_eval_status_text(card, 'jokers', 1, nil, nil, {message = "Tarot!", colour = G.C.SECONDARY_SET.Tarot})
                end
            end
        end

	end
}

--frozen joker
SMODS.Joker {
	key = 'frozen',
	loc_txt = {
		name = 'Frozen Joker',
		text = {
			"Create a {C:rare}Rare{C:attention} Joker{} after",
            "setting the score on {C:red}fire{C:attention} #2#{} times",
            "{C:red}self destructs",
            "{C:inactive}(Currently {C:attention}#1#/#2#{C:inactive})"
		}
	},
	config = {
        extra = {current=0,max=2},
    },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = false, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 4, y = 4 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		return { vars = {card.ability.extra.current,card.ability.extra.max} }
	end,
	calculate = function(self, card, context)
        if context.final_scoring_step and (hand_chips * mult) > G.GAME.blind.chips then
            
            card.ability.extra.current = card.ability.extra.current + 1
            if  card.ability.extra.current >= card.ability.extra.max then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.25,
                    func = function()
                        card:start_dissolve()
                        G.jokers:remove_card(card)
                        local new_joker = SMODS.add_card({set = 'Joker', rarity = 1 })
                        return true
                    end
                }))
                return {
                    message = "Thawed!",
                    colour = G.C.BLUE
                }
            end

            return {
                message = tostring(card.ability.extra.current).."/"..tostring(card.ability.extra.max),
                colour = G.C.BLUE
            }
		end
	end
}

--instant noodles
SMODS.Joker {
	key = 'instant_noodles',
	loc_txt = {
		name = 'Instant Noodles',
		text = {
            "{X:mult,C:white}X#1#{} {C:mult}Mult{}",
            "{C:red}Destroyed{} after boss blind"
		}
	},
	config = {mult_mult = 3},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = false, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.mult_mult
        }}
    end,
	calculate = function(self, card, context)

        if context.joker_main then
            return {xmult = card.ability.mult_mult}
        end

        if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
            if G.GAME.blind.boss then
                card:start_dissolve()
                G.jokers:remove_card(card)
                return {
                    card = target,
                    message = "Eaten!"
                }
            end
        end
	end
}

--free trial
SMODS.Joker {
	key = 'free_trial',
	loc_txt = {
		name = 'Free Trial',
		text = {
            "Create a {C:attention,E:1}Fragile{} {C:dark_edition}Negative{} {C:attention}Joker",
            "when blind is selected", 
            "{C:inactive}({C:red}Destroyed{C:inactive} at end of round)",
		}
	},
	config = {},
    unlocked = true,
    discovered = true, 
    blueprint_compat = true,
    perishable_compat = true, 
    eternal_compat = true,
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTER_POOLS.Tag[3]
		return {vars = {}}
	end,
	calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then

                local valids = {}
                for _,i in pairs(G.P_CENTERS) do
                    if _:find("j_") then
                        if i.perishable_compat then
                            valids[#valids+1] = _
                        end
                    end
                end

                local new_card = SMODS.add_card({set = "Joker", edition = "e_negative", key=pseudorandom_element(valids,pseudoseed("pick"))})
                
                G.GAME.joker_buffer = 0
                SMODS.Stickers.onio_fragile:apply(new_card, true)
                card_eval_status_text(card, 'jokers', 1, nil, nil, {message = "Trial!", colour = G.C.SECONDARY_SET.Tarot})
        end

	end
}

--restraining order
SMODS.Joker {
	key = 'restraining_order',
	loc_txt = {
		name = 'Restraining Order',
		text = {
            "{X:mult,C:white}X#1#{} {C:mult}Mult{} if the played hand",
            "contains {C:attention}2{} ranks that have atleast",
            "{C:attention}5{} ranks between them",
            "{C:inactive}(e.g. {C:attention}2{C:inactive} & {C:attention}7{C:inactive} or {C:attention}3{C:inactive} & {C:attention}Jack{C:inactive})"
		}
	},
	config = {mult_mult = 3},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = false, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.mult_mult
        }}
    end,
	calculate = function(self, card, context)

        if context.joker_main then
            local allow = false
            local counts = {}
            local msg = ""
            for _,i in pairs(G.play.cards) do
                local a = i:get_id()-- or i.orig_id or i.base.id
                counts[#counts+1] = a
            end
            for a=1,#counts do
                for b=1,#counts do
                    if math.abs(counts[a] - counts[b]) >= 5 then
                        msg = tostring(get_rank_table()[counts[a]-1]).."-"..tostring(get_rank_table()[counts[b]-1])
                        allow = true
                    end
                end
            end

            if allow then
                return {
                    message = msg,
                    xmult = card.ability.mult_mult
                }
            end
        end
	end
}

--oversaturated scaling func
local scie = SMODS.calculate_individual_effect
function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition)
    local ret = scie(effect, scored_card, key, amount, from_edition)
    if
        (
            key == "x_mult"
            or key == "xmult"
            or key == "Xmult"
            or key == "x_mult_mod"
            or key == "xmult_mod"
            or key == "Xmult_mod"
        )
        and amount ~= 1
        and mult
    then
        for _, v in pairs(find_joker("j_onio_oversaturated_joker")) do
            --v.ability.extra.xmult = v.ability.extra.xmult + v.ability.extra.gain
            v.ability.extra.xmult = v.ability.extra.xmult + v.ability.extra.gain
            card_eval_status_text(v, 'jokers', 1, nil, nil, {message = "Upgraded!", colour = G.C.MULT})
        end
    end
    return ret
end
--oversaturated joker
SMODS.Joker {
	key = 'oversaturated_joker',
	loc_txt = {
		name = 'Oversaturated Joker',
		text = {
			"Gains {X:mult,C:white}X#1#{C:mult} Mult{} whenever",
            "{X:mult,C:white}XMult{} is triggred",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:mult} Mult{} {C:inactive})"
		}
	},
	config = { extra = {gain = 0.05, xmult = 1, active = false}},
    unlocked = true,
	discovered = true,
    blueprint_compat = true,
    perishable_compat = true,
	eternal_compat = true,
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 5, y = 4 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		return { vars = {
            card.ability.extra.gain,
            card.ability.extra.xmult,
        } }
	end,
	calculate = function(self,card,context)

        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end

	end,
}

--construction work
SMODS.Joker {
	key = 'construction_work',
	loc_txt = {
		name = 'Construction Work',
		text = {
            "Gains {X:chips,C:white}X#1#{} {C:chips}Chips{} if the played hand",
            "is {C:red}not{} a {C:inactive}[{}{C:attention}#3#{}{C:inactive}]{} but contains a {C:inactive}[{}{C:attention}#3#{C:inactive}]{},",
            "then target {C:inactive}[{}{C:attention}hand{}{C:inactive}]{} is set to the {C:attention}played hand.",
            "{C:attention}Resets hand{} to {C:attention}Highcard{} after boss blind",
            "{C:inactive}(Currently {X:chips,C:white}X#2#{} {C:chips}Chips{C:inactive})"
		}
	},
	config = {gain = 0.5,Xchips = 1,current_hand = "High Card"},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = false, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.gain,
            card.ability.Xchips,
            card.ability.current_hand,
        }}
    end,
	calculate = function(self, card, context)

        if context.joker_main then
            return {xchips = card.ability.Xchips}
        end

        if context.before and next(context.poker_hands[card.ability.current_hand]) then
            if context.scoring_name ~= card.ability.current_hand then
                print(context.scoring_name)
                card.ability.current_hand = context.scoring_name
                card.ability.Xchips = card.ability.Xchips + card.ability.gain
                return {
                    message = "Upgraded!",
                    colour = G.C.CHIPS
                }
            end
        end

        if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
            if G.GAME.blind.boss then
                card.ability.current_hand = "High Card"
                return {
                    message = "Reset Hand!",
                    colour = G.C.CHIPS
                }
            end
        end
	end
}

--dark fountain
SMODS.Joker {
    key = 'dark_fountain',
	loc_txt = {
		name = 'Dark Fountain',
		text = {
			"When first hand is drawn, draw",
            "{C:attention}5 {C:dark_edition}Negative {C:attention,E:1}Fragile{} playing cards with",
            "a random {C:attention}enhancement{} & {C:attention}seal{} to hand",
            "{C:inactive}({C:red}Destroyed{C:inactive} at end of round)"
		}
	},
	config = {
        amount = 5,
    },
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
    loc_vars = function(self, info_queue, card)
		return { vars = { } }
	end,
    calculate = function(self, card, context)
        if context.setting_blind then
             for i = 1, card.ability.amount do
                local r = pseudorandom_element(get_rank_table(),pseudoseed("stoners"))
                local s = pseudorandom_element(get_suit_table(),pseudoseed("stoners"))
                local new_card = create_playing_card({
                    --front = G.P_CARDS.S_A, 
                    no_edition = true,
                    area = nil,
                    --rank = pseudorandom_element(get_rank_table(),pseudoseed("stonerr")),
                    --suit = pseudorandom_element(get_suit_table(),pseudoseed("stoners")),
                    center = G.P_CENTERS.c_base}, G.hand, nil, nil, {G.C.SECONDARY_SET.Enhanced}
                )
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                SMODS.change_base(new_card, s, r)
                rand_seals = G.P_CENTER_POOLS.Seal
                rand_editi = G.P_CENTER_POOLS.Edition
                --remove base & negative edition from pool
                rand_editi[1] = nil
                rand_editi[5] = nil

                new_card:set_edition("e_negative", true)
                SMODS.Stickers.onio_fragile:apply(new_card, true)
                
                new_card:set_ability(pseudorandom_element(G.P_CENTER_POOLS.Enhanced,pseudoseed(tostring("glitch_404"))).key)
                new_card:set_seal(pseudorandom_element(rand_seals,pseudoseed("stoner_add")).key, nil, true)

                draw_card(G.hand,G.hand, 0.5,'down', nil, new_card, 0.07)

            end
        end
    end,
}

--chips & dip
SMODS.Joker {
	key = 'chips_and_dip',
	loc_txt = {
		name = 'Chips & Dip',
		text = {
			"{C:chips}+#1# Chips",
            "{C:chips}-#2# Chips{} per{C:attention} Booster Pack{} opened "
		}
	},
	config = { extra = {chips = 200, loss = 40}},
    unlocked = true,
	discovered = true,
    blueprint_compat = true,
    perishable_compat = true,
	eternal_compat = true,
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = {
            card.ability.extra.chips,
            card.ability.extra.loss,
        } }
	end,
	calculate = function(self,card,context)

        if context.open_booster then
            if not context.blueprint then
                card.ability.extra.chips = card.ability.extra.chips - card.ability.extra.loss
            end
            if card.ability.extra.chips > 0 and not context.blueprint then
                return {
                    message_card = card,
                    message = "-"..tostring(card.ability.extra.loss),
                    colour = G.C.CHIPS
                }
            else
                card:start_dissolve()
                G.jokers:remove_card(card)
                return {
                    card = target,
                    message = "Eaten!"
                }
            end
        end

        if context.joker_main then
            return {chips = card.ability.extra.chips}
        end

	end,
}

--archaeologist
SMODS.Joker {
	key = 'archaeologist',
	loc_txt = {
		name = 'Archaeologist',
		text = {
            "Create a {C:attention}Relic{} card every",
            "{C:attention}#1#{C:inactive}[#2#]{C:attention} Stone Cards{} scored",
            "{C:inactive}(Must have room)"
		}
	},
	config = {max = 10, current = 0},
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	rarity = 1,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS["m_stone"]
        return {vars = {
            card.ability.max,
            card.ability.current,
        }}
    end,
	calculate = function(self, card, context)

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if SMODS.has_enhancement(context.other_card, "m_stone") then
                if not context.blueprint then
                    card.ability.current = card.ability.current + 1
                end

                if card.ability.current >= card.ability.max then
                    if #G.consumeables.cards < G.consumeables.config.card_limit then
                        local new_card = SMODS.add_card({set = "Relics"})
                        if not context.blueprint then
                            card.ability.current = 0
                        end
                        return {
                            message_card = card,
                            message = "Created!",
                        }
                    else
                        return {
                            message_card = card,
                            message = "No Room!",
                        }
                    end
                else
                    if not context.blueprint then
                        return {
                            message_card = card,
                            message = tostring(card.ability.current).."/"..tostring(card.ability.max),
                        }
                    end
                end
			end
        end

	end
}

--excavation
SMODS.Joker {
	key = 'excavation',
	loc_txt = {
		name = 'Excavation',
		text = {
            "Create a {C:attention}Relic{} card every",
            "{C:attention}#1#{C:inactive}[#2#]{} cards {C:red}destroyed",
            "{C:inactive}(Must have room)"
		}
	},
    config = {max = 6, current = 0},
    unlocked = true,  
	discovered = true, 
    blueprint_compat = true,
    perishable_compat = true,
	eternal_compat = true, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.max,
            card.ability.current,
        }}
    end,
	calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            
            card.ability.current = card.ability.current + #context.removed

            while card.ability.current >= card.ability.max do
                if not context.blueprint then
                    card.ability.current = card.ability.current - card.ability.max
                end
                if #G.consumeables.cards < G.consumeables.config.card_limit then
                    local new_card = SMODS.add_card({set = "Relics"})
                    return {
                        message_card = card,
                        message = "Created!",
                    }
                else
                    return {
                        message_card = card,
                        message = "No Room!",
                    }
                end
            end
            if card.ability.current < card.ability.max then
                if not context.blueprint then
                    return {
                        message_card = card,
                        message = tostring(card.ability.current).."/"..tostring(card.ability.max),
                    }
                end
            end

        end
	end
}

--sunset
SMODS.Joker {
	key = 'sunset',
	loc_txt = {
		name = 'Sunset',
		text = {
            "Create a {C:dark_edition}Negative{} {C:attention,E:1}Fragile{} {C:spectral}Spectral{}",
            "card {C:attention}boss blind{} is selected",
            "{C:inactive}({C:red}Destroyed{C:inactive} at end of round)",
		}
	},
	config = {},
    unlocked = true,  
    discovered = true, 
    blueprint_compat = true, 
    perishable_compat = true, 
    eternal_compat = false, 
	rarity = 2,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
        return {vars = {}}
    end,
	calculate = function(self, card, context)

        if context.setting_blind and G.GAME.blind.boss then
            card:juice_up()
            local new_card = SMODS.add_card({set = "Spectral",edition = "e_negative"})
            SMODS.Stickers.onio_fragile:apply(new_card, true)
            return {
                message = "Created!",
            }
        end

	end
}



--??? dice

--PH test

--minesweeper

--grafitti

--SMODS.Stickers.onio_fragile:apply(card, true)

-- discard count - G.GAME.round_resets.discards
-- hand count - G.GAME.round_resets.hands
-- discards remaining - G.GAME.current_round.discards_left
-- hands remaining - G.GAME.current_round.hands_left
-- hand size - G.hand:change_size(G.hand.config.card_limit) - G.GAME.round_resets.temp_handsize - G.hand.config.card_limit
