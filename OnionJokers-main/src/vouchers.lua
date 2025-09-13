

--spam folder
SMODS.Voucher {
    key = 'spam_folder',
    atlas = "OnionVouchers",
    loc_txt = {
		name = 'Spam Folder',
		text = {
            "Certian {C:attention}Jokers{} & {C:attention}Vouchers{}",
            "{C:red}cannot{} apear in the shop"
		}
	},
    pos = { x = 1, y = 0 },
    config = { extra = { blocklist = {
        "j_obelisk",
        "v_magic_trick",
        "v_illusion"
    }} },
    loc_vars = function(self, info_queue, card)
        for _, i in pairs(card.ability.extra.blocklist) do
            info_queue[#info_queue+1] = G.P_CENTERS[i]
        end
        return { vars = { } }
    end,
    redeem = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                for _, i in pairs(card.ability.extra.blocklist) do
                    G.GAME.banned_keys[i] = true
                end
                return true
            end
        }))
    end,
    unredeem = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                for _, i in pairs(card.ability.extra.blocklist) do
                    G.GAME.banned_keys[i] = nil
                end
                return true
            end
        }))
    end
}

--blocklist
SMODS.Voucher {
    key = 'blocklist',
    atlas = "OnionVouchers",
    loc_txt = {
		name = 'Blocklist',
		text = {
            "{C:attention}Jokers{} sold while in your {C:attention}rightmost{}",
            "{C:attention}Joker{} slot {C:red}cannot{} apear again"
		}
	},
    pos = { x = 1, y = 1 },
    config = { extra = { } },
    requires = { 'v_onio_spam_folder' },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    redeem = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                return true
            end
        }))
    end,
}

--filter
SMODS.Voucher {
    key = 'filter',
    atlas = "OnionVouchers",
    loc_txt = {
		name = 'Filter',
		text = {
            "{C:common}Common{} Jokers are {C:attention}50%{}",
            "less likely to apear"
		}
	},
    pos = { x = 2, y = 0 },
    config = { extra = { } },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end
}

--weedmat
SMODS.Voucher {
    key = 'decontamination',
    atlas = "OnionVouchers",
    requires = { 'v_onio_filter' },
    loc_txt = {
		name = 'Decontamination',
		text = {
            "{C:common}Common{} Jokers {C:red}cannot{} apear in the shop",
            "{C:attention}Stickers{} are {C:attention}75%{} less likely to apear"
		}
	},
    pos = { x = 2, y = 1},
    config = { extra = { } },
    loc_vars = function(self, info_queue, card)
        local j = non_stake_stickers()
        for _, i in pairs(j) do
            --print(i)
            --info_queue[#info_queue+1] = G.shared_stickers[i]
        end
        return { vars = { } }
    end
}

--archaeological site
SMODS.Voucher {
    key = 'arch_site',
    atlas = "OnionVouchers",
    loc_txt = {
		name = 'Archaeological Site',
		text = {
            "{C:attention}Relic{} cards may occasionaly",
            "apear in the {C:attention}shop"
		}
	},
    pos = { x = 0, y = 0 },
    config = { extra = {rate = 999}},--2} },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    redeem = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.relics_rate = self.config.extra.rate
                return true
            end
        }))
    end,
    unredeem = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.relics_rate = 0
                return true
            end
        }))
    end
}

--museum
SMODS.Voucher {
    key = 'museum',
    atlas = "OnionVouchers",
    requires = { 'v_onio_arch_site' },
    loc_txt = {
		name = 'Museum',
		text = {
            "{C:attention}Relic{} cards that select cards",
            "may select {C:attention}1{} more card",
            "{C:inactive}(Max of {C:attention}5{C:inactive} cards)"
		}
	},
    pos = { x = 0, y = 1 },
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
}
