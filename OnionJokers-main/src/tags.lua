



--clover tag
SMODS.Tag {
    key = "clover",
	loc_txt = {
		name = 'Clover Tag',
		text = {
            "Applies on {C:attention}entering shop{} or {C:attention}reroll{}",
            "All {C:common}Common{} Jokers are {C:money}100%{} off",
            "All {C:uncommon}Uncommon{} Jokers are {C:money}50%{} off",
            "All {C:rare}Rare{} Joker are {C:money}25%{} off",
		}
	},
    atlas = 'OnionTags',
    pos = { x = 0, y = 0 },
    apply = function(self, tag, context)
        if context.type == 'store_joker_modify' and G.shop then
            --local lock = self.ID
            --G.CONTROLLER.locks[lock] = true
            local valids = 0
            if G.shop_jokers and not G.GAME.shop_free then
                for _, i in pairs(G.shop_jokers.cards) do
                    if not i.ability.clovered and i.ability.set == 'Joker' then
                        valids = valids + 1
                    end
                end
            end

            if valids > 0 and not G.GAME.clover_data.trig then
                tag:yep('+', G.C.GREEN, function()
                    if G.shop_jokers then
                        for _, i in pairs(G.shop_jokers.cards) do
                            if i.ability.set == 'Joker' and not i.ability.clovered then
                                i.ability.clovered = true
                                i:set_cost()
                                i:juice_up(0.5,0.125)
                            end
                        end
                        --G.CONTROLLER.locks[lock] = nil
                    end
                    return true
                end)
                G.GAME.clover_data.trig = true
                tag.triggered = true
                return true
            else
                tag.triggered = false
                return nil
            end
        end
    end
}

--stored data for clover tag, making sure that it only triggers once per reroll / shop enter
local igo = Game.init_game_object
function Game:init_game_object()
    local ret = igo(self)
    ret.clover_data = { trig = false }
    return ret
end


