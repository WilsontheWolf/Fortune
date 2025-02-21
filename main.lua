Fortune = {}
Fortune_Mod = SMODS.current_mod
Fortune_Config = Fortune_Mod.config


SMODS.Atlas {
    key = "FortuneJokers",
    path = "jokers.png",
    px = 71,
    py = 95
}

SMODS.Atlas {
    key = "FortuneDecks",
    path = "decks.png",
    px = 71,
    py = 95
}

SMODS.Sound({
    key = "RAXD_pants",
    path = "pants.mp3",
    pitch = 1,
    volume = 1
}
)

SMODS.Sound({
    key = "RAXD_gamble_win",
    path = "gamblecorewin.ogg",
    pitch = 1,
    volume = 1
})

SMODS.Sound({
    key = "RAXD_gamble_lose",
    path = "gamblecorelose.ogg",
    pitch = 1,
    volume = 1
})

SMODS.Joker {
    key = "gamblecore",
    rarity = 1,
    atlas = "FortuneJokers",
    pos = { x = 0, y = 0 },
    config = { extra = { odds = 5 } },
    cost = 6,
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal or 1, card.ability.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.before then
            local win = false
            for index, value in ipairs(G.play.cards) do
                if value.config.center == G.P_CENTERS.c_base and not value.debuff then
                    if pseudorandom('aw dangit') < G.GAME.probabilities.normal / card.ability.extra.odds then
                        win = true
                        value:set_ability(
                            G.P_CENTERS[SMODS.poll_enhancement({ guaranteed = true, type_key = 'spinning!!' })], true,
                            false)
                        value:juice_up()
                    end
                end
            end
            if Fortune_Config.FortuneSounds then
                if win then
                    play_sound("RAXD_gamble_win", 1, 1)
                else
                    play_sound("RAXD_gamble_lose", 1, 1)
                end
            end
        end
    end
}

SMODS.Joker {
    key = "responsible",
    rarity = 2,
    atlas = "FortuneJokers",
    pos = { x = 1, y = 0 },
    cost = 6,

    config = { extra = { chipsgained = 10, interestcol = 1, currentchips = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chipsgained, card.ability.extra.interestcol, card.ability.extra.currentchips } }
    end,
}

SMODS.Joker {
    key = "stairs",
    rarity = 2,
    atlas = "FortuneJokers",
    pos = { x = 2, y = 0 },
    cost = 8,
    config = { extra = { xmult = 1, xmult_gain = 0.25 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_gain } }
    end,
    calculate = function(self, card, context)
        if context.before and next(context.poker_hands["Straight"]) then
            local winner = true
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:is_face() then
                    winner = false
                end
            end
            if winner then
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.RED,
                    card = card
                }
            end
        end
        if context.joker_main and card.ability.extra.xmult > 1 then
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } },
                Xmult_mod = card.ability.extra.xmult
            }
        end
    end

}

SMODS.Joker {
    key = "jokercore",
    rarity = 1,
    atlas = "FortuneJokers",
    pos = { x = 3, y = 0 },
    cost = 6,
    config = { extra = { odds_c = 2, odds_u = 8, odds_r = 20 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal or 1, card.ability.extra.odds_c, card.ability.extra.odds_u, card.ability.extra.odds_r } }
    end,
    calculate = function(self, card, context)
        ---I know about context.main_eval, but if possible i want this to be backwards compatible with old calc
        if context.end_of_round and not context.game_over and not context.individual and not context.repetition and #G.jokers.cards <= (G.jokers.config.card_limit - 1) then
            if pseudorandom('aw dangit') < G.GAME.probabilities.normal / card.ability.extra.odds_r then
                G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local card = create_card('Joker', G.jokers, nil, 1, nil, nil, nil, 'rare')
                        card:add_to_deck()
                        G.jokers:emplace(card)
                        card:start_materialize()
                        G.GAME.joker_buffer = 0
                        return true
                    end
                }))
                card_eval_status_text(context.blueprint_card or self, 'extra', nil, nil, nil,
                    { message = localize('k_plus_joker'), colour = G.C.BLUE })
            end
            if pseudorandom('aw dangit') < G.GAME.probabilities.normal / card.ability.extra.odds_u then
                G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local card = create_card('Joker', G.jokers, nil, 0.9, nil, nil, nil, 'uncommon')
                        card:add_to_deck()
                        G.jokers:emplace(card)
                        card:start_materialize()
                        G.GAME.joker_buffer = 0
                        return true
                    end
                }))
                card_eval_status_text(context.blueprint_card or self, 'extra', nil, nil, nil,
                    { message = localize('k_plus_joker'), colour = G.C.BLUE })
            end
            if pseudorandom('aw dangit') < G.GAME.probabilities.normal / card.ability.extra.odds_c then
                G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local card = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, 'common')
                        card:add_to_deck()
                        G.jokers:emplace(card)
                        card:start_materialize()
                        G.GAME.joker_buffer = 0
                        return true
                    end
                }))
                card_eval_status_text(context.blueprint_card or self, 'extra', nil, nil, nil,
                    { message = localize('k_plus_joker'), colour = G.C.BLUE })
            end
        end
    end
}

SMODS.Joker {
    key = "Fishingcore",
    rarity = 2,
    atlas = "FortuneJokers",
    pos = { x = 4, y = 0 },
    cost = 6,
    config = { extra = { odds = 10 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal or 1, card.ability.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.before then
            for index, value in ipairs(G.play.cards) do
                if value.config.center == G.P_CENTERS.c_base and not value.debuff then
                    if pseudorandom('aw dangit') < G.GAME.probabilities.normal / card.ability.extra.odds and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.0,
                            func = (function()
                                local s_card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil,
                                    'wii play fishing')
                                s_card:add_to_deck()
                                G.consumeables:emplace(s_card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end)
                        }))
                        return {
                            message = localize('k_plus_spectral'),
                            colour = G.C.SECONDARY_SET.Spectral,
                            card = card
                        }
                    end
                end
            end
        end
    end
}

SMODS.Joker {
    key = "tungsten",


    rarity = 3,
    atlas = "FortuneJokers",
    pos = { x = 0, y = 1 },
    cost = 6,
}

SMODS.Joker {
    key = "pants",
    rarity = 2,
    atlas = "FortuneJokers",
    pos = { x = 1, y = 1 },
    cost = 7,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_mult
    end,
    calculate = function(self, card, context)
        if context.before and next(context.poker_hands["Two Pair"]) and G.GAME.current_round.hands_played == 0 then
            card:juice_up()
            if Fortune_Config.FortuneSounds then
                play_sound("RAXD_pants", 1, 1)
            else

            end
            for index, value in ipairs(G.play.cards) do
                if not value.debuff then
                    card:juice_up()
                    value:set_ability(G.P_CENTERS.m_mult, nil, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            value:juice_up()
                            return true
                        end
                    }))
                end
            end
        end
    end
}

SMODS.Joker {
    key = "bpay",


    rarity = 2,
    atlas = "FortuneJokers",
    pos = { x = 2, y = 1 },
    cost = 6,
}

SMODS.Joker {
    key = "critical",
    rarity = 3,
    atlas = "FortuneJokers",
    pos = { x = 3, y = 1 },
    cost = 10,
    config = { extra = { odds = 10, xmult = 4 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal or 1, card.ability.extra.odds, card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)

    end
}

SMODS.Joker {
    key = "rockjumpscare",


    rarity = 2,
    atlas = "FortuneJokers",
    pos = { x = 4, y = 1 },
    cost = 6,
}

SMODS.Joker {
    key = "spanishbutton",
    rarity = 3,
    atlas = "FortuneJokers",
    pos = { x = 0, y = 2 },
    cost = 10,
    config = { extra = { xmult = 3 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and G.SETTINGS.language == 'es_ES' or G.SETTINGS.language == 'es_419' then
            return {
				message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } },
				Xmult_mod = card.ability.extra.xmult
			}
        end
    end
}

SMODS.Joker {
    key = "burgerman",

    rarity = 3,
    atlas = "FortuneJokers",
    pos = { x = 1, y = 2 },
    cost = 6,
}

Trafficcolors = {
    ["RED"] = G.C.RED,
    ["BLUE"] = G.C.BLUE
}
SMODS.Joker {
    key = "trafficlight",
    rarity = 1,
    atlas = "FortuneJokers",
    pos = { x = 2, y = 2 },
    cost = 6,
    config = { extra = { blue = false, increase = 1, } },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.increase,
                card.ability.extra.blue and "Hand" or "Discard",
                colours = {
                    card.ability.extra.blue and G.C.BLUE or G.C.RED,
                },
            }
        }
    end,
    calculate = function(self, card, context)
        ---I know about context.main_eval, but if possible i want this to be backwards compatible with old calc
        if context.end_of_round and not context.game_over and not context.individual and not context.repetition and not context.blueprint then
            if card.ability.extra.blue == false then
                card.ability.extra.blue = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        self:set_sprites(card)
                        return true
                    end
                }))
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    { message = localize('k_light_blue'), colour = G.C.BLUE })
            else
                card.ability.extra.blue = false
                G.E_MANAGER:add_event(Event({
                    func = function()
                        self:set_sprites(card)
                        return true
                    end
                }))
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    { message = localize('k_light_red'), colour = G.C.RED })
            end
        end
        if context.setting_blind then
            if card.ability.extra.blue then
                ease_hands_played(card.ability.extra.increase)
            else
                ease_discard(card.ability.extra.increase)
            end
        end
    end,
    set_sprites = function(self, card, front)
        card.children.center:set_sprite_pos({
            x = self.pos.x,
            y = (card.ability and card.ability.extra and card.ability.extra.blue) and
                3 or 2
        })
    end
}

SMODS.Joker {
    key = "deathball",

    rarity = 3,
    atlas = "FortuneJokers",
    pos = { x = 3, y = 2 },
    cost = 6,
}

SMODS.Joker {
    key = "entity",
    rarity = 2,
    atlas = "FortuneJokers",
    pos = { x = 4, y = 2 },
    cost = 6,
    config = {
        extra = {
            mult_mod = 1,
            mult = 1,
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.mult_mod, card.ability.extra.mult }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
            }
        end
    end,
    update = function(self, card, dt)
        if not card.ability.extra.year then
            local now = os.date("*t")
            local date = {
                year = now.year,
                month = 11,
                day = 1,
            }
            card.ability.extra.year = now.year
            card.ability.extra.endTime = os.time(date)
        end
        local today = os.date("%d%m")
        if card.ability.extra.today ~= today then
            card.ability.extra.today = today
            local time = os.time()
            local days = math.ceil(os.difftime(card.ability.extra.endTime, time) / 86400)
            card.ability.extra.mult = card.ability.extra.mult_mod * days
        end
    end,
    load = function(self, card, card_table, other_card)
        card_table.ability.extra.year = nil
        card_table.ability.extra.today = nil
        card_table.ability.extra.endTime = nil
    end,
}

---Config UI

Fortune_Mod.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = { align = "m", r = 0.1, padding = 0.1, colour = G.C.BLACK, minw = 8, minh = 6 },
        nodes = {
            { n = G.UIT.R, config = { align = "cl", padding = 0, minh = 0.1 }, nodes = {} },

            {
                n = G.UIT.R,
                config = { align = "cl", padding = 0 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cl", padding = 0.05 },
                        nodes = {
                            create_toggle { col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = Fortune_Config, ref_value = "FortuneSounds" },
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = "c", padding = 0 },
                        nodes = {
                            { n = G.UIT.T, config = { text = "Joker Sounds", scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
                        }
                    },
                }
            },

        }
    }
end
