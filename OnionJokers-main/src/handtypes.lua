--- HAND TYPES

-- straight 5
SMODS.PokerHand {
    key = "straight_five",
    mult = 15,
    chips = 150,
    l_mult = 4,
    l_chips = 50,
    example = {
        { 'S_J', true },
        { 'S_J', true },
        { 'C_J', true},
        { 'H_J', true },
        { 'H_J', true }
    },
    loc_txt = {
        name = "Straight Five",
        description = {
            "5 cards of the same rank that",
            "are also {E:1}somehow{} are in a row?"
        }
    },
    visible = false,
    evaluate = function(parts, hand)

        if is_straight(hand) then
            --not next(parts._straight) or
            if not next(parts._5) then return end
            return { SMODS.merge_lists(parts._5) }
        end
        
    end,
}

-- straight flush five
SMODS.PokerHand {
    key = "straight_flush_five",
    mult = 20,
    chips = 200,
    l_mult = 5,
    l_chips = 70,
    example = {
        { 'C_K', true },
        { 'C_K', true },
        { 'C_K', true},
        { 'C_K', true },
        { 'C_K', true }
    },
    loc_txt = {
        name = "Straight Flush Five",
        description = {
            "5 cards of the same rank and suit",
            "that are also {E:1}somehow{} are in a row?"
        }
    },
    visible = false,
    evaluate = function(parts, hand)

        if is_straight(hand) then
            if not next(parts._flush) or not next(parts._5) then return end
            return { SMODS.merge_lists(parts._5) }
        end



    end,
}

-- straight House
SMODS.PokerHand {
    key = "straight_house",
    visible = false,
    mult = 14,
    chips = 140,
    l_mult = 4,
    l_chips = 40,
    example = {
        { 'D_K', true },
        { 'D_K', true },
        { 'C_K', true },
        { 'C_J', true },
        { 'H_J', true }
    },
    loc_txt = {
        name = "Straight House",
        description = {
            "A 3 of a Kind and a Pair",
            "that are also {E:1}somehow{} are in a row?"
        }
    },
    evaluate = function(parts, hand)

        if is_straight(hand) then
            if #parts._3 < 1 or #parts._2 < 2 then return {} end
            return { SMODS.merge_lists(parts._all_pairs) }
        end

    end
}

-- straight flush house
SMODS.PokerHand {
    key = "straight_flush_house",
    mult = 18,
    chips = 175,
    l_mult = 4,
    l_chips = 70,
    example = {
        { 'C_K', true },
        { 'C_K', true },
        { 'C_K', true},
        { 'C_J', true },
        { 'C_J', true }
    },
    loc_txt = {
        name = "Straight Flush House",
        description = {
            "A 3 of a Kind and a Pair",
            "that all share a suit",
            "and are also {E:1}somehow{} are in a row?"
        }
    },
    visible = false,
    evaluate = function(parts, hand)

        if is_straight(hand) then
            if not next(parts._flush) or #parts._3 < 1 or #parts._2 < 2 then return {} end
            return { SMODS.merge_lists(parts._flush,parts._all_pairs) }
        end

    end,
}

