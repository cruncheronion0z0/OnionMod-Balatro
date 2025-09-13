--------- DECKS:

--- everchanging deck
SMODS.Back {
    name = "everchanging Deck",
    key = "everchanging_Deck",
    atlas = 'OnionDecks',
    pos = { x = 2, y = 3 },
    config = {},
    loc_txt = {
        name = "Everchanging Deck",
        text = {
            "Half of the starting",
            "cards have {C:green,T:s_onio_cycle_seal}Cycle{} seals.",
            "Start with {C:attention}2{} of each rank",
            "spread across all suits"
        },
    },
    apply = function()
        G.E_MANAGER:add_event(Event({
            func = function()

                local saved = {}
                local rank_count = {}
                for i=2,14 do
                    rank_count[i] = 0
                end
                for i = 1, #G.playing_cards do
                    -- indexOf(saved,G.playing_cards[i]:get_id()) == nil
                    if rank_count[G.playing_cards[i]:get_id()] < 2 then
                        --G.playing_cards[i]:set_seal("onio_cycle_seal", nil, true)
                        saved[#saved+1] = G.playing_cards[i]
                        rank_count[G.playing_cards[i]:get_id()] = rank_count[G.playing_cards[i]:get_id()] + 1
                    else
                        G.playing_cards[i]:start_dissolve()
                    end
                    
                end

                local s_table = get_suit_table()

                s_table = shuffle_table(s_table)

                local j = 1
                for i=1,#saved do
                    SMODS.change_base(saved[i], s_table[j])
                    j = j + 1
                    if j > #s_table then
                        j = 1
                    end
                end

                local alt = 0
                saved = shuffle_table(saved)
                for i=1,#saved do
                    if alt == 1 then
                        saved[i]:set_seal("onio_cycle_seal", nil, true)
                        alt = 0
                    else
                        alt = 1
                    end
                end

                G.GAME.starting_deck_size = 26

                return true
            end
        }))
    end
}

--- concrete deck
SMODS.Back {
    name = "Concrete Deck",
    key = "concrete_Deck",
    atlas = 'OnionDecks',
    pos = { x = 1, y = 0 },
    config = {},
    loc_txt = {
        name = "Concrete Deck",
        text = {
            "All starting face cards",
            "are {C:attention}stone cards{}.",
            "{C:attention}Stone cards{} count",
            "as face cards"
        },
    },
    apply = function()
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = #G.playing_cards, 1, -1 do
                    if G.playing_cards[i]:get_id() >= 11 and G.playing_cards[i]:get_id() <= 13 then
                        G.playing_cards[i]:set_ability(G.P_CENTERS.m_stone)
                    end
                end
                return true
            end
        }))
    end
}

--- echo deck
SMODS.Back {
    name = "Echo Deck",
    key = "echo_deck",
    atlas = 'OnionDecks',
    pos = { x = 6, y = 1 },
    config = { hand_size = -1, ante_bonus = 1, current_card = {}, tick = true },
    loc_txt = {
        name = "Echo Deck",
        text = {
            "{C:attention}#1#{} Starting Hand Size.",
            "{C:attention}+#2#{} Hand Size every 2 {C:attention}Antes{}.",
            "All {C:attention}discarded{} cards are",
            "returned to the deck."
        },
    },
    loc_vars = function(self, info_queue, back)
        return { vars = { self.config.hand_size, self.config.ante_bonus, self.config.current_card, self.config.tick } }
    end,
    calculate = function(self, back, context)
        if context.discard then
            if self.config.current_card ~= context.other_card then
                self.config.current_card = context.other_card
                G.FUNCS.draw_from_discard_to_deck(1)
            end
        end

        if context.round_eval and G.GAME.last_blind and G.GAME.last_blind.boss then
            self.config.tick = not self.config.tick
            if self.config.tick then
                G.hand:change_size(self.config.ante_bonus)
                return {
                    message = "+1 Hand Size"
                }
            end
        end
    end
}

--- scavanged deck
SMODS.Back {
    name = "Scavenged Deck",
    key = "scavenged_deck",
    atlas = 'OnionDecks',
    pos = { x = 3, y = 2 },
    config = {},
    loc_txt = {
        name = "Scavenged Deck",
        text = {
            "Start with {C:attention}10{} cards",
            "and {C:attention}4 Standard Tags{}.",
            "Create {C:attention}2 Standard Tags{}",
            "after every {C:attention}boss blind{}"
        },
    },
    loc_vars = function(self, info_queue, back)
        --info_queue[#info_queue + 1] = G.P_CENTERS.p_standard_mega_1
        return { vars = {} }
    end,
    apply = function()
        G.E_MANAGER:add_event(Event({
            func = function()
                local count = 0
                local log = {}
                while #G.playing_cards - count > 10 do
                    local a = pseudorandom_element(G.playing_cards, pseudoseed("eatcard" .. tostring(count)))
                    while indexOf(log, a) ~= nil do
                        a = pseudorandom_element(G.playing_cards,
                            pseudoseed("eatcard" .. tostring(indexOf(log, a) + #a + count)))
                    end
                    log[#log + 1] = a
                    a:start_dissolve()
                    count = count + 1
                end
                add_tag(Tag('tag_standard'))
                add_tag(Tag('tag_standard'))
                add_tag(Tag('tag_standard'))
                add_tag(Tag('tag_standard'))
                G.GAME.starting_deck_size = 10
                return true
            end
        }))
    end,
    calculate = function(self, back, context)
        if context.round_eval then
            if G.GAME.last_blind and G.GAME.last_blind.boss then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        add_tag(Tag('tag_standard'))
                        add_tag(Tag('tag_standard'))
                        play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                        return true
                    end
                }))
            end
        end
    end
}

--- discardeck
SMODS.Back {
    name = "Discardeck",
    key = "discardeck",
    atlas = 'OnionDecks',
    pos = { x = 2, y = 2 },
    config = {limit=3,discards = -1,carryover = 0},
    loc_txt = {
        name = "Discardeck",
        text = {
            "{C:red}#2# discards{} per round",
            "{C:attention}+#1#{} {C:red}discard{} selection limit",
            "Unused {C:red}discards{} are carried",
            "over into the {C:attention}next blind",
            "{C:inactive}(Currently {C:red}+#3# discards{C:inactive})"
        },
    },
    loc_vars = function(self, info_queue, back)
        --info_queue[#info_queue + 1] = G.P_CENTERS.p_standard_mega_1
        return { vars = {self.config.limit, self.config.discards,self.config.carryover} }
    end,
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                SMODS.change_discard_limit(self.config.limit)
                self.config.carryover = 0
                return true
            end
        }))
    end,
    calculate = function(self, back, context)
        if context.round_eval then
            G.E_MANAGER:add_event(Event({
                func = function()
                    --G.GAME.round_resets.discards = G.GAME.round_resets.discards - self.config.carryover
                    self.config.carryover = G.GAME.current_round.discards_left
                    play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                    return true
                end
            }))
            return {
                message = tostring(G.GAME.current_round.discards_left).." Carryover!",
                colour = G.C.RED
            }
        end
        if context.setting_blind then
            G.E_MANAGER:add_event(Event({
                func = function()
                    --G.GAME.round_resets.discards = G.GAME.round_resets.discards + self.config.carryover
                    G.GAME.current_round.discards_left = G.GAME.round_resets.discards
                    play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                    return true
                end
            }))
            ease_discard(self.config.carryover)
            return {
                message = "+"..tostring(self.config.carryover).." Discards!",
                colour = G.C.RED
            }
        end
    end
}

--testin zone
--SMODS.Back {
--    name = "testerrr",
--    key = "testerrr",
--    atlas = 'OnionDecks',
--    loc_txt = {
--        name = "testerrrr",
--        text = {
--            "Start"
--        },
--       },
--    pos = { x = 6, y = 0 },
--    config = {dollars = 999999999 },
--    unlocked = true,
--    loc_vars = function(self, info_queue, back)
--        return { vars = { "32", self.config.consumable_slot } }
--    end
--}


