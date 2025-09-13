
--gilded
SMODS.Edition {
    key = 'gilded',
    shader = 'gilded',
    config = { percent = 0.05, max = 50 },
    in_shop = true,
    weight = 6,
    extra_cost = 4,
    sound = { sound = "holo1", per = 1.2 * 1.58, vol = 0.4 },
    loc_txt = {
		name = 'Gilded',
        label = "Gilded",
		text = {
            "{C:money}+#1#% money",
            "{C:inactive}(Max of {C:money}+$#2#{C:inactive})",
            "{C:inactive}(Currently {C:money}+$#3#{C:inactive})",
		}
	},
    loc_vars = function(self, info_queue, card)
        local m = math.min(card.edition.max,math.floor(math.max(0, (G.GAME.dollars or 0) + (G.GAME.dollar_buffer or 0)) * card.edition.percent))
        return { vars = { 100 * self.config.percent, self.config.max, m } }
    end,
    get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    calculate = function(self, card, context)
        if context.pre_joker or (context.main_scoring and context.cardarea == G.play) then
            local m = math.min(
                card.edition.max,
                math.floor(
                    math.max(
                        0,
                        (G.GAME.dollars or 0) + (G.GAME.dollar_buffer or 0)
                    ) * card.edition.percent)
            )
            print(m)
            if type(m) == "number" then
                if m > 0 then
                    return {
                        dollars = m
                    }
                end
            end
        end
    end
}