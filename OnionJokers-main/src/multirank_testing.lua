
--CODE STOLEN FROM MULTIPLAYER MOD'S GRADIENT DECK, SO I COULD FIGURE
--OUT HOW MULTIRANK CARDS WORK, HOLY SHIT WHY DOES THIS WORK AT ALL WHAT.
--thanks for writing the code! i mean i didnt steal it fully, i just
--used that to figure out how it was done

--illusion cards
SMODS.Enhancement {
    name = "IllusionCard",
    key = "illusion",
    badge_colour = HEX("6a57e6"),
	config = {},
    loc_txt = {
        label = 'Illusion Card',
        name = 'Illusion Card',
         text = {
            'counts as any {C:attention}rank',
            "for all {C:attention}Joker{} effects"
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,
    atlas = 'OnionDecks',
    pos = {x=0, y=1}
}

--jack of all trades
SMODS.Joker {
    key = 'jack_all_trades',
    loc_txt = {
        name = 'Jack of all trades',
        text = {
            '{C:attention}Jacks{} count as any {C:attention}rank',
            "for all {C:attention}Joker{} effects"
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
		return { vars = {} }
	end,
}

local function card_anyrank_check(card)
	if next(find_joker('j_onio_jack_all_trades')) and (card.orig_id == 11 or card.base.id == 11) then return true end
	if SMODS.has_enhancement(card, "m_onio_illusion") then return true end
	return false
end

-- water is wet
local function set_temp_id(card, key)
	if not card.orig_id then card.orig_id = card.base.id end
	--card.base.id = card.orig_id + G.CARD_ALL_RANKS
	card.base.id = G.CARD_ALL_RANKS

	if key ~= "j_raised_fist" then -- otherwise it gets confused and triggers a second card
		if card.base.id == 15 then
			card.base.id = 2
		elseif card.base.id == 1 then
			card.base.id = 14
		end
	end
end

-- if code runs twice it needs a func ig
local function reset_ids()
	if G.CARD_ALL_RANKS then
		G.CARD_ALL_RANKS = nil
		for i, card in ipairs(G.playing_cards) do
			card.base.id = card.orig_id
			card.orig_id = nil
		end
	end
end

local function get_bp(joker)
	local key = joker.config.center.key
	local count = 0
	local pos = 0
	for i, v in ipairs(G.jokers.cards) do
		if v == joker then pos = i end
	end
	while (key == "j_blueprint" or key == "j_brainstorm") and count <= #G.jokers.cards do
		if key == "j_blueprint" then
			key = G.jokers.cards[pos + 1] and G.jokers.cards[pos + 1].config.center.key or "NULL"
			pos = pos + 1
		elseif key == "j_brainstorm" then
			key = G.jokers.cards[1].config.center.key
			pos = 1
		end
		count = count + 1
	end
	return key
end

-- hardcoded dumb stuff, because cards that could trigger but don't due to rng are dumb and stupid and don't return anything
-- ALSO i have to add a whole get blueprint key thing (above) it's so stupid
-- all this to avoid lovely patching? who cares
local function valid_trigger(card, joker)
	local key = joker.config.center.key
	key = get_bp(joker)
	local function rank_check(ranks)
		for i, v in ipairs(ranks) do
			if card:get_id() == v then return true end
		end
		return
	end
	if key == "j_8_ball" then
		return rank_check({ 9, 8, 7 }) -- i don't know if this is necessary? just prevents extra checks ig
	elseif key == "j_business" or key == "j_reserved_parking" then
		return card:is_face()
	elseif key == "j_bloodstone" or key == "j_mp_bloodstone" or key == "j_mp_bloodstone2" then
		return card:is_suit("Hearts")
	end
end

-- hardcoded functions because honk shoo
local function passkey(joker)
	local key = get_bp(joker)
	if key == "j_superposition" or key == "j_sixth_sense" then return true end
	return false
end
local function blacklist(joker)
	local key = get_bp(joker)
	if key == "j_photograph" or key == "j_faceless" then return true end
	return false
end

-- infamous calculate joker hook
local calculate_joker_ref = Card.calculate_joker
function Card:calculate_joker(context)
	if not context.blueprint then -- very important because bloopy recursively calls this
        --G.GAME.modifiers.card_all_ranks and
		if (context.other_card or passkey(self)) and not blacklist(self) then
			for j = 2, 14 do
				--G.CARD_ALL_RANKS = -card.orig_id + i
                -- -i + 2
                --G.CARD_ALL_RANKS = 11 - i
                --print("!!!!!!!!!!----------------------")
				for i, card in ipairs(G.playing_cards) do -- it's actually insane that this doesn't blow up the game??? this is being run thousands of times wastefully
                    G.CARD_ALL_RANKS = card.orig_id or card.base.id
                    if card_anyrank_check(card) then
                        G.CARD_ALL_RANKS = j
						-- -card.base.id + j
                    end
                    --print(tostring(card.base.id).."+"..tostring(G.CARD_ALL_RANKS).."="..tostring(card.base.id + G.CARD_ALL_RANKS))
					set_temp_id(card, self.config.center.key)
				end
				local ret, post = calculate_joker_ref(self, context)
				if ret or post or valid_trigger(context.other_card, self) then
					reset_ids()
					return ret, post
				end
			end
			reset_ids()
		end
	end
	return calculate_joker_ref(self, context)
end

-- a special hardcoded hook just for cloud nine! hook hook, hooray!
local update_ref = Card.update
function Card:update(dt)
	local ret = update_ref(self, dt)
	--if G.GAME.modifiers.card_all_ranks then
	if self.ability.name == "Cloud 9" and next(find_joker('cloud_9')) then
		self.ability.nine_tally = 0
		for k, v in pairs(G.playing_cards) do
			local id = v:get_id()
			if card_anyrank_check(v) or id == 9 then
				self.ability.nine_tally = self.ability.nine_tally + 1
			end
		end
	end
	--end
end