
--fragile
SMODS.Sticker {
    key = "fragile",
    badge_colour = HEX 'b18f43',
    loc_txt = {
		name = 'Fragile',
        label = 'Fragile',
		text = {
			"{C:red}Destroyed{} at end of round",
            "{C:attention}On playing cards:{} also {C:red}destroyed",
            "after played or discarded"
		}
	},
    atlas = 'OnionStickers',
    pos = { x = 0, y = 2 },
    should_apply = function(self, card, center, area, bypass_roll)
        return false
    end,
    apply = function(self, card, val)
        card.ability[self.key] = val
        print("fragile")
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.rental_rate or 1 } }
    end,
    calculate = function(self, card, context)

        if context.end_of_round and not context.repetition and not context.individual then
            card_eval_status_text(card, 'jokers', 1, nil, nil, {message = "Destroyed!", colour = G.C.RED})
            G.E_MANAGER:add_event(Event({
                func = function()
                    card:start_dissolve()
                    G.jokers:remove_card(card)
                    G.deck:remove_card(card)
                    G.consumeables:remove_card(card)
                    return true
                end
            }))
        end
        if context.end_of_round and not context.repetition and context.individual then
            --card:start_dissolve()
            if indexOf(G.hand.cards,card) ~= nil then
                --G.hand:remove_card(card)
                --card_eval_status_text(card, 'jokers', 1, nil, nil, {message = "Destroyed!", colour = G.C.RED})
                G.E_MANAGER:add_event(Event({
                func = function()
                    card:start_dissolve()
                    G.hand:remove_card(card)
                    return true
                end
            }))
            end
        end
        if context.discard then
            if context.other_card == card then
                card_eval_status_text(card, 'jokers', 1, nil, nil, {message = "Destroyed!", colour = G.C.RED})
                return {
                    remove = true
                }
            end
        end
        if context.destroy_card and (context.cardarea == G.play or context.cardarea == "unscored") and context.destroy_card == card then
            card_eval_status_text(card, 'jokers', 1, nil, nil, {message = "Destroyed!", colour = G.C.RED})
            return {remove = true}
        end
    end
}

--smile
SMODS.Sticker {
    key = "smile",
    badge_colour = HEX 'b18f43',
    loc_txt = {
		name = 'Smile',
        label = 'Smile',
		text = {
			"This card counts as a {C:attention}face{} card"
		}
	},
    atlas = 'OnionStickers',
    pos = { x = 1, y = 2 },
    should_apply = function(self, card, center, area, bypass_roll)
        return false
    end,
    apply = function(self, card, val)
        card.ability[self.key] = val
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.rental_rate or 1 } }
    end
}