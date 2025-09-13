
--Effigy rank
SMODS.Rank {
    key = 'Effigy',
    lc_atlas = 'OnionRanks', hc_atlas = 'OnionRanks',
    loc_txt = {
        name = "Effigy"
    },
    card_key = 'E',
    pos = { x = 0 },
    suit_map = { Hearts = 0, Clubs = 1, Diamonds = 2, Spades = 3 },
    nominal = 15,
    face_nominal = 0.65,
    face = true,
    shorthand = 'E',
    next = {},
    strength_effect = {ignore = true},
    in_pool = function (self,args)
        if args.initial_deck then
            return false
        end
        return (next(SMODS.find_card("j_onio_isabel")) ~= nil)
    end
}

--isabel
SMODS.Joker {
	key = 'isabel',
	loc_txt = {
		name = 'Isabel',
		text = {
            "{C:mult}+#2# Mult{} for every {C:attention}Effigy{}",
            "card in your {C:attention}full deck{}."
		}
	},
	config = { upgrade_requirement = 10 , upgrade_level = 0, upgrade_ping = false},
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true, 
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 0, y = 0 },
	cost = 8,
    update = function(self, card, dt)
        if next(SMODS.find_card("j_onio_isabel")) then
            G.GAME.has_isabel_existed.has = true
        end
        self.loc_txt.name = rcs(8)

        local count = 0
        if G.deck then
            for i = 1, #G.playing_cards do
                if G.playing_cards[i]:get_id() == 15 then count = count + 1 end
            end
        end

        local upgrade_borders = {5,10,20,30,40,999999}
        local temp_lvl = 0
        local last_threshold = -1
        for i=1,#upgrade_borders do
            if count >= last_threshold and math.min(count,50) < upgrade_borders[i] then
                temp_lvl = i - 1
                last_threshold = upgrade_borders[i]
            end
        end

        if temp_lvl ~= card.ability.upgrade_level then card.ability.upgrade_ping = true end

        card.ability.upgrade_requirement = upgrade_borders[temp_lvl + 1]
        card.ability.upgrade_level = temp_lvl

    end,
	loc_vars = function(self, info_queue, card)

        local lvl = card.ability.upgrade_level or 0

        local count = 0
        if G.deck then
            for i = 1, #G.playing_cards do
                if G.playing_cards[i]:get_id() == 15 then count = count + 1 end
            end
        end

        --lvl1
        local deck_mult_txt = {n = G.UIT.T, config = {minw=0, align = "tm", text = " +"..tostring((count) or 0).." Mult", colour = G.C.MULT, scale = 0.35}}

        local empty_fix = {n = G.UIT.T, config = {minw=0, align = "tm", text = "", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35}}
        local space_fix = {n = G.UIT.T, config = {minw=0, align = "tm", text = " ", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35}}
        local empty_txt = {n = G.UIT.T, config = {minw=0, align = "tm", text = " no additional effects", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35}}
        --local mult_txt = {n = G.UIT.T, config = {minw=0, align = "tm", text = " +"..tostring((count) or 0).." Mult", colour = G.C.MULT, scale = 0.35}}
        --l-ocal Smult_txt = {n = G.UIT.T, config = {minw=0, align = "tm", text = " +"..tostring((card.ability.deck_mult * count) or 0).." Mult", colour = G.C.MULT, scale = 0.35}}
        --local chip_txt = {n = G.UIT.T, config = {minw=0, align = "tm", text = " +"..tostring((card.ability.deck_mult * count) or 0).." Chips", colour = G.C.CHIPS, scale = 0.35}}
        --local money_txt = {n = G.UIT.T, config = {minw=0, align = "tm", text = " +$"..tostring((card.ability.deck_mult * count) or 0), colour = G.C.MONEY, scale = 0.35}}

        local Xmult_txt = {n = G.UIT.C, config = {maxw = 5,minw=0,maxh = 0.5, minh=0, colour = G.C.MULT, padding = 0.025, r=0.0}, nodes = {
            {n = G.UIT.T, config = {minw=0, align = "tm", text = "X"..tostring(1 + ((0.05 * count) or 0)), colour = G.C.WHITE, scale = 0.35}},
        }}
        local plain_mult_suffix = {n = G.UIT.T, config = {minw=0, align = "tm", text = " Mult", colour = G.C.MULT, scale = 0.35}}
        
        local Xchip_txt = {n = G.UIT.C, config = {maxw = 5,minw=0,maxh = 0.5, minh=0, colour = G.C.CHIPS, padding = 0.025, r=0.001}, nodes = {
            {n = G.UIT.T, config = {minw=0, align = "tm", text = "X"..tostring(1 + ((0.05 * count) or 0 or 0)), colour = G.C.WHITE, scale = 0.35}},
        }}
        local plain_chip_suffix = {n = G.UIT.T, config = {minw=0, align = "tm", text = " Chips", colour = G.C.CHIPS, scale = 0.35}}


        local m_start = ternary( lvl >= 2,{
            {n = G.UIT.C, config = {maxw = 5,minw=0,maxh = 0.5 + (0.5 * bool_to_number(lvl > 0)), minh=0, colour = G.C.WHITE, padding = 0.1}, nodes = {
                {n = G.UIT.R, config = {minw=5, minh=0, align = "tm", colour = G.C.WHITE, padding = 0}, nodes = {
                    {n = G.UIT.T, config = {padding=0,text = "Effigy cards",colour = G.C.FILTER,scale = 0.35 },},
                    {n = G.UIT.T, config = {padding=0,text = " cards may now apear.", colour = G.C.UI.TEXT_DARK, scale=0.35 },},
                }},
                {n = G.UIT.R, config = {minw=5, minh=0, align = "tm", colour = G.C.WHITE, padding = 0}, nodes = {
                    {n = G.UIT.T, config = {padding=0,text = "(1 Gaurenteed per standard pack)", colour = G.C.UI.TEXT_INACTIVE, scale=0.275 },}
                }}
            }}
        },{
            {n = G.UIT.T, config = {padding=0,text = "Effigy",colour = G.C.FILTER,scale = 0.35 },},
            {n = G.UIT.T, config = {padding=0,text = " cards may now apear.", colour = G.C.UI.TEXT_DARK, scale=0.35 },}
        })
        local m_end = {
            {n = G.UIT.C, config = {maxw = 5,minw=0,maxh = 0.5 + (0.5 * bool_to_number(lvl > 0)), minh=0, colour = G.C.WHITE, padding = 0.1}, nodes = {
                {n = G.UIT.R, config = {minw=5, minh=0, align = "tm", colour = G.C.WHITE, padding = 0}, nodes = {
                    {n = G.UIT.T, config = {minw=5, align = "tm", text = "(Currently", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35}},
                    ternary( lvl == 0, empty_txt , empty_fix ),
                    ternary( lvl == 1, deck_mult_txt , empty_fix ),
                    ternary( lvl >= 2, space_fix , empty_fix ),
                    ternary( lvl >= 2, Xmult_txt , empty_fix ),
                    ternary( lvl >= 2, plain_mult_suffix , empty_fix ),
                    ternary( lvl >= 5, space_fix , empty_fix ),
                    ternary( lvl >= 5, Xchip_txt , empty_fix ),
                    ternary( lvl >= 5, plain_chip_suffix , empty_fix ),
                    {n = G.UIT.T, config = {minw=5, align = "tm", text = ".)", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35}},
                }},
                ternary (lvl == 5,
                    {n = G.UIT.R, config = {minw=5, minh=0, align = "bm", colour = G.C.WHITE, padding = 0}, nodes = {
                        {n = G.UIT.T, config = {minw=5, align = "tm", text = "Max Upgrade!", colour = G.C.FILTER, scale = 0.35}},
                    }}
                ,
                    {n = G.UIT.R, config = {minw=5, minh=0, align = "bm", colour = G.C.WHITE, padding = 0}, nodes = {
                        {n = G.UIT.T, config = {minw=5, align = "tm", text = "Upgrade ability", colour = G.C.FILTER, scale = 0.35}},
                        {n = G.UIT.T, config = {minw=5, align = "bm", text = " when owning", colour = G.C.UI.TEXT_DARK, scale = 0.35}},
                        {n = G.UIT.T, config = {minw=5, align = "tm", text = " "..tostring(card.ability.upgrade_requirement), colour = G.C.FILTER, scale = 0.35}},
                        {n = G.UIT.T, config = {minw=5, align = "tm", text = "["..tostring(count).."]", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35}},
                        {n = G.UIT.T, config = {minw=5, align = "tm", text = " Effigies", colour = G.C.FILTER, scale = 0.35}},
                    }}
                )
            }}
        }
        
        return {
            main_start = m_start,
            main_end = m_end,
            vars = {
                card.ability.upgrade_requirement,
                card.ability.deck_mult,
                card.ability.deck_text,
                colours = { HEX('82868c')}
            },
            key = "j_onio_isabel_lvl"..tostring(lvl)
        }
	end,
	calculate = function(self, card, context)

        if card.ability.upgrade_ping then
            card.ability.upgrade_ping = false
            return {
                card = card,
                message = "Upgraded!"
            }
        end

        if card.ability.upgrade_level >= 2 and context.open_booster then
            if G.pack_cards and context.card.ability.name:find('Standard') ~= nil then

                G.E_MANAGER:add_event(Event({
                func = function()
                    if G.pack_cards and G.pack_cards.cards and G.pack_cards.cards[1] and G.pack_cards.VT.y < G.ROOM.T.h then
                        assert(SMODS.change_base(G.pack_cards.cards[1] , nil, 'onio_Effigy'))
                        G.pack_cards.cards[1]:juice_up(0.3, 0.5)
                        return true
                    end
                end
                }))
            end


        end

        if card.ability.upgrade_level == 0 then
            if context.individual and context.cardarea == G.play then
                if context.other_card:get_id() == 15  then
                    return {
                        mult = 5,
                    }
                end
            end
        end

        if card.ability.upgrade_level == 1 then
            if context.individual and context.cardarea == G.play then
                if context.other_card:get_id() == 15 then
                    local count = 0
                    if G.deck then
                        for i = 1, #G.playing_cards do
                            if G.playing_cards[i]:get_id() == 15 then count = count + 1 end
                        end
                    end
                    return {
                        mult = count,
                    }
                end
            end
        end

        if card.ability.upgrade_level == 2 then
            if context.individual and context.cardarea == G.play then
                if context.other_card:get_id() == 15  then
                    return {
                        mult = 15,
                        dollars= 1
                    }
                end
            end
        end

        if card.ability.upgrade_level == 3 then
            if context.individual and context.cardarea == G.play then
                if context.other_card:get_id() == 15  then
                    return {
                        mult = 20,
                        dollars= 1,
                        xmult = 1.25
                    }
                end
            end
        end

        if card.ability.upgrade_level == 4 then
            if context.individual and context.cardarea == G.play then
                if context.other_card:get_id() == 15  then
                    return {
                        mult = 20,
                        dollars= 2,
                        xmult = 1.5
                    }
                end
            end

            if context.individual and context.cardarea == G.hand then
                if context.other_card:get_id() == 15  then
                    return {
                        
                        mult = ternary(context.end_of_round,0,10),
                        dollars= 1,
                        xmult = ternary(context.end_of_round,1,1.25)
                    }
                end
            end
        end

        if card.ability.upgrade_level >= 2 and card.ability.upgrade_level <= 4 then
            if context.joker_main then
                local count = 0
                    if G.deck then
                        for i = 1, #G.playing_cards do
                            if G.playing_cards[i]:get_id() == 15 then count = count + 1 end
                        end
                    end
                return {
                    xmult = 1 + (0.05 * count),
                }
            end

        end

        if card.ability.upgrade_level == 5 then
            if context.individual and (context.cardarea == G.play or context.cardarea == G.hand) then
                if context.other_card:get_id() == 15 then
                    return {
                        mult = ternary(context.end_of_round,0,20),
                        dollars= 2,
                        xmult = ternary(context.end_of_round,1,2)
                    }
                end
            end

            if context.joker_main then
                local count = 0
                    if G.deck then
                        for i = 1, #G.playing_cards do
                            if G.playing_cards[i]:get_id() == 15 then count = count + 1 end
                        end
                    end
                return {
                    xmult = 1 + (0.05 * count * ternary(card.ability.upgrade_level == 5,2,1)),
                    xchips = 1 + (0.05 * count * ternary(card.ability.upgrade_level == 5,2,1)),
                }
            end
        end

	end
}

--BSTRD font
SMODS.Font {
    key="bstrd_font",
    path = "bstrd_font.ttf",
    render_scale = 200,
    TEXT_HEIGHT_SCALE = 0.83,
    TEXT_OFFSET = {x=0,y=0},
    FONTSCALE = 0.1,
    squish = 1,
    DESCSCALE = 1
}

--BSTRD
SMODS.Joker {
	key = 'bstrd',
	loc_txt = {
		name = '{f:onio_bstrd_font,V:1,s:1.5}BSTRD',
		text = {
			"Copies {C:attention}#1#%{} all of the {C:chips}Chips{}",
            "from other Jokers as {C:mult}Mult{}",
            "{C:attention}+#2#%{} when boss blind is defeated",
            "{C:inactive}(Max of {C:attention}#3#%{C:inactive})"
		}
	},
	config = { extra = {active = false,percentage = 0.5,gain=0.1,max=2}},
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
            100 * card.ability.extra.percentage,
            100 * card.ability.extra.gain,
            100 * card.ability.extra.max,
            colours = {
                HEX('ff0066')
            }
        } }
	end,
	calculate = function(self,card,context)
        
        if context.end_of_round and context.cardarea == G.jokers and not context.blueprint and G.GAME.blind.boss then
            card.ability.extra.percentage = math.min(card.ability.extra.max,card.ability.extra.percentage + card.ability.extra.gain)
            return {
                message = "Upgraded!"
            }
        end

		if card.ability.extra.active and not context.repetition then

            local gains = {}

			for _, j in ipairs(G.jokers.cards) do
				if j.config.center.blueprint_compat and j.ability.name ~= 'BSTRD' and j.ability.name ~= 'Blueprint' and j.ability.name ~= 'Brainstorm' then -- bp effects create infinite feedback loops if we try copy them...
                    context.blueprint = nil
					local ret = SMODS.blueprint_effect(card, j, context)
					if ret then
                        local c = tonumber(ret.chips or ret.chip_mod)
                        if c then
                            local chip_effect = math.max(1,card.ability.extra.percentage * c)
                            if chip_effect then
                                gains[#gains+1] = {mult = chip_effect}
                            end
                        end
					end
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

        if context.setting_blind then
			card.ability.extra.active = true
		end
		if context.end_of_round then
			card.ability.extra.active = false
		end


	end,
}

--velzies glee
SMODS.Joker {
	key = 'velzies_glee',
	loc_txt = {
		name = 'Velzies Glee',
		text = {
            "{C:attention}Reroll{} the boss blind every {C:attention}15",
            "{C:attention}frames{} while selecting a blind",
            "{X:money,C:white}X#1#{} initial boss reward {C:money}${}."
		}
	},
	config = { extra = {money_mult=2,active = true,ticker = 0}},
    unlocked = true,
    discovered = true,
    blueprint_compat = false, 
    perishable_compat = true,
    eternal_compat = true,
	rarity = 3,
	atlas = 'OnionJokers',
	pos = { x = 1, y = 4 },
    soul_pos ={
        x = 2,
        y = 4,
        draw = function(self, card, layer)
            self.children.floating_sprite:draw_shader(
                'booster',
                nil,
                self.ARGS.send_to_shader,
                nil,
                self.children.center
            )
        end,
    },
    --draw = function(self, card, layer)
    --    card.children.center:draw_shader('negative', nil, card.ARGS.send_to_shader)
    --end,
	cost = 6,
    loc_vars = function(self, info_queue, card)
		return { vars = {card.ability.extra.money_mult} }
	end,
    update = function(self, card, dt)
        if next(SMODS.find_card("j_onio_velzies_glee")) and G.blind_select and G.blind_select.VT.y < 10 and G.GAME and card.ability.extra.active then
            if G.GAME.round_resets then
                if G.GAME.round_resets.blind_choices then
                    card.ability.extra.ticker = card.ability.extra.ticker + 1
                    if card.ability.extra.ticker >= 15 then
                        card.ability.extra.ticker = 0
                        --G.from_boss_tag = true
                        --G.FUNCS.reroll_boss()
                        --print(G.GAME.round_resets)
                        --G.GAME.round_resets.blind_choices["Boss"] = get_new_boss()
                        manual_boss_reroll()
                    end
                end
            end
        end
    end,
	calculate = function(self, card, context)

        if context.setting_blind and not context.blueprint then
            card.ability.extra.active = false
            if G.GAME.blind.boss then
                G.GAME.blind.dollars = G.GAME.blind.dollars * card.ability.extra.money_mult
                SMODS.juice_up_blind()
                return {
                    card = card,
                    message = "X"..tostring(card.ability.extra.money_mult).." Reward!",
                }
            end
        end

		if context.end_of_round then
			card.ability.extra.active = true
		end

	end
}

function manual_boss_reroll()
    stop_use()
    G.GAME.round_resets.boss_rerolled = true
    G.from_boss_tag = nil
    --G.CONTROLLER.locks.boss_reroll = true
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
        play_sound('other1')
        --G.blind_select_opts.boss:set_role({xy_bond = 'Weak'})
        --G.blind_select_opts.boss.alignment.offset.y = 20
        return true
        end
    }))
    G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0.0025,
    func = (function()
        local par = G.blind_select_opts.boss.parent
        G.GAME.round_resets.blind_choices.Boss = get_new_boss()

        G.blind_select_opts.boss:remove()
        G.blind_select_opts.boss = UIBox{
        T = {par.T.x, 0, 0, 0, },
        definition =
            {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
            UIBox_dyn_container({create_UIBox_blind_choice('Boss')},false,get_blind_main_colour('Boss'), mix_colours(G.C.BLACK, get_blind_main_colour('Boss'), 0.8))
            }},
        config = {align="bmi",
                    offset = {x=0,y=G.ROOM.T.y + 0},--9},
                    major = par,
                    xy_bond = 'Weak'
                }
        }
        par.config.object = G.blind_select_opts.boss
        par.config.object:recalculate()
        G.blind_select_opts.boss.parent = par
        --G.blind_select_opts.boss.alignment.offset.y = 0
        
        G.E_MANAGER:add_event(Event({blocking = false, trigger = 'after', delay = 0.1,func = function()
            --G.CONTROLLER.locks.boss_reroll = nil
            return true
        end
        }))

        save_run()
        for i = 1, #G.GAME.tags do
        if G.GAME.tags[i]:apply_to_run({type = 'new_blind_choice'}) then break end
        end
        return true
    end)
    }))
end



