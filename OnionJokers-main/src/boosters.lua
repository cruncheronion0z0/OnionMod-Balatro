--normal relic pack 1
SMODS.Booster {
    key = "relic_normal_1",
    kind = "Relics",
    atlas = "OnionBoosters",
    group_key = "onio_relic_pack",
    loc_txt = {
        name = 'Relic Pack',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{C:attention} Relic{} cards to",
            "be used immediately",
        },
    },
    pos = {
        x = 0,
        y = 0
    },
    config = {
        extra = 3,
        choose = 1
    },
    cost = 4,
    weight = 0.96,
    draw_hand = true,
    create_card = function(self, card)
        return create_card("Relics", G.pack_cards, nil, nil, true, true, nil)
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("c28246"))
        ease_background_colour({ new_colour = HEX("b06933"), special_colour = G.C.BLACK, contrast = 2 })
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { math.min(card.ability.choose + (G.GAME.modifiers.booster_choice_mod or 0), math.max(1, card.ability.extra + (G.GAME.modifiers.booster_size_mod or 0))), math.max(1, card.ability.extra + (G.GAME.modifiers.booster_size_mod or 0)) } }
    end
}

--normal relic pack 2
SMODS.Booster {
    key = "relic_normal_2",
    kind = "Relics",
    atlas = "OnionBoosters",
    loc_txt = {
        name = 'Relic Pack',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{C:attention} Relic{} cards to",
            "be used immediately",
        },
    },
    group_key = "onio_relic_pack",
    pos = {
        x = 1,
        y = 0
    },
    config = {
        extra = 3,
        choose = 1
    },
    cost = 4,
    weight = 0.96,
    draw_hand = true,
    create_card = function(self, card)
        return create_card("Relics", G.pack_cards, nil, nil, true, true, nil)
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("c28246"))
        ease_background_colour({ new_colour = HEX("b06933"), special_colour = G.C.BLACK, contrast = 2 })
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { math.min(card.ability.choose + (G.GAME.modifiers.booster_choice_mod or 0), math.max(1, card.ability.extra + (G.GAME.modifiers.booster_size_mod or 0))), math.max(1, card.ability.extra + (G.GAME.modifiers.booster_size_mod or 0)) } }
    end
}

--jumbo relic pack 1
SMODS.Booster {
    key = "relic_jumbo_1",
    kind = "Relics",
    atlas = "OnionBoosters",
    loc_txt = {
        name = 'Jumbo Relic Pack',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{C:attention} Relic{} cards to",
            "be used immediately",
        },
    },
    group_key = "onio_relic_pack",
    pos = {
        x = 0,
        y = 2
    },
    config = {
        extra = 4,
        choose = 1
    },
    cost = 4,
    weight = 0.96,
    draw_hand = true,
    create_card = function(self, card)
        return create_card("Relics", G.pack_cards, nil, nil, true, true, nil)
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("c28246"))
        ease_background_colour({ new_colour = HEX("b06933"), special_colour = G.C.BLACK, contrast = 2 })
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { math.min(card.ability.choose + (G.GAME.modifiers.booster_choice_mod or 0), math.max(1, card.ability.extra + (G.GAME.modifiers.booster_size_mod or 0))), math.max(1, card.ability.extra + (G.GAME.modifiers.booster_size_mod or 0)) } }
    end
}

--mega relic pack 1
SMODS.Booster {
    key = "relic_mega_1",
    kind = "Relics",
    atlas = "OnionBoosters",
    loc_txt = {
        name = 'Mega Relic Pack',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{C:attention} Relic{} cards to",
            "be used immediately",
        },
    },
    group_key = "onio_relic_pack",
    pos = {
        x = 3,
        y = 2
    },
    config = {
        extra = 5,
        choose = 2
    },
    cost = 4,
    weight = 0.96,
    draw_hand = true,
    create_card = function(self, card)
        return create_card("Relics", G.pack_cards, nil, nil, true, true, nil)
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("c28246"))
        ease_background_colour({ new_colour = HEX("b06933"), special_colour = G.C.BLACK, contrast = 2 })
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { math.min(card.ability.choose + (G.GAME.modifiers.booster_choice_mod or 0), math.max(1, card.ability.extra + (G.GAME.modifiers.booster_size_mod or 0))), math.max(1, card.ability.extra + (G.GAME.modifiers.booster_size_mod or 0)) } }
    end
}
