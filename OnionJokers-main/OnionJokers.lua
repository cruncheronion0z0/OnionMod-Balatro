--- STEAMODDED HEADER
--- MOD_NAME: OnionMod
--- MOD_ID: onionmod
--- MOD_AUTHOR: [onion]
--- MOD_DESCRIPTION: yeah thats stuff

----------------------------------------------
------------MOD CODE -------------------------

----- VERSION::1.0

assert(SMODS.load_file("src/blinds.lua"))()
assert(SMODS.load_file("src/decks.lua"))()
assert(SMODS.load_file("src/seals.lua"))()
assert(SMODS.load_file("src/enhancements.lua"))()
assert(SMODS.load_file("src/spectrals.lua"))()
assert(SMODS.load_file("src/planets.lua"))()
assert(SMODS.load_file("src/tarots.lua"))()
assert(SMODS.load_file("src/jokers.lua"))()
assert(SMODS.load_file("src/handtypes.lua"))()
assert(SMODS.load_file("src/tags.lua"))()
assert(SMODS.load_file("src/editions.lua"))()
assert(SMODS.load_file("src/vouchers.lua"))()
assert(SMODS.load_file("src/stickers.lua"))()
--assert(SMODS.load_file("src/corru_stuff.lua"))()
assert(SMODS.load_file("src/relics.lua"))()
assert(SMODS.load_file("src/boosters.lua"))()
assert(SMODS.load_file("src/multirank_testing.lua"))()
assert(SMODS.load_file("src/challenges.lua"))()

-- add joker_destroyed context
local card_remove_ref = Card.remove
function Card:remove()
    if self.area and (self.area == G.jokers) and not G.CONTROLLER.locks.selling_card then
        SMODS.calculate_context({ joker_destroyed = true, card_destroyed = self })
    end
    card_remove_ref(self)
end

SMODS.current_mod.optional_features = function()
    return {
        cardareas = {
            deck = true
        }
        --retrigger_joker = true
    }
end

--
local igo = Game.init_game_object
function Game:init_game_object()
    local ret = igo(self)
    ret.has_isabel_existed = { has = false }
    return ret
end

--------- UTIL FUNCS
function indexOf(array, value)
    for i, v in pairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function ternary(cond, T, F)
    if cond then return T else return F end
end

function bool_to_number(value)
    return value and 1 or 0
end

function get_rank_table()
    if (G.GAME.has_isabel_existed.has or next(SMODS.find_card("j_onio_isabel"))) then return { "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack",
            "Queen", "King", "Ace", "onio_Effigy" } end
    return { "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace" }
end

function get_suit_table()
    return { "Hearts", "Diamonds", "Clubs", "Spades" }
end

function get_rank_id_table()
    if (G.GAME.has_isabel_existed.has or next(SMODS.find_card("j_onio_isabel"))) then return { 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15 } end
    return { 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }
end

function sort_by_rank(a, b)
    local sorted_ranks = get_rank_id_table()
    local a_index = indexOf(sorted_ranks, a) or 99999
    local b_index = indexOf(sorted_ranks, b) or 99999
    return a_index < b_index
end

function get_keys(t)
    local keys = {}
    for key, _ in pairs(t) do
        keys[#keys + 1] = key
    end
    return keys
end

function fuzzy_equal(a, b, eps) return (math.abs(a - b) < eps) end

function round_to_multiple(number, multiple)
    if multiple == 0 then
        return 0
    end
    return math.floor((number / multiple) + 0.5) * multiple
end

function least_played_hand()
    local v = "High Card"
    local count = 9999
    local last = { order = 999 }
    for a, b in pairs(G.GAME.hands) do
        if b.played < count or (b.played == count and b.order >= last.order) then
            v = a
            count = b.played
            last = b
        end
    end
    return v
end

function most_played_hand()
    local v = "High Card"
    local count = -1
    local last = { order = 999 }
    for a, b in pairs(G.GAME.hands) do
        if b.played > count or (b.played == count and b.order >= last.order) then
            v = a
            count = b.played
            last = b
        end
    end
    return v
end

function clear_dupe_values(items)
    local new = {}
    for i = 1, #items do
        if indexOf(new, items[i]) == nil then new[#new + 1] = items[i] end
    end
    return new
end

function shuffle_table(t)

    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

function get_hands_contained(hand)
    local hands = { hand, "High Card" }

    if hand:find("Flush") ~= nil then
        hands[#hands + 1] = "Flush"
    end
    if hand:find("Five") ~= nil then
        hands[#hands + 1] = "Five of a Kind"
    end
    if hand:find("Straight") ~= nil or hand:find("Royal") ~= nil then
        hands[#hands + 1] = "Straight"
    end
    if hand:find("House") ~= nil then
        hands[#hands + 1] = "Full House"
        hands[#hands + 1] = "Two Pair"
        hands[#hands + 1] = "Three of a Kind"
    end

    if indexOf(hands, "Five of a Kind") ~= nil then
        hands[#hands + 1] = "Four of a Kind"
    end
    if indexOf(hands, "Four of a Kind") ~= nil then
        hands[#hands + 1] = "Three of a Kind"
    end
    if indexOf(hands, "Three of a Kind") ~= nil or indexOf(hands, "Two Pair") then
        hands[#hands + 1] = "Pair"
    end

    return clear_dupe_values(hands)
end

function non_stake_stickers()
    local h = {}
    for _,i in pairs(G.P_CENTER_POOLS["Stake"]) do
        h[#h+1] = string.lower(i.original_key)
    end
    local j = {}
    for _,i in pairs(get_keys(G.shared_stickers)) do
        if indexOf(h,string.lower(i)) == nil then
            j[#j+1] = i
        end
    end

    --for _, i in pairs(j) do
    --    print(i)
    --    info_queue[#info_queue+1] = G.shared_stickers[i]
    --end
    return j
end

--------- ATLASES (texture mapping)
SMODS.Atlas {
    key = "OnionJokers",
    path = "jokers.png",
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = "OnionSeals",
    path = "seals.png",
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = "OnionConsumeables",
    path = "consumeables.png",
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = "OnionDecks",
    path = "decks.png",
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = "OnionRanks",
    path = "effigies.png",
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = "OnionTags",
    path = "tags.png",
    px = 34,
    py = 34
}
SMODS.Atlas {
    key = "OnionStickers",
    path = "stickers.png",
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = "OnionBoosters",
    path = "boosters.png",
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = "OnionVouchers",
    path = "vouchers.png",
    px = 71,
    py = 95
}

--------- SHADERS:

SMODS.Shader {
    key = "ethereal",
    path = "ethereal.fs"
}

SMODS.Shader {
    key = "gilded",
    path = "gilded.fs"
}

--SMODS.DrawStep {
--    key = 'grayscale_step',
--    order = 999,
--    func = function(self, layer)
--        --print(self.ability.name)
--        --onio_monochrome
--        if self.ability.name == "Transparent" then
--            self.children.center:draw_shader('onio_monochrome', nil, self.ARGS.send_to_shader)
--        end
--    end,
--    conditions = {  vortex = false, facing = 'front' },
--}


SMODS.Seal:take_ownership('Gold',
    {
    draw = function(self, card, layer)
        local a = false
        if card.edition then
            if card.edition.key then
                if card.edition.key == "e_onio_gilded" then
                    a = true
                end
            end
        end
        if a then
            if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
                G.shared_seals[card.seal].role.draw_major = card
                G.shared_seals[card.seal]:draw_shader('onio_gilded', nil, card.ARGS.send_to_shader, nil, card.children.center)
            end
        else
            if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
                G.shared_seals[card.seal].role.draw_major = card
                G.shared_seals[card.seal]:draw_shader('dissolve', nil, nil, nil, card.children.center)
                G.shared_seals[card.seal]:draw_shader('voucher', nil, card.ARGS.send_to_shader, nil, card.children.center)
            end
        end
    end,
    },
    false
)


function negative_less_likely()
    return pseudorandom_element({true,false,false},pseudoseed("balancing jank"))
end

local gf = get_flush
function get_flush(hand)
  local ret = {}
  local four_fingers = next(find_joker('Four Fingers'))
  local suits = get_suit_table()
  if #hand > 5 or #hand < (5 - (four_fingers and 1 or 0)) then return ret else
    for j = 1, #suits do
      local t = {}
      local suit = suits[j]
      local flush_count = 0
      for i=1, #hand do
        if hand[i]:is_suit(suit, nil, true) or custom_is_flush_skip(hand[i]) then
            flush_count = flush_count + 1;
            t[#t+1] = hand[i]
        end 
      end
      if flush_count >= (5 - (four_fingers and 1 or 0)) then
        table.insert(ret, t)
        return ret
      end
    end
    return gf(hand)
  end
end

function custom_is_flush_skip(card)
    if next(SMODS.find_card("j_onio_skipping_stone")) and SMODS.has_enhancement(card, "m_stone") then return true end
    return 
end

local gs = get_straight
function get_straight(hand, min_length, skip, wrap)
    local ret = {}--gs(hand,min_length,skip,wrap)
    local four_fingers = next(find_joker('Four Fingers'))
    if #hand > 5 or #hand < (5 - (four_fingers and 1 or 0)) then
        return ret
    else
        local t = {}
        --in IDS, each key is a rank in hand, and each value of that rank is a table of all cards with that rank
        local IDS = {}
        --for every card in hand,
        for i = 1, #hand do
            -- if its got a valid id we add it to an array of each rank
            if not custom_is_straight_skip(hand[i]) then
                local id = hand[i]:get_id()
                if id > 1 and id < 15 then
                    if IDS[id] then
                        IDS[id][#IDS[id] + 1] = hand[i]
                    else
                        IDS[id] = { hand[i] }
                    end
                end
            end
        end

        local straight_length = 0
        local straight = false
        local can_skip = next(find_joker('Shortcut'))
        local skipped_rank = false
        local real_rank_yet = false


        local lowest_real_rank = 9999
        local gaps = {}
        local used_gaps = 0
        local used_gaps_log = {}
        for _, a in pairs(hand) do
            if custom_is_straight_skip(a) then gaps[#gaps+1] = a else
                lowest_real_rank = math.min(lowest_real_rank,a:get_id())
            end
        end

        if #gaps >= (5 - (four_fingers and 1 or 0)) then return {hand} end


        --staight eval, for every rank 2-A...
        for j = 1, 14 do
            --check if the rank is in the played hand
            --this is normal straight behaviour
            if IDS[j == 1 and 14 or j] then
                -- tick stright & reset skip check
                straight_length = straight_length + 1
                skipped_rank = false
                real_rank_yet = true
                -- add all cards of the current rank to the scored hand
                -- the current rank in the played hand (inc, self)
                for k, v in ipairs(IDS[j == 1 and 14 or j]) do
                    if indexOf(used_gaps_log,v) == nil then
                        t[#t + 1] = v
                    end
                end
            elseif can_skip and not skipped_rank and j ~= 14 then
                --if we can skip and the rank is not Ace, so no skipping through the K-A-2
                skipped_rank = true
                real_rank_yet = true
            else

                --next card real fix
                if j < lowest_real_rank then real_rank_yet = false end

                if #gaps > 0 and used_gaps < #gaps and real_rank_yet then
                    straight_length = straight_length + 1
                    used_gaps = used_gaps + 1
                    t[#t+1] = gaps[used_gaps]
                    used_gaps_log[#used_gaps_log+1] = gaps[used_gaps]
                    skipped_rank = false
                    real_rank_yet = true
                else
                    --no skip, rank not in hand, no custom check, cancel straight.
                    straight_length = 0
                    skipped_rank = false
                    if not straight then t = {} end
                end

                --if not straight then t = {} end
                if straight then break end
                
            end


            --straight len is cut off if a non-skip non-next-rank card is scored, so we chill
            if straight_length >= (5 - (four_fingers and 1 or 0)) then straight = true end
        end
        --print(tprint(ret))
        if not straight then return ret end
        table.insert(ret, t)
        if t == {} or ret == {} or ret == {{}} then return gs(hand, min_length, skip, wrap) end
        return ret
    end
end

function custom_is_straight_skip(card)
    if next(SMODS.find_card("j_onio_hangman")) and card:is_face() then return true end
    if SMODS.has_enhancement(card, "m_onio_skip") then
        return true
    end
    if next(SMODS.find_card("j_onio_skipping_stone")) and SMODS.has_enhancement(card, "m_stone") then return true end
    return false
end

function is_straight(hand, min_length, skip, wrap)
    if #get_straight(hand, min_length, skip, wrap) > 0 then return true end
    return false
end

local card_is_face_ref = Card.is_face
function Card:is_face(from_boss)
    if G.GAME.selected_back.name == "Concrete Deck"  and SMODS.has_enhancement(self, "m_stone") then return true end
    if self.ability.onio_smile then return true end
    return card_is_face_ref(self, from_boss) or (self:get_id() and next(SMODS.find_card("j_vremade_pareidolia")))
end

local card_is_suit_ref = Card.is_suit
function Card:is_suit(suit, bypass_debuff, flush_calc)
    local ret = card_is_suit_ref(self, suit, bypass_debuff, flush_calc)

    --if not ret and self:get_id() == 11 and next(SMODS.find_card("j_onio_jack_all_trades")) then return true end

    if not ret and not SMODS.has_no_suit(self) and next(SMODS.find_card("j_smeared")) and next(SMODS.find_card("j_onio_c_blind")) then
        return true
    end

    if not ret and not SMODS.has_no_suit(self) and next(SMODS.find_card("j_smeared")) then
        return SMODS.smeared_check(self, suit)
    end
    if not ret and not SMODS.has_no_suit(self) and next(SMODS.find_card("j_onio_c_blind")) then
        return c_blind_check(self, suit)
    end

    return ret
end

function c_blind_check(card, suit)
    if ((card.base.suit == 'Hearts' or card.base.suit == 'Clubs') and (suit == 'Hearts' or suit == 'Clubs')) then
        return true
    end
    return false
end

function reverse_table_num(t)
    local new = {}
    for i = 1,#t do
        new[#new+1] = t[(#t-i)+1]
    end
    return new
end

G.FUNCS.onio_activate = function(e)

    for i=1,#G.jokers.cards do
        G.jokers.cards[i]:highlight(false)
    end

    local card = e.config.ref_table
    --card:highlight(false)
    card.highlighted = false
    e.config.ref_table.ability.extra.page =  e.config.ref_table.ability.extra.page + 1
    if e.config.ref_table.ability.extra.page >  e.config.ref_table.ability.extra.page_count then
         e.config.ref_table.ability.extra.page = 1
    end
end

G.FUNCS.onio_can_activate = function(e)
    
    local disable = true
    if e.config.ref_table.ability then
        if e.config.ref_table.ability.extra then
            if e.config.ref_table.ability.extra.page ~= nil then
                e.config.colour = G.C.PURPLE
                e.config.button = 'onio_activate'
                disable = false
            end
        end
    end

    if disable then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end


end

local card_highlight_ref = Card.highlight
function Card:highlight(is_highlighted)
    if self.config.center_key == "j_onio_tenna" then 
        self.highlighted = is_highlighted
        if self.highlighted then


            
            self.children.use_button = UIBox({
                definition = create_sell_and_use_buttons(self, { sell = true, activate = true }),
                config = {
                    align = "cr",
                    offset = { x = -0.4, y = 0 },
                    parent = self
                }
            })
        elseif self.children.use_button then
            self.children.use_button:remove()
            self.children.use_button = nil
        end
    else
        card_highlight_ref(self, is_highlighted)
    end
end

function create_sell_and_use_buttons(card, args)
    local args = args or {}
    local sell = nil
    local activate = nil

    if args.sell then
        sell = {
            n = G.UIT.C,
            config = { align = "cr" },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { ref_table = card, align = "cr", padding = 0.1, r = 0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'sell_card', func = 'can_sell_card', handy_insta_action = "sell" },
                    nodes = {
                        { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                        {
                            n = G.UIT.C,
                            config = { align = "tm" },
                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", maxw = 1.25 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = localize('b_sell'), colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true } }
                                    }
                                },
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm" },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = localize('$'), colour = G.C.WHITE, scale = 0.4, shadow = true } },
                                        { n = G.UIT.T, config = { ref_table = card, ref_value = 'sell_cost_label', colour = G.C.WHITE, scale = 0.55, shadow = true } }
                                    }
                                }
                            }
                        }
                    }
                },
            }
        }
    end
    if args.activate then
        activate = {
            n = G.UIT.C,
            config = { align = "cr" },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { ref_table = card, align = "cr", padding = 0.1, r = 0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.TAROT, one_press = true, button = 'onio_activate', func = 'onio_can_activate', handy_insta_action = "use" },
                    nodes = {
                        { n = G.UIT.B, config = {colour = G.C.TAROT, w = 0.1, h = 0.6 } },
                        {
                            n = G.UIT.C,
                            config = {colour = G.C.TAROT, align = "tm" },
                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", maxw = 1.25 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = 'Page', colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true } }
                                    }
                                },
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm" },
                                    nodes = {
                                        { n = G.UIT.T, config = { ref_table = card.ability.extra, ref_value = 'page', colour = G.C.WHITE, scale = 0.55, shadow = true } },
                                        { n = G.UIT.T, config = { text = "/", colour = G.C.WHITE, scale = 0.4, shadow = true } },
                                        { n = G.UIT.T, config = { ref_table = card.ability.extra, ref_value = 'page_count', colour = G.C.WHITE, scale = 0.55, shadow = true } }
                                    }
                                }
                            }
                        }
                    }
                },
            }
        }
    end

    return {
        n = G.UIT.ROOT,
        config = {
            align = "cr",
            padding = 0,
            colour = G.C.CLEAR
        },
        nodes = {
            {
                n = G.UIT.C,
                config = { padding = 0.15, align = 'cl' },
                nodes = {
                    sell and {
                        n = G.UIT.R,
                        config = { align = 'cl' },
                        nodes = { sell }
                    } or nil,
                    activate and {
                        n = G.UIT.R,
                        config = { align = 'cl' },
                        nodes = { activate }
                    } or nil,
                }
            }
        }
    }
end

--packception data/ func inject
local igo = Game.init_game_object
function Game:init_game_object()
    local ret = igo(self)
    ret.packception = { ative = false, prior = {} }
    ret.blocklist = { keys = {} }
    return ret
end

--filter ownership common decreasing
SMODS.Rarity:take_ownership('Common',
    {
    get_weight = function(self, weight, object_type)
        if G.GAME.used_vouchers.v_onio_decontamination then
            return 0
        end
        if G.GAME.used_vouchers.v_onio_filter then
            return weight * 0.5
        else
            return weight
        end
    end
    },
    false
)

SMODS.Sticker:take_ownership('eternal',
    {
    should_apply = function(self, card, center, area, bypass_roll)
        print( G.shared_stickers['eternal'].config)
        local t = pseudorandom("1") < 0.3--G.shared_stickers['eternal'].config.rate
        local t2 = pseudorandom("1") < 0.075
        if G.GAME.modifiers.enable_eternals_in_shop and not card.perishable and card.config.center.eternal_compat then
            print(G.GAME.used_vouchers.v_onio_decontamination)
            if ternary(G.GAME.used_vouchers.v_onio_decontamination,t2,t) then
                return true
            end
        end
        return false
    end
    },
    false
)
SMODS.Sticker:take_ownership('perishable',
    {
    should_apply = function(self, card, center, area, bypass_roll)
        local t = pseudorandom("2") < 0.3--G.shared_stickers['perishable'].config.rate
        local t2 = pseudorandom("1") < 0.075
        if G.GAME.modifiers.enable_perishables_in_shop and not card.eternal and card.config.center.perishable_compat then
            print(G.GAME.used_vouchers.v_onio_decontamination)
            if ternary(G.GAME.used_vouchers.v_onio_decontamination,t2,t) then
                return true
            end
        end
        return false
    end
    },
    false
)
SMODS.Sticker:take_ownership('rental',
    {
    should_apply = function(self, card, center, area, bypass_roll)
        local t = pseudorandom("3") < 0.3--G.shared_stickers['rental'].rate
        local t2 = pseudorandom("1") < 0.075
        if G.GAME.modifiers.enable_rentals_in_shop and card.ability.set == 'Joker' then
            print(G.GAME.used_vouchers.v_onio_decontamination)
            if ternary(G.GAME.used_vouchers.v_onio_decontamination,t2,t) then
                return true
            end
        end
        return false
    end
    },
    false
)


function custom_can_open(card)
    print("can open check!")
    print(ternary(G.booster_pack,"pack exists","no pack"))
    print(ternary(G.GAME.packception.active,"packception active", "packception not active"))
    card.draw_hand = true
    if G.GAME.used_vouchers.v_onio_packception then
        if card.ability.from_packception then
            print("can open trig")
            print(ternary(card == G.booster_pack,"!!! =","!!! !="))
            print("switch")
            G.GAME.packception.prior = G.booster_pack
            G.booster_pack:remove()
            G.booster_pack = nil
            G.booster_pack = card
            print(ternary(card == G.booster_pack,"!!! =","!!! !="))
            --stop_use()
            --card:explode()
            --card.ability.from_pack:remove()
            --card:remove()
            --card = nil 
            --G.FUNCS.toggle_shop()
            --G.FUNCS.toggle_shop()
            --G.FUNCS.end_consumeable()
            --force_end_pack(card.ability.from_pack)
            ---G.FUNCS.skip_booster()
            delay(1.0)

            return true
        end
    end

    return true
end

function custom_consumeable_end()
    print("consume ended check!")
    print("vvvvvvvvvvv")
    print(ternary(G.booster_pack,"pack exists","no pack?"))
    print(ternary(G.GAME.packception.active,"packception active", "packception not active"))
    print(ternary(G.shop,"yes shop", "no shop???"))
    if G.GAME.packception.active then
        G.GAME.packception.active = false
        --print(inspect(G.GAME.packception.prior))
        stop_use()
        print("panic")
        G.booster_pack = G.GAME.packception.prior
        G.GAME.packception.prior = nil
        
        --print(#G.booster_pack)
        --force_end_pack(G.booster_pack)
        --G.CONTROLLER.interrupt.focus = true
        --G.booster_pack:remove()
        --G.booster_pack = 
        --force_end_pack(G.booster_pack)
        --G.FUNCS.skip_booster()

        return true
        
    end
end

function force_end_pack(pack)

    print("panicresult")

    G.CONTROLLER.locks.use = false
    G.TAROT_INTERRUPT = nil
    --G.FUNCS.toggle_shop()

    --print(get_keys(G.FUNCS))
    
    if G.booster_pack_sparkles then G.booster_pack_sparkles:fade(1) end
    if G.booster_pack_stars then G.booster_pack_stars:fade(1) end
    if G.booster_pack_meteors then G.booster_pack_meteors:fade(1) end
    --G.booster_pack.alignment.offset.y = G.ROOM.T.y + 9

    G.E_MANAGER:add_event(Event({trigger = 'after',delay = 1,blocking = false, blockable = false,
    func = function()
    if G.booster_pack_sparkles then G.booster_pack_sparkles:remove(); G.booster_pack_sparkles = nil end
    if G.booster_pack_stars then G.booster_pack_stars:remove(); G.booster_pack_stars = nil end
    if G.booster_pack_meteors then G.booster_pack_meteors:remove(); G.booster_pack_meteors = nil end
    return true
    end}))
end



