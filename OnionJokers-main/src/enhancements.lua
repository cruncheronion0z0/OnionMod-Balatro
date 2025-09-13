--------- ENHANCEMENTS:

-- ethereal
SMODS.Enhancement {
    name = "Ethereal Card",
    key = "ethereal",
    badge_colour = HEX("c38773"),
	config = {},
    loc_txt = {
        label = 'Ethereal Card',
        name = 'Ethereal Card',
         text = {
            --"This card has {C:attention}no suit{}.",
            "Draw {C:attention}1{} card to hand when scored.",
            "Draw {C:attention}2{} cards to hand after scoring.",
            "{C:inactive}(Can go over hand size.)"
        }
    },
    --no_suit = true,
    shatters = true,
    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,
    atlas = 'OnionDecks',
    pos = {x=4, y=1},
    draw = function(self, card, layer)
        --onio_greyscale
        local allow = true
        if card.edition or "!" ~= "!" then
            if card.edition.key == "e_negative" then
                allow = false
            end
        end

        if allow then
            card.children.center:draw_shader('onio_ethereal', nil, card.ARGS.send_to_shader)
        end
        --card.children.front:draw_shader('negative', nil, card.ARGS.send_to_shader)
        --card.children.front.children:draw_shader('foil', nil, card.ARGS.send_to_shader)
    end,
    calculate = function(self, card, context)

        if card.edition or "!" ~= "!" then
            if card.edition.key == "e_negative" then
                card.children.center:set_sprite_pos{ x = 4, y = 2 }
            else
                card.children.center:set_sprite_pos{ x = 4, y = 1 }
            end
        else
            card.children.center:set_sprite_pos{ x = 4, y = 1 }
        end

        if context.after and context.cardarea == G.play then
            draw_card(G.deck, G.hand)
            draw_card(G.deck, G.hand)
            --draw_card(G.deck, G.hand)
            return {
                message = "+2 Cards",
                colour = G.C.GREEN
            }
        end
        if context.main_scoring and context.cardarea == G.play then
            draw_card(G.deck, G.hand)
            return {
                message = "+1 Card",
                colour = G.C.GREEN
            }
        end
    end
}

-- chainmail
SMODS.Enhancement {
    name = "Chainmail Card",
    key = "chainmail",
    badge_colour = HEX("a9a9a9"),
	config = {},
    loc_txt = {
        label = 'Chainmail Card', 
        name = 'Chainmail Card',
         text = {
            "Retrigger this card {C:attention}1{} additional time for",
            "every {C:attention}2{} scoring {C:attention}Chainmail{} card played."
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,
    atlas = 'OnionDecks',
    pos = {x=1, y=2},
    calculate = function(self, card, context)

        if context.repetition then
            local count = 0
            for _,a in pairs(G.play.cards) do
                if SMODS.has_enhancement(a, "m_onio_chainmail") then
                    count = count + 1
                end
            end
            count = math.floor(count / 2.0)
            
            return {
                repetitions = count,
                card = card,
            }
        end
        
    end
}

--skip card
SMODS.Enhancement {
    name = "Skip Card",
    key = "skip",
    badge_colour = HEX("6a57e6"),
	config = {},
    loc_txt = {
        label = 'Skip Card',
        name = 'Skip Card',
         text = {
            "This card can fill gaps in {C:attention}straights{}.",
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,
    atlas = 'OnionDecks',
    pos = {x=0, y=2}
}


