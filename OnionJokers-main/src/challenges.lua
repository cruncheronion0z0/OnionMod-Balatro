
--singleplayer
SMODS.Challenge {
    name = "Singleplayer",
    key = 'solo_game',
    loc_txt = {
        name = "Singleplayer"
    },
    rules = {
        custom = {
            {id = "singledesc", value = true}
        }
    },
    jokers = {
        { id = 'j_blueprint', pinned = true, eternal = true },
        { id = 'j_blueprint', pinned = true, eternal = true },
        { id = 'j_blueprint', pinned = true, eternal = true },
        { id = 'j_blueprint', pinned = true, eternal = true },
    },
    restrictions = {
        banned_cards = {
            { id = 'v_blank' },
            { id = 'v_antimatter' },
            { id = 'j_onio_nuclear_shadow' },
            { id = 'c_ectoplasm' },
            { id = 'c_onio_wormhole_planet' },
            { id = 'c_onio_the_clown' },
        },
        banned_tags = {
            { id = 'tag_negative' }
        }
    },
    deck = {
		type = "Challenge Deck",
	}
}